import 'package:bonsoir/bonsoir.dart';
import 'package:bonsoir_example/models/app_service.dart';
import 'package:bonsoir_example/models/discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Allows to display all discovered services.
class ServiceList extends ConsumerWidget {
  /// Creates a new service list instance.
  const ServiceList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    BonsoirDiscoveryModel model = ref.watch(discoveryModelProvider);
    if (model.services.isEmpty) {
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

    return ListView(
      children: [
        for (BonsoirService service in model.services)
          _ServiceWidget(
            service: service,
          )
      ],
    );
  }
}

/// Allows to display a discovered service.
class _ServiceWidget extends ConsumerWidget {
  /// The discovered service.
  final BonsoirService service;

  /// Creates a new service widget.
  const _ServiceWidget({
    required this.service,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String subtitle = 'Type : ${service.type}';
    if (service.attributes.containsKey(AppService.attributeOs)) {
      subtitle += ', OS : ${service.attributes[AppService.attributeOs]}';
    }
    if (service.attributes.containsKey(AppService.attributeUuid)) {
      subtitle += ', UUID : ${service.attributes[AppService.attributeUuid]}';
    }
    if (service is ResolvedBonsoirService) {
      subtitle += '\nHost : ${(service as ResolvedBonsoirService).host}, port : ${service.port}';
    }

    VoidCallback? serviceResolverFunction = ref.watch(discoveryModelProvider.select((model) => model.getServiceResolverFunction(service)));
    return ListTile(
      title: Text(service.name),
      subtitle: Text(subtitle),
      trailing: service is ResolvedBonsoirService
          ? null
          : TextButton(
              onPressed: serviceResolverFunction!,
              child: Text('Resolve'.toUpperCase()),
            ),
    );
  }
}
