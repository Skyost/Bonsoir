import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:bonsoir/src/discovery/discovery_event.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

/// Allows to run a network discovery.
class BonsoirDiscovery {
  /// The type of service to find.
  final String type;
  BonsoirPlatformInterface _interface;

  /// Creates a new Bonsoir discovery instance.
  BonsoirDiscovery({
    bool printLogs = kDebugMode,
    @required this.type,
  }) {
    _interface = BonsoirPlatformInterface.fromArgs(
        classType: 'discovery', printLogs: printLogs);
  }

  static BonsoirDiscoveryEvent transformPlatformEvent(dynamic event) {
    Map<String, dynamic> data = Map<String, dynamic>.from(event);
    return BonsoirDiscoveryEvent.fromJson(data);
  }

  Future<void> get ready async => _interface.ready(toJson());

  bool get isReady => _interface.isReady;

  bool get isStopped => _interface.isStopped;

  Future<void> start() => _interface.start();

  Future<void> stop() => _interface.stop();

  Stream<BonsoirDiscoveryEvent> get eventStream =>
      _interface.eventStream.map(transformPlatformEvent);

  Map<String, dynamic> toJson() => _interface.toJson()..['type'] = type;
}
