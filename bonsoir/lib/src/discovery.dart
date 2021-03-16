import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:flutter/foundation.dart';

/// Allows to run a network discovery.
class BonsoirDiscovery {
  /// The type of service to find.
  final String type;

  /// The event source abstraction.
  final BonsoirAction<BonsoirDiscoveryEvent> _discoveryAction;

  /// Creates a new Bonsoir discovery instance.
  BonsoirDiscovery({
    bool printLogs = kDebugMode,
    required this.type,
  }) : _discoveryAction = BonsoirPlatformInterface.instance.createDiscovery(type, printLogs: printLogs);

  /// The ready getter, that returns when the platform is ready for discovery.
  Future<void> get ready async => _discoveryAction.ready;

  /// This returns whether the platform is ready for discovery.
  bool get isReady => _discoveryAction.isReady;

  /// Returns whether the discovery has been stopped.
  bool get isStopped => _discoveryAction.isStopped;

  /// Starts the discovery.
  Future<void> start() => _discoveryAction.start();

  /// Stops the discovery.
  Future<void> stop() => _discoveryAction.stop();

  /// Regular event stream.
  Stream<BonsoirDiscoveryEvent>? get eventStream => _discoveryAction.eventStream;

  /// This returns a JSON representation of this discovery.
  Map<String, dynamic> toJson() => _discoveryAction.toJson()..['type'] = type;
}
