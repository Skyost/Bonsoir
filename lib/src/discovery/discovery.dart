import 'package:bonsoir/src/bonsoir_class.dart';
import 'package:bonsoir/src/discovery/discovery_event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Allows to run a network discovery.
class BonsoirDiscovery extends BonsoirClass<BonsoirDiscoveryEvent> {
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
