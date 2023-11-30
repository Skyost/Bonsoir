import 'package:bonsoir_platform_interface/src/events/event.dart';
import 'package:bonsoir_platform_interface/src/events/types/broadcast.dart';

/// A Bonsoir broadcast event.
class BonsoirBroadcastEvent extends BonsoirEvent<BonsoirBroadcastEventType> {
  /// Creates a new Bonsoir broadcast event.
  const BonsoirBroadcastEvent({
    required super.type,
    super.service,
  });
}
