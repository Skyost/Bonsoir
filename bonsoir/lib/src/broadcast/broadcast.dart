import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:bonsoir/src/broadcast/broadcast_event.dart';
import 'package:bonsoir/src/service.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

/// Allows to broadcast a service on the network.
class BonsoirBroadcast {
  /// The service to broadcast.
  final BonsoirService service;
  BonsoirPlatformInterface _interface;

  /// Creates a new Bonsoir broadcast instance.
  BonsoirBroadcast({
    bool printLogs = kDebugMode,
    @required this.service,
  }) {
    _interface = BonsoirPlatformInterface.fromArgs(
      classType: 'broadcast',
      printLogs: printLogs,
    );
  }

  static BonsoirBroadcastEvent transformPlatformEvent(dynamic event) {
    Map<dynamic, dynamic> data = Map<String, dynamic>.from(event);
    return BonsoirBroadcastEvent.fromJson(data);
  }

  Future<void> get ready async => _interface.ready(toJson());

  bool get isReady => _interface.isReady;

  bool get isStopped => _interface.isStopped;

  Future<void> start() => _interface.start();

  Future<void> stop() => _interface.stop();

  Stream<BonsoirBroadcastEvent> get eventStream =>
      _interface.eventStream.map(transformPlatformEvent);

  @protected
  Map<String, dynamic> toJson() => {
        ..._interface.toJson(),
        ...service.toJson(),
      };
}
