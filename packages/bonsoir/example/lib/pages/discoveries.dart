import 'package:bonsoir/bonsoir.dart';
import 'package:bonsoir_example/models/discovery.dart';
import 'package:bonsoir_example/widgets/service_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays the current discoveries.
class DiscoveriesPageWidget extends ConsumerWidget {
  /// Creates a new discoveries page widget instance.
  const DiscoveriesPageWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<String> discoveries = ref.watch(discoveryTypeListProvider);
    return Center(
      child: ListView(
        padding: EdgeInsets.all(10),
        shrinkWrap: discoveries.isEmpty,
        children: [
          if (discoveries.isEmpty)
            Text(
              'Currently not discovering any service.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
          for (String type in discoveries)
            _DiscoveryTypeWidget(
              type: type,
            ),
        ],
      ),
    );
  }
}

/// Displays a discovery type.
class _DiscoveryTypeWidget extends ConsumerStatefulWidget {
  /// The type.
  final String type;

  /// Creates a new discovery type widget instance.
  const _DiscoveryTypeWidget({
    required this.type,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DiscoveryTypeWidgetState();
}

/// The discovery type widget state.
class _DiscoveryTypeWidgetState extends ConsumerState<_DiscoveryTypeWidget> with AutomaticKeepAliveClientMixin<_DiscoveryTypeWidget> {
  @override
  bool wantKeepAlive = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      discoveryTypeStateProvider(widget.type),
      (_, next) {
        switch (next.value) {
          case BonsoirDiscoveryReadyState():
          case BonsoirDiscoveryStartedState():
            wantKeepAlive = true;
            updateKeepAlive();
            break;
          case BonsoirDiscoveryStoppedState():
          case null:
            wantKeepAlive = false;
            updateKeepAlive();
            break;
        }
      },
      fireImmediately: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    AsyncValue<BonsoirDiscoveryState> discoveryState = ref.watch(discoveryTypeStateProvider(widget.type));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TypeHeaderWidget(
          type: widget.type,
          state: discoveryState.value,
        ),
        if (discoveryState.isLoading)
          Padding(
            padding: EdgeInsets.all(10),
            child: CircularProgressIndicator(),
          )
        else if (!discoveryState.hasValue || discoveryState.value!.services.isEmpty)
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: const CircularProgressIndicator(),
              title: Text(
                'Searching for services of type "${widget.type}"...',
              ),
            ),
          )
        else
          for (BonsoirService service in discoveryState.value!.services)
            ServiceWidget(
              service: service,
              trailing: service.host == null
                  ? TextButton(
                      child: Text('Resolve'),
                      onPressed: () => service.resolve(discoveryState.value!.serviceResolver),
                    )
                  : null,
            ),
      ],
    );
  }
}

/// Allows to display the current type.
class _TypeHeaderWidget extends ConsumerWidget {
  /// The type.
  final String type;

  /// The discovery state.
  final BonsoirDiscoveryState? state;

  /// Creates a new type header widget.
  const _TypeHeaderWidget({
    required this.type,
    this.state,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
    leading: const Icon(Icons.chevron_right),
    title: Text(
      type,
      style: Theme.of(context).textTheme.titleLarge,
    ),
    subtitle: state == null ? null : Text('Discovery state : $discoveryStateText'),
    trailing: TextButton(
      child: Text('Stop'),
      onPressed: () => ref.read(discoveryTypeListProvider.notifier).remove(type),
    ),
  );

  /// The discovery state.
  String? get discoveryStateText => switch (state) {
    BonsoirDiscoveryReadyState() => 'ready',
    BonsoirDiscoveryStartedState() => 'started',
    BonsoirDiscoveryStoppedState() => 'stopped',
    _ => null,
  };
}
