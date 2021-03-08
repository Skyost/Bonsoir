import 'package:bonsoir/src/broadcast/broadcast_event.dart';
import 'package:bonsoir/src/service.dart';
import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

/// Allows to broadcast a service on the network.
class BonsoirBroadcast {
  /// The service to broadcast.
  final BonsoirService service;
  /// The event source abstraction
  final BonsoirPlatformEvents<BonsoirBroadcastEvent> _events;

  /// Creates a new Bonsoir broadcast instance.
  BonsoirBroadcast({
    bool printLogs = kDebugMode,
    required this.service,
  }) :_events = BonsoirPlatformInterface.instance
        .createBroadcast(service, printLogs: printLogs);

  /// The ready getter, that returns when the platform is ready for broadcast.
  Future<void> get ready async => _events.ready;

  /// This returns whether the platform is ready for broadcast.
  bool get isReady => _events.isReady;

  /// Returns whether the broadcast has been stopped.
  bool get isStopped => _events.isStopped;

  /// Starts the broadcast.
  Future<void> start() => _events.start();

  /// Stops the broadcast.
  Future<void> stop() => _events.stop();

  /// Regular event stream.
  Stream<BonsoirBroadcastEvent>? get eventStream => _events.eventStream;

  @protected
  Map<String, dynamic> toJson() => {
        ..._events.toJson(),
        ...service.toJson(),
      };
}
