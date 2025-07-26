import 'package:bonsoir_platform_interface/src/service/service.dart';

/// Represents a Bonsoir event.
abstract class BonsoirEvent {
  /// The event id.
  final String? id;

  /// The service (if any).
  final BonsoirService? service;

  /// The Bonsoir event type.
  const BonsoirEvent({
    this.id,
    this.service,
  });
}
