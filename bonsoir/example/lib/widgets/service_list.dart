import 'package:bonsoir/bonsoir.dart';
import 'package:bonsoir_example/models/app_service.dart';
import 'package:bonsoir_example/models/discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Allows to display all discovered services.
class ServiceList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    BonsoirDiscoveryModel model = ref.watch(discoveryModelProvider);
    List<ResolvedBonsoirService> discoveredServices = model.discoveredServices;
    if (discoveredServices.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'Found no service of type "${AppService.type}".',
            style: TextStyle(
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: discoveredServices.length,
      itemBuilder: (context, index) => _ServiceWidget(service: discoveredServices[index]),
    );
  }
}

/// Allows to display a discovered service.
class _ServiceWidget extends StatelessWidget {
  /// The discovered service.
  final ResolvedBonsoirService service;

  /// Creates a new service widget.
  const _ServiceWidget({
    required this.service,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(service.name),
        subtitle: Text('Type : ${service.type}, ip : ${service.ip}, port : ${service.port}'),
      );
}
