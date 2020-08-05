import 'package:bonsoir/src/discovery/discovered_service.dart';
import 'package:flutter/material.dart';

/// A Bonsoir discovery event.
class BonsoirDiscoveryEvent {
  /// The event type.
  final BonsoirDiscoveryEventType type;

  /// The service (can be null, it depends on the event type).
  final DiscoveredBonsoirService service;

  /// Creates a new Bonsoir discovery event.
  const BonsoirDiscoveryEvent({
    @required this.type,
    this.service,
  });
}

/// Available Bonsoir discovery event types.
enum BonsoirDiscoveryEventType {
  /// Triggered when the discovery has started.
  DISCOVERY_STARTED,

  /// Triggered when a service has been found.
  DISCOVERY_SERVICE_FOUND,

  /// Triggered when a discovered service has been lost.
  DISCOVERY_SERVICE_LOST,

  /// Triggered when the discovery has stopped.
  DISCOVERY_STOPPED,

  /// Unknown type.
  UNKNOWN,
}

/// Allows to give a name to event types.
extension BonsoirDiscoveryEventTypeName on BonsoirDiscoveryEventType {
  /// Returns the type name.
  String get name => toString().split('.').last;
}
