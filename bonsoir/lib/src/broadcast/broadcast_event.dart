import 'package:bonsoir/src/event.dart';
import 'package:bonsoir/src/service.dart';
import 'package:meta/meta.dart';

/// A Bonsoir broadcast event.
class BonsoirBroadcastEvent extends BonsoirEvent<BonsoirBroadcastEventType> {
  /// Creates a new Bonsoir broadcast event.
  const BonsoirBroadcastEvent({
    @required BonsoirBroadcastEventType type,
    BonsoirService service,
  }) : super(
          type: type,
          service: service,
        );

  /// Creates a new Bonsoir broadcast event from the given JSON map.
  BonsoirBroadcastEvent.fromJson(Map<String, dynamic> json)
      : this(
          type: BonsoirBroadcastEventType.values.firstWhere(
              (type) => type.name.toLowerCase() == json['id'],
              orElse: () => BonsoirBroadcastEventType.UNKNOWN),
          service: json.containsKey('service')
              ? BonsoirService.fromJson(
                  Map<String, dynamic>.from(json['service']))
              : null,
        );
}

/// Available Bonsoir broadcast event types.
enum BonsoirBroadcastEventType {
  /// Triggered when the broadcast has started.
  BROADCAST_STARTED,

  /// Triggered when the broadcast has stopped.
  BROADCAST_STOPPED,

  /// Unknown type.
  UNKNOWN,
}

/// Allows to give a name to broadcast event types.
extension BonsoirBroadcastEventTypeName on BonsoirBroadcastEventType {
  /// Returns the type name.
  String get name => toString().split('.').last;
}
