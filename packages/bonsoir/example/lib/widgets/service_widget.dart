import 'package:bonsoir/bonsoir.dart';
import 'package:bonsoir_example/models/app_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Allows to display a discovered service.
class ServiceWidget extends ConsumerWidget {
  /// The discovered service.
  final BonsoirService service;

  /// The trailing widget.
  final Widget? trailing;

  /// Creates a new service widget.
  const ServiceWidget({
    super.key,
    required this.service,
    this.trailing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String subtitle = 'Type : ${service.type}';
    for (MapEntry<String, String> entry in service.attributes.entries) {
      String key = entry.key;
      if (key == DefaultAppService.attributeOs) {
        key = 'OS';
      } else if (key == DefaultAppService.attributeUuid) {
        key = 'UUID';
      }
      subtitle += ', $key : ${entry.value}';
    }

    if (service.host != null) {
      subtitle += '\nHost : ${service.host}, port : ${service.port}';
    }

    return Card(
      child: ListTile(
        leading: const Icon(Icons.wifi),
        title: Text(service.name),
        subtitle: Text(subtitle),
        trailing: trailing,
        isThreeLine: true,
      ),
    );
  }
}
