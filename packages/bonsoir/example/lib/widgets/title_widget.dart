import 'package:bonsoir_example/models/discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Allows to display the app title based on how many services have been discovered.
class TitleWidget extends ConsumerWidget {
  /// Creates a new title widget instance.
  const TitleWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int discoveredServicesCount = ref.watch(discoveryModelProvider.select((model) => model.services.length));
    return Text(discoveredServicesCount == 0 ? 'Bonsoir app demo' : 'Found $discoveredServicesCount service(s)');
  }
}
