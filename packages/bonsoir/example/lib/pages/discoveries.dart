import 'package:bonsoir/bonsoir.dart';
import 'package:bonsoir_example/models/discovery.dart';
import 'package:bonsoir_example/widgets/service_list.dart';
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
    BonsoirDiscoveryModel discoveryModel = ref.watch(discoveryModelProvider);
    return ServiceList.fromMap(
      services: discoveryModel.services,
      emptyText: 'Currently not discovering any service.',
      typeHeaderWidgetBuilder: (context, type) {
        _TypeHeaderWidget headerWidget = _TypeHeaderWidget(type: type);
        return discoveryModel.services[type]!.isEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  headerWidget,
                  Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: const CircularProgressIndicator(),
                      title: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          'Searching for services of type "$type"...',
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : headerWidget;
      },
      trailingServiceWidgetBuilder: (context, service) => service is ResolvedBonsoirService
          ? null
          : TextButton(
              child: Text('Resolve'.toUpperCase()),
              onPressed: () => discoveryModel.resolveService(service),
            ),
    );
  }
}

/// Allows to display the current type.
class _TypeHeaderWidget extends ConsumerWidget {
  /// The type.
  final String type;

  /// Creates a new type header widget.
  const _TypeHeaderWidget({
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
        leading: const Icon(Icons.chevron_right),
        title: Text(
          type,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        trailing: TextButton(
          child: Text('Stop'.toUpperCase()),
          onPressed: () => ref.read(discoveryModelProvider).stop(type),
        ),
      );
}
