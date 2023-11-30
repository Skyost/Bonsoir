import 'package:bonsoir_platform_interface/src/events/types/type.dart';

/// Available Bonsoir discovery event types.
enum BonsoirDiscoveryEventType with BonsoirEventType {
  /// Triggered when the discovery has started.
  discoveryStarted,

  /// Triggered when a service has been found.
  discoveryServiceFound,

  /// Triggered when a service has been found and resolved.
  discoveryServiceResolved,

  /// Triggered when a service has been found but cannot be resolved.
  discoveryServiceResolveFailed,

  /// Triggered when a service has been lost.
  discoveryServiceLost,

  /// Triggered when the discovery has stopped.
  discoveryStopped,

  /// Unknown type.
  unknown;

  /// Returns a [BonsoirDiscoveryEventType] by its [id] or [unknown] if not found.
  static BonsoirDiscoveryEventType getById(String id) => values.firstWhere(
        (type) => type.id == id,
        orElse: () => BonsoirDiscoveryEventType.unknown,
      );
}
