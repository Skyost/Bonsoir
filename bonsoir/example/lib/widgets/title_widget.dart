import 'package:bonsoir/bonsoir.dart';
import 'package:bonsoir_example/models/discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Allows to display the app title based on how many services have been discovered.
class TitleWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<ResolvedBonsoirService> discoveredServices = ref.watch(discoveryModelProvider.select((model) => model.discoveredServices));
    return Text(discoveredServices.isEmpty ? 'Bonsoir app demo' : 'Found ${discoveredServices.length} service(s)');
  }
}
