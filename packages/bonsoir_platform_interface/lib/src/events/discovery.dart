import 'package:bonsoir_platform_interface/src/events/event.dart';
import 'package:bonsoir_platform_interface/src/service/service.dart';

/// A Bonsoir discovery event.
sealed class BonsoirDiscoveryEvent extends BonsoirEvent {
  /// Creates a new Bonsoir discovery event.
  const BonsoirDiscoveryEvent({
    super.id,
    super.service,
  });

  /// Creates a [BonsoirDiscoveryEvent] from a [json] map.
  factory BonsoirDiscoveryEvent.fromJson(Map<String, dynamic> json) => BonsoirDiscoveryEvent.fromId(
    id: json['id'],
    service: json.containsKey('service') ? BonsoirService.fromJson(Map<String, dynamic>.from(json['service'])) : null,
  );

  /// Creates a [BonsoirDiscoveryEvent] from its [id].
  factory BonsoirDiscoveryEvent.fromId({
    required String id,
    BonsoirService? service,
  }) => switch (id) {
    BonsoirDiscoveryStartedEvent.discoveryStarted => const BonsoirDiscoveryStartedEvent(),
    BonsoirDiscoveryServiceFoundEvent.discoveryServiceFound => BonsoirDiscoveryServiceFoundEvent(service: service!),
    BonsoirDiscoveryServiceResolvedEvent.discoveryServiceResolved => BonsoirDiscoveryServiceResolvedEvent(service: service!),
    BonsoirDiscoveryServiceUpdatedEvent.discoveryServiceUpdated => BonsoirDiscoveryServiceUpdatedEvent(service: service!),
    BonsoirDiscoveryServiceResolveFailedEvent.discoveryServiceResolveFailed => const BonsoirDiscoveryServiceResolveFailedEvent(),
    BonsoirDiscoveryServiceLostEvent.discoveryServiceLost => BonsoirDiscoveryServiceLostEvent(service: service!),
    BonsoirDiscoveryStoppedEvent.discoveryStopped => const BonsoirDiscoveryStoppedEvent(),
    _ => BonsoirDiscoveryUnknownEvent(id: id, service: service),
  };
}

/// Triggered when the discovery has started.
class BonsoirDiscoveryStartedEvent extends BonsoirDiscoveryEvent {
  /// The event id.
  static const String discoveryStarted = 'discoveryStarted';

  /// Creates a new Bonsoir discovery started event instance.
  const BonsoirDiscoveryStartedEvent();
}

/// Triggered when a service has been found.
class BonsoirDiscoveryServiceFoundEvent extends BonsoirDiscoveryEvent {
  /// The event id.
  static const String discoveryServiceFound = 'discoveryServiceFound';

  /// Creates a new Bonsoir discovery service found event instance.
  const BonsoirDiscoveryServiceFoundEvent({
    required BonsoirService super.service,
  });

  @override
  BonsoirService get service => super.service as BonsoirService;
}

/// Triggered when a service has been found and resolved.
class BonsoirDiscoveryServiceResolvedEvent extends BonsoirDiscoveryEvent {
  /// The event id.
  static const String discoveryServiceResolved = 'discoveryServiceResolved';

  /// Creates a new Bonsoir discovery service resolved event instance.
  const BonsoirDiscoveryServiceResolvedEvent({
    required BonsoirService super.service,
  });

  @override
  BonsoirService get service => super.service as BonsoirService;
}

/// Triggered when a service has been updated.
class BonsoirDiscoveryServiceUpdatedEvent extends BonsoirDiscoveryEvent {
  /// The event id.
  static const String discoveryServiceUpdated = 'discoveryServiceUpdated';

  /// Creates a new Bonsoir discovery service updated event instance.
  const BonsoirDiscoveryServiceUpdatedEvent({
    required BonsoirService super.service,
  });

  @override
  BonsoirService get service => super.service as BonsoirService;
}

/// Triggered when a service has been found but cannot be resolved.
class BonsoirDiscoveryServiceResolveFailedEvent extends BonsoirDiscoveryEvent {
  /// The event id.
  static const String discoveryServiceResolveFailed = 'discoveryServiceResolveFailed';

  /// Creates a new Bonsoir discovery service resolve failed event instance.
  const BonsoirDiscoveryServiceResolveFailedEvent();
}

/// Triggered when a service has been lost.
class BonsoirDiscoveryServiceLostEvent extends BonsoirDiscoveryEvent {
  /// The event id.
  static const String discoveryServiceLost = 'discoveryServiceLost';

  /// Creates a new Bonsoir discovery service lost event instance.
  const BonsoirDiscoveryServiceLostEvent({
    required BonsoirService super.service,
  });

  @override
  BonsoirService get service => super.service as BonsoirService;
}

/// Triggered when the discovery has stopped.
class BonsoirDiscoveryStoppedEvent extends BonsoirDiscoveryEvent {
  /// The event id.
  static const String discoveryStopped = 'discoveryStopped';

  /// Creates a new Bonsoir discovery stopped event instance.
  const BonsoirDiscoveryStoppedEvent();
}

/// Unknown event occurred.
class BonsoirDiscoveryUnknownEvent extends BonsoirDiscoveryEvent {
  /// Creates a new Bonsoir discovery unknown event instance.
  const BonsoirDiscoveryUnknownEvent({
    super.id,
    super.service,
  });
}
