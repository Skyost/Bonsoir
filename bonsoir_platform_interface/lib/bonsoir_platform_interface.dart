/// Flutter Week View, created by Skyost
/// Github : https://github.com/Skyost/Bonsoir

import 'dart:async';
import 'package:bonsoir_platform_interface/method_channel_bonsoir.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class BonsoirPlatformEvents<T> {
  Stream<T> get eventStream;

  Future<void> get ready;

  Future<void> start();

  Future<void> stop();

  bool get isReady;

  bool get isStopped;

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
    _instance = _instance;
  }

  BonsoirPlatformInterface() : super(token: _token);

  /// This method returns an initialized subclass
  /// of BonsoirPlatformEvents holding the eventStreams and other
  /// state needed for the implementations.
  BonsoirPlatformEvents<BonsoirDiscoveryEvent> createDiscovery(String type, {bool printLogs = kDebugMode});

  BonsoirPlatformEvents<BonsoirBroadcastEvent> createBroadcast(BonsoirService service, {bool printLogs = kDebugMode});
}
