import 'package:bonsoir_platform_interface/src/events/event.dart';
import 'package:bonsoir_platform_interface/src/events/types/discovery.dart';

/// A Bonsoir discovery event.
class BonsoirDiscoveryEvent extends BonsoirEvent<BonsoirDiscoveryEventType> {
  /// Creates a new Bonsoir discovery event.
  const BonsoirDiscoveryEvent({
    required super.type,
    super.service,
  });
}
