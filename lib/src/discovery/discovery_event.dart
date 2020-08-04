import 'package:bonsoir/src/discovery/discovered_service.dart';
import 'package:flutter/material.dart';

class BonsoirDiscoveryEvent {
  final BonsoirDiscoveryEventType type;
  final DiscoveredBonsoirService service;

  const BonsoirDiscoveryEvent({
    @required this.type,
    this.service,
  });
}

enum BonsoirDiscoveryEventType {
  DISCOVERY_STARTED,
  DISCOVERY_SERVICE_FOUND,
  DISCOVERY_SERVICE_LOST,
  DISCOVERY_STOPPED,
  UNKNOWN,
}

extension BonsoirDiscoveryEventTypeName on BonsoirDiscoveryEventType {
  String get name => toString().split('.').last;
}