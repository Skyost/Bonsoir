import 'package:bonsoir_platform_interface/src/events/event.dart';
import 'package:bonsoir_platform_interface/src/service/service.dart';

/// A Bonsoir discovery event.
class BonsoirDiscoveryEvent extends BonsoirEvent<BonsoirDiscoveryEventType> {
  /// Creates a new Bonsoir discovery event.
  const BonsoirDiscoveryEvent({
    required super.type,
    super.service,
  });

  /// Creates a new Bonsoir discovery event from the given JSON map.
  BonsoirDiscoveryEvent.fromJson(Map<String, dynamic> json)
      : this(
          type: BonsoirDiscoveryEventType.values.firstWhere(
            (type) => type.id == json['id'],
            orElse: () => BonsoirDiscoveryEventType.unknown,
          ),
          service: json.containsKey('service') ? BonsoirService.fromJson(Map<String, dynamic>.from(json['service'])) : null,
        );
}

/// Available Bonsoir discovery event types.
enum BonsoirDiscoveryEventType {
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

  /// Returns the type name.
  String get id => toString().split('.').last;
}
