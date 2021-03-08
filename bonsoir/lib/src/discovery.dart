import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:bonsoir_platform_interface/events/discovery_event.dart';
import 'package:flutter/foundation.dart';

/// Allows to run a network discovery.
class BonsoirDiscovery {
  /// The type of service to find.
  final String type;

  /// The event source abstraction
  final BonsoirPlatformEvents<BonsoirDiscoveryEvent> _events;

  /// Creates a new Bonsoir discovery instance.
  BonsoirDiscovery({
    bool printLogs = kDebugMode,
    required this.type,
  }) : _events = BonsoirPlatformInterface.instance.createDiscovery(type, printLogs: printLogs);

  /// The ready getter, that returns when the platform is ready for discovery.
  Future<void> get ready async => _events.ready;

  /// This returns whether the platform is ready for discovery.
  bool get isReady => _events.isReady;

  /// Returns whether the discovery has been stopped.
  bool get isStopped => _events.isStopped;

  /// Starts the discovery.
  Future<void> start() => _events.start();

  /// Stops the discovery.
  Future<void> stop() => _events.stop();

  /// Regular event stream.
  Stream<BonsoirDiscoveryEvent>? get eventStream => _events.eventStream;

  /// This returns a JSON representation of this discovery.
  Map<String, dynamic> toJson() => _events.toJson()..['type'] = type;
}
