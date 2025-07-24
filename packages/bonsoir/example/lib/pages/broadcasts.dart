import 'package:bonsoir/bonsoir.dart';
import 'package:bonsoir_example/models/broadcast.dart';
import 'package:bonsoir_example/widgets/service_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays the current broadcasts.
class BroadcastsPageWidget extends ConsumerWidget {
  /// Creates a new broadcasts page widget instance.
  const BroadcastsPageWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<BonsoirService> broadcasts = ref.watch(broadcastServiceListProvider);
    return Center(
      child: ListView(
        padding: EdgeInsets.all(10),
        shrinkWrap: broadcasts.isEmpty,
        children: [
          if (broadcasts.isEmpty)
            Text(
              'Currently not broadcasting any service.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
          for (BonsoirService broadcast in broadcasts)
            _BroadcastServiceWidget(
              service: broadcast,
            ),
        ],
      ),
    );
  }
}

/// Displays a broadcast service.
class _BroadcastServiceWidget extends ConsumerStatefulWidget {
  /// The broadcast service.
  final BonsoirService service;

  /// Creates a new broadcast service widget instance.
  const _BroadcastServiceWidget({
    required this.service,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BroadcastServiceWidgetState();
}

/// The broadcast service widget state.
class _BroadcastServiceWidgetState extends ConsumerState<_BroadcastServiceWidget> with AutomaticKeepAliveClientMixin<_BroadcastServiceWidget> {
  @override
  bool wantKeepAlive = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      broadcastServiceStateProvider(widget.service),
      (_, next) {
        switch (next.value) {
          case BonsoirBroadcastReadyState():
          case BonsoirBroadcastStartedState():
            wantKeepAlive = true;
            updateKeepAlive();
            break;
          case BonsoirBroadcastStoppedState():
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
    AsyncValue<BonsoirBroadcastState> broadcastState = ref.watch(broadcastServiceStateProvider(widget.service));
    String? broadcastStateText = switch (broadcastState.value) {
      BonsoirBroadcastReadyState() => 'ready',
      BonsoirBroadcastStartedState() => 'started',
      BonsoirBroadcastStoppedState() => 'stopped',
      _ => null,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ServiceWidget(
          service: broadcastState.value?.service ?? widget.service,
          trailing: broadcastState.isLoading
              ? CircularProgressIndicator()
              : TextButton(
                  child: Text('Stop'),
                  onPressed: () => ref.read(broadcastServiceListProvider.notifier).remove(widget.service),
                ),
        ),
        if (broadcastStateText != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
            child: Text.rich(
              TextSpan(
                children: [
                  WidgetSpan(
                    child: Icon(
                      Icons.chevron_right,
                      size: Theme.of(context).textTheme.bodySmall?.fontSize,
                    ),
                  ),
                  TextSpan(
                    text: ' Broadcast state : $broadcastStateText',
                  ),
                ],
              ),
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
