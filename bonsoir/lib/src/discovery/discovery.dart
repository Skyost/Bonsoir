import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:bonsoir/src/discovery/discovery_event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// Allows to run a network discovery.
class BonsoirDiscovery {
  /// The type of service to find.
  final String type;
  /// The event source abstraction
  BonsoirPlatformEvents<BonsoirDiscoveryEvent> _events;

  /// Creates a new Bonsoir discovery instance.
  BonsoirDiscovery({
    bool printLogs = kDebugMode,
    @required this.type,
  }) {
    _events = BonsoirPlatformInterface.instance
        .createDiscovery(type, printLogs: printLogs);
  }

  Future<void> get ready async => _events.ready;

  bool get isReady => _events.isReady;

  bool get isStopped => _events.isStopped;

  Future<void> start() => _events.start();

  Future<void> stop() => _events.stop();

  Stream<BonsoirDiscoveryEvent> get eventStream => _events.eventStream;

  Map<String, dynamic> toJson() => _events.toJson()..['type'] = type;
}
