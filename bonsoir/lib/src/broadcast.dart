import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

/// Allows to broadcast a service on the network.
class BonsoirBroadcast {
  /// The service to broadcast.
  final BonsoirService service;

  /// The event source abstraction
  final BonsoirAction<BonsoirBroadcastEvent> _broadcastAction;

  /// Creates a new Bonsoir broadcast instance.
  BonsoirBroadcast({
    bool printLogs = kDebugMode,
    required this.service,
  }) : _broadcastAction = BonsoirPlatformInterface.instance.createBroadcast(service, printLogs: printLogs);

  /// The ready getter, that returns when the platform is ready for broadcast.
  Future<void> get ready async => _broadcastAction.ready;

  /// This returns whether the platform is ready for broadcast.
  bool get isReady => _broadcastAction.isReady;

  /// Returns whether the broadcast has been stopped.
  bool get isStopped => _broadcastAction.isStopped;

  /// Starts the broadcast.
  Future<void> start() => _broadcastAction.start();

  /// Stops the broadcast.
  Future<void> stop() => _broadcastAction.stop();

  /// Regular event stream.
  Stream<BonsoirBroadcastEvent>? get eventStream => _broadcastAction.eventStream;

  @protected
  Map<String, dynamic> toJson() => {
        ..._broadcastAction.toJson(),
        ...service.toJson(),
      };
}
