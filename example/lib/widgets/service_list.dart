import 'package:bonsoir/bonsoir.dart';
import 'package:bonsoir_example/models/app_service.dart';
import 'package:bonsoir_example/models/discovery.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Allows to display all discovered services.
class ServiceList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BonsoirDiscoveryModel model = context.watch<BonsoirDiscoveryModel>();
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
    @required this.service,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(service.name),
        subtitle: Text('Type : ${service.type}, ip : ${service.ip}, port : ${service.port}'),
      );
}
