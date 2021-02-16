/// Flutter Week View, created by Skyost
/// Github : https://github.com/Skyost/Bonsoir

import 'dart:async';
import 'package:bonsoir_platform_interface/method_channel_bonsoir.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

typedef BonsoirPlatformInterface PlatformFactory(
    String classType, bool printArgs);

/// A Bonsoir class that allows to either broadcast a service or to discover services on the network.
abstract class BonsoirPlatformInterface extends PlatformInterface {
  /// The class identifier.
  static PlatformFactory _factory = (String classType, bool printLogs) =>
      MethodChannelBonsoir(classType: classType, printLogs: printLogs);

  static final Object _token = Object();

  static PlatformFactory get factory => _factory;

  static set factory(PlatformFactory factory) {
    try {
      var testInstance = factory('discovery', false);
      PlatformInterface.verifyToken(testInstance, _token);
      _factory = _factory;
    } catch (e) {
      if (!(e is AssertionError)) {
        print("Couldn't get a working factory?");
      }
      rethrow;
    }
  }

  /// The class type.
  final String classType;

  /// Whether to print logs.
  final bool printLogs;

  /// Creates a new Bonsoir class instance.
  BonsoirPlatformInterface({
    this.classType,
    this.printLogs,
  }) : super(token: _token);

  /// The event stream.
  /// Subscribe to it to receive this instance updates.
  Stream<dynamic> get eventStream {
    throw UnimplementedError('eventStream getter has not been implemented');
  }

  /// Await this method to know when the plugin will be ready.
  Future<void> ready(Map<String,dynamic> jsonBody) async {
    throw UnimplementedError('ready() has not been implemented');
  }

  /// Returns whether this instance can be used.
  bool get isReady {
    throw UnimplementedError('isReady has not been implemented');
  }

  /// Returns whether this instance has been stopped.
  bool get isStopped {
    throw UnimplementedError('isStopped has not been implemented');
  }

  /// Starts to do either a discover or a broadcast.
  Future<void> start() {
    throw UnimplementedError('start() has not been implemented');
  }

  /// Stops the current discover or broadcast.
  Future<void> stop() async {
    throw UnimplementedError('stop() has not been implemented');
  }

  /// Converts this Bonsoir class to a JSON map.
  Map<String, dynamic> toJson() {
    throw UnimplementedError('toJson() has not been implemented');
  }

  factory BonsoirPlatformInterface.fromArgs(
      {String classType, bool printLogs}) {
    return factory(classType, printLogs);
  }
}
