/// Flutter Week View, created by Skyost
/// Github : https://github.com/Skyost/Bonsoir

import 'dart:async';
import 'package:bonsoir_platform_interface/method_channel_bonsoir.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// This class serves as the stream source
/// for the implementations to override
abstract class BonsoirPlatformEvents<T> {
  /// Regular event stream
  Stream<T> get eventStream;
  /// The ready getter, that returns when the platform is
  /// ready for the operation requested.
  Future<void> get ready;
  /// This starts the required action (eg. Discovery, or Broadcast)
  Future<void> start();
  /// This stops the action (eg. stops discovery or broadcast)
  Future<void> stop();
  /// This returns whether the platform is ready for this event.
  bool get isReady;
  /// This returns whether the platform has discarded this event.
  bool get isStopped;
  /// This returns a JSON representation of the event.
  Map<String, dynamic> toJson();
}

/// A Bonsoir class that allows to either broadcast a service or to discover services on the network.
abstract class BonsoirPlatformInterface extends PlatformInterface {
  /// This object is needed to check
  /// if the platform instance registering is actually extending
  /// the platform interface (this class)
  static final Object _token = Object();

  /// Setting a default platform instance implementation.
  static BonsoirPlatformInterface _instance = MethodChannelBonsoir();

  /// Getter for better control
  static BonsoirPlatformInterface get instance => _instance;
  /// This function checks if the instance passed is extending this class
  static set instance(BonsoirPlatformInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  BonsoirPlatformInterface() : super(token: _token);

  /// This method returns an initialized subclass
  /// of BonsoirPlatformEvents holding the eventStreams and other
  /// state needed for the implementations.
  BonsoirPlatformEvents<BonsoirDiscoveryEvent> createDiscovery(String type, {bool printLogs = kDebugMode});

  BonsoirPlatformEvents<BonsoirBroadcastEvent> createBroadcast(BonsoirService service, {bool printLogs = kDebugMode});
}
