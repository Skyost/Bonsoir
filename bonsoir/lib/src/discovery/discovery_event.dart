import 'package:bonsoir/src/event.dart';
import 'package:bonsoir/src/service.dart';

/// A Bonsoir discovery event.
class BonsoirDiscoveryEvent extends BonsoirEvent<BonsoirDiscoveryEventType> {
  /// Creates a new Bonsoir discovery event.
  const BonsoirDiscoveryEvent({
    required BonsoirDiscoveryEventType type,
    BonsoirService? service,
  }) : super(
          type: type,
          service: service,
        );

  /// Creates a new Bonsoir discovery event from the given JSON map.
  BonsoirDiscoveryEvent.fromJson(Map<String, dynamic> json)
      : this(
          type: BonsoirDiscoveryEventType.values.firstWhere((type) => type.name.toLowerCase() == json['id'], orElse: () => BonsoirDiscoveryEventType.UNKNOWN),
          service: json.containsKey('service') ? BonsoirService.fromJson(Map<String, dynamic>.from(json['service'])) : null,
        );
}

/// Available Bonsoir discovery event types.
enum BonsoirDiscoveryEventType {
  /// Triggered when the discovery has started.
  DISCOVERY_STARTED,

  /// Triggered when a service has been found.
  DISCOVERY_SERVICE_FOUND,

  /// Triggered when a service has been found and resolved.
  DISCOVERY_SERVICE_RESOLVED,

  /// Triggered when a service has been found but cannot be resolved.
  DISCOVERY_SERVICE_RESOLVE_FAILED,

  /// Triggered when a service has been lost.
  DISCOVERY_SERVICE_LOST,

  /// Triggered when the discovery has stopped.
  DISCOVERY_STOPPED,

  /// Unknown type.
  UNKNOWN,
}

/// Allows to give a name to discovery event types.
extension BonsoirDiscoveryEventTypeName on BonsoirDiscoveryEventType {
  /// Returns the type name.
  String get name => toString().split('.').last;
}
