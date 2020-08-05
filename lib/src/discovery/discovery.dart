import 'package:bonsoir/src/bonsoir_class.dart';
import 'package:bonsoir/src/discovery/discovered_service.dart';
import 'package:bonsoir/src/discovery/discovery_event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Allows to run a network discovery.
class BonsoirDiscovery extends BonsoirClass<BonsoirDiscoveryEvent> {
  /// The type of service to find.
  final String type;

  /// Creates a new Bonsoir discovery instance.
  BonsoirDiscovery({
    bool printLogs = kDebugMode,
    @required this.type,
  }) : super(
          classType: 'discovery',
          printLogs: printLogs,
        );

  @override
  @protected
  BonsoirDiscoveryEvent transformPlatformEvent(dynamic event) {
    Map<String, dynamic> data = Map<String, dynamic>.from(event);
    String id = data['id'];
    BonsoirDiscoveryEventType type = BonsoirDiscoveryEventType.values.firstWhere((type) => type.name.toLowerCase() == id, orElse: () => BonsoirDiscoveryEventType.UNKNOWN);
    DiscoveredBonsoirService service;
    if (type == BonsoirDiscoveryEventType.DISCOVERY_SERVICE_FOUND || type == BonsoirDiscoveryEventType.DISCOVERY_SERVICE_LOST) {
      service = jsonToService(Map<String, dynamic>.from(data['result']));
    }

    return BonsoirDiscoveryEvent(type: type, service: service);
  }

  @override
  @protected
  Map<String, dynamic> toJson() => super.toJson()..['type'] = type;
}
