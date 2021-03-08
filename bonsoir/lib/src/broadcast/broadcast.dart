import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:bonsoir/src/broadcast/broadcast_event.dart';
import 'package:bonsoir/src/service.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

/// Allows to broadcast a service on the network.
class BonsoirBroadcast {
  /// The service to broadcast.
  final BonsoirService service;
  /// The event source abstraction
  BonsoirPlatformEvents<BonsoirBroadcastEvent> _events;

  /// Creates a new Bonsoir broadcast instance.
  BonsoirBroadcast({
    bool printLogs = kDebugMode,
    @required this.service,
  }) {
    _events = BonsoirPlatformInterface.instance
        .createBroadcast(service, printLogs: printLogs);
  }

  Future<void> get ready async => _events.ready;

  bool get isReady => _events.isReady;

  bool get isStopped => _events.isStopped;

  Future<void> start() => _events.start();

  Future<void> stop() => _events.stop();

  Stream<BonsoirBroadcastEvent> get eventStream => _events.eventStream;

  @protected
  Map<String, dynamic> toJson() => {
        ..._events.toJson(),
        ...service.toJson(),
      };
}
