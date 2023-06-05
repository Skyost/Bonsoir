import 'package:bonsoir_platform_interface/src/events/event.dart';
import 'package:bonsoir_platform_interface/src/service/service.dart';

/// A Bonsoir broadcast event.
class BonsoirBroadcastEvent extends BonsoirEvent<BonsoirBroadcastEventType> {
  /// Creates a new Bonsoir broadcast event.
  const BonsoirBroadcastEvent({
    required super.type,
    super.service,
  });

  /// Creates a new Bonsoir broadcast event from the given JSON map.
  BonsoirBroadcastEvent.fromJson(Map<String, dynamic> json)
      : this(
          type: BonsoirBroadcastEventType.values.firstWhere(
            (type) => type.id == json['id'],
            orElse: () => BonsoirBroadcastEventType.unknown,
          ),
          service: json.containsKey('service') ? BonsoirService.fromJson(Map<String, dynamic>.from(json['service'])) : null,
        );
}

/// Available Bonsoir broadcast event types.
enum BonsoirBroadcastEventType {
  /// Triggered when the broadcast has started.
  broadcastStarted,

  /// Triggered when the broadcast has stopped.
  broadcastStopped,

  /// Unknown type.
  unknown;

  /// Returns the type name.
  String get id => toString().split('.').last;
}
