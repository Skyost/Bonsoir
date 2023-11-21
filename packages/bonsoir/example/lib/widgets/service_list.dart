import 'dart:collection';

import 'package:bonsoir/bonsoir.dart';
import 'package:bonsoir_example/models/app_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Allows to display a list of services.
class ServiceList extends StatelessWidget {
  /// The services to display.
  final Map<String, List<BonsoirService>> services;

  /// Builds the type header widget.
  final Widget Function(BuildContext, String)? typeHeaderWidgetBuilder;

  /// Builds the trailing widget for the given service.
  final Widget? Function(BuildContext, BonsoirService)? trailingServiceWidgetBuilder;

  /// The text to display when the list is empty.
  final String emptyText;

  /// Creates a new service list instance.
  ServiceList({
    Key? key,
    required Iterable<BonsoirService> services,
    required String emptyText,
    Widget Function(BuildContext, BonsoirService)? trailingServiceWidgetBuilder,
  }) : this.fromMap(
          key: key,
          services: _buildMap(services),
          emptyText: emptyText,
          trailingServiceWidgetBuilder: trailingServiceWidgetBuilder,
        );

  /// Creates a new service list instance.
  ServiceList.fromMap({
    super.key,
    required Map<String, List<BonsoirService>> services,
    this.typeHeaderWidgetBuilder,
    this.trailingServiceWidgetBuilder,
    required this.emptyText,
  }) : services = SplayTreeMap.from(services, (a, b) => a.compareTo(b));

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            emptyText,
            style: const TextStyle(
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      children: [
        for (MapEntry<String, List<BonsoirService>> entry in services.entries) ...[
          if (typeHeaderWidgetBuilder != null) typeHeaderWidgetBuilder!(context, entry.key),
          for (BonsoirService service in entry.value)
            _ServiceWidget(
              service: service,
              trailing: trailingServiceWidgetBuilder?.call(context, service),
            ),
        ],
      ],
    );
  }

  /// Builds a sorted map of services.
  static Map<String, List<BonsoirService>> _buildMap(Iterable<BonsoirService> services) {
    Map<String, List<BonsoirService>> result = {};
    for (BonsoirService service in services) {
      result[service.type] ??= [];
      result[service.type]!.add(service);
      result[service.type]!.sort((a, b) => a.name.compareTo(b.name));
    }
    return result;
  }
}

/// Allows to display a discovered service.
class _ServiceWidget extends ConsumerWidget {
  /// The discovered service.
  final BonsoirService service;

  /// The trailing widget.
  final Widget? trailing;

  /// Creates a new service widget.
  const _ServiceWidget({
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
      }
      else if (key == DefaultAppService.attributeUuid) {
        key = 'UUID';
      }
      subtitle += ', $key : ${entry.value}';
    }

    if (service is ResolvedBonsoirService) {
      subtitle += '\nHost : ${(service as ResolvedBonsoirService).host}, port : ${service.port}';
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
