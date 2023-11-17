import 'package:bonsoir_platform_interface/src/events/event.dart';

/// A Bonsoir broadcast event.
class BonsoirBroadcastEvent extends BonsoirEvent<BonsoirBroadcastEventType> {
  /// Creates a new Bonsoir broadcast event.
  const BonsoirBroadcastEvent({
    required super.type,
    super.service,
  });
}

/// Available Bonsoir broadcast event types.
enum BonsoirBroadcastEventType {
  /// Triggered when the broadcast has started.
  broadcastStarted,

  /// Triggered when a name conflicts occurs.
  broadcastNameAlreadyExists,

  /// Triggered when the broadcast has stopped.
  broadcastStopped,

  /// Unknown type.
  unknown;

  /// Returns the type name.
  String get id => toString().split('.').last;
}
