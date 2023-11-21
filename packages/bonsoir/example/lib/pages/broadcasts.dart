import 'package:bonsoir_example/models/broadcast.dart';
import 'package:bonsoir_example/widgets/service_list.dart';
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
    BonsoirBroadcastModel broadcastModel = ref.watch(broadcastModelProvider);
    return ServiceList(
      services: broadcastModel.broadcastedServices,
      emptyText: 'Currently not broadcasting any service.',
      trailingServiceWidgetBuilder: (context, service) => TextButton(
        child: Text('Stop'.toUpperCase()),
        onPressed: () => broadcastModel.stop(service),
      ),
    );
  }
}
