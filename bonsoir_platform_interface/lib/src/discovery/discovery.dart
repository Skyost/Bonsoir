import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:bonsoir_platform_interface/src/discovery/discovery_event.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

/// Allows to run a network discovery.
class BonsoirDiscovery extends BonsoirPlatformInterface<BonsoirDiscoveryEvent> {
  /// The type of service to find.
  final String type;

  /// Creates a new Bonsoir discovery instance.
  BonsoirDiscovery({
    bool printLogs = kDebugMode,
    @required this.type,
  }) : super(
          classType: 'discovery',
          printLogs: printLogs,
        );

  @override
  @protected
  BonsoirDiscoveryEvent transformPlatformEvent(dynamic event) {
    Map<String, dynamic> data = Map<String, dynamic>.from(event);
    return BonsoirDiscoveryEvent.fromJson(data);
  }

  @override
  @protected
  Map<String, dynamic> toJson() => super.toJson()..['type'] = type;
}
