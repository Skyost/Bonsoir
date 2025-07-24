import 'package:bonsoir_platform_interface/src/events/event.dart';
import 'package:bonsoir_platform_interface/src/service/service.dart';

/// A Bonsoir broadcast event.
class BonsoirBroadcastEvent extends BonsoirEvent {
  /// Creates a new Bonsoir broadcast event.
  const BonsoirBroadcastEvent({
    super.id,
    super.service,
  });

  /// Creates a [BonsoirBroadcastEvent] from a [json] map.
  factory BonsoirBroadcastEvent.fromJson(Map<String, dynamic> json) => BonsoirBroadcastEvent.fromId(
    id: json['id'],
    service: json.containsKey('service') ? BonsoirService.fromJson(Map<String, dynamic>.from(json['service'])) : null,
  );

  /// Creates a [BonsoirBroadcastEvent] from its [id].
  factory BonsoirBroadcastEvent.fromId({
    required String id,
    BonsoirService? service,
  }) => switch (id) {
    BonsoirBroadcastStartedEvent.broadcastStarted => BonsoirBroadcastStartedEvent(service: service!),
    BonsoirBroadcastNameAlreadyExistsEvent.broadcastNameAlreadyExists => BonsoirBroadcastNameAlreadyExistsEvent(service: service!),
    BonsoirBroadcastStoppedEvent.broadcastStopped => BonsoirBroadcastStoppedEvent(service: service!),
    _ => BonsoirBroadcastUnknownEvent(id: id, service: service),
  };
}

/// Triggered when the broadcast has started.
class BonsoirBroadcastStartedEvent extends BonsoirBroadcastEvent {
  /// The event id.
  static const String broadcastStarted = 'broadcastStarted';

  /// Creates a new Bonsoir broadcast started event started instance.
  const BonsoirBroadcastStartedEvent({
    super.id,
    required BonsoirService super.service,
  });

  @override
  BonsoirService get service => super.service as BonsoirService;
}

/// Triggered when a name conflicts occurs.
class BonsoirBroadcastNameAlreadyExistsEvent extends BonsoirBroadcastEvent {
  /// The event id.
  static const String broadcastNameAlreadyExists = 'broadcastNameAlreadyExists';

  /// Creates a new Bonsoir broadcast name already exists event instance.
  const BonsoirBroadcastNameAlreadyExistsEvent({
    required BonsoirService super.service,
  });

  @override
  BonsoirService get service => super.service as BonsoirService;
}

/// Triggered when the broadcast has stopped.
class BonsoirBroadcastStoppedEvent extends BonsoirBroadcastEvent {
  /// The event id.
  static const String broadcastStopped = 'broadcastStopped';

  /// Creates a new Bonsoir broadcast stopped event instance.
  const BonsoirBroadcastStoppedEvent({
    required BonsoirService super.service,
  });

  @override
  BonsoirService get service => super.service as BonsoirService;
}

/// Unknown event occurred.
class BonsoirBroadcastUnknownEvent extends BonsoirBroadcastEvent {
  /// Creates a new Bonsoir broadcast unknown event instance.
  const BonsoirBroadcastUnknownEvent({
    super.id,
    super.service,
  });
}
