import 'package:bonsoir_platform_interface/src/events/types/type.dart';

/// Available Bonsoir broadcast event types.
enum BonsoirBroadcastEventType with BonsoirEventType {
  /// Triggered when the broadcast has started.
  broadcastStarted,

  /// Triggered when a name conflicts occurs.
  broadcastNameAlreadyExists,

  /// Triggered when the broadcast has stopped.
  broadcastStopped,

  /// Unknown type.
  unknown;

  /// Returns a [BonsoirBroadcastEventType] by its [id] or [unknown] if not found.
  static BonsoirBroadcastEventType getById(String id) => values.firstWhere(
        (type) => type.id == id,
        orElse: () => BonsoirBroadcastEventType.unknown,
      );
}
