import 'package:flutter/material.dart';

/// A Bonsoir broadcast event.
class BonsoirBroadcastEvent {
  /// The event type.
  final BonsoirBroadcastEventType type;

  /// Creates a new Bonsoir broadcast event.
  const BonsoirBroadcastEvent({
    @required this.type,
  });
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

/// Allows to give a name to event types.
extension BonsoirBroadcastEventTypeName on BonsoirBroadcastEventType {
  /// Returns the type name.
  String get name => toString().split('.').last;
}
