/// Flutter Week View, created by Skyost
/// Github : https://github.com/Skyost/Bonsoir

import 'dart:async';
import 'dart:math';

import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:flutter/services.dart';

/// A Bonsoir class that allows to either broadcast a service or to discover services on the network.
class MethodChannelBonsoir extends BonsoirPlatformInterface {
  /// The channel name.
  static const String _channelName = 'fr.skyost.bonsoir';

  /// The channel.
  static const MethodChannel channel = MethodChannel(_channelName);

  /// The class identifier.
  final int _id;

  /// Whether this instance has been stopped.
  bool _isStopped = false;

  /// The current event stream.
  Stream<dynamic> _eventStream;

  // All of the body request;
  Map<String, dynamic> _cachedBody;
  /// Creates a new Bonsoir class instance.
  MethodChannelBonsoir({String classType, bool printLogs})
      : _id = _createRandomId(),
        super(classType: classType, printLogs: printLogs);

  /// Await this method to know when the plugin will be ready.
  Future<void> ready(Map<String,dynamic> jsonBody) async {
    _cachedBody = jsonBody;
    await channel.invokeMethod('$classType.initialize', _cachedBody);
    _eventStream =
        EventChannel('$_channelName.$classType.$_id').receiveBroadcastStream();
  }

  /// Returns whether this instance can be used.
  @override
  bool get isReady => _eventStream != null && !_isStopped;

  /// Returns whether this instance has been stopped.
  bool get isStopped => _isStopped;

  /// Starts to do either a discover or a broadcast.
  Future<void> start() {
    assert(isReady,
        '''$runtimeType should be ready to start in order to call this method.
You must wait until this instance is ready by calling "await $runtimeType.ready".
If you have previously called "$runtimeType.stop()" on this instance, you have to create a new instance of this class.''');
    return channel.invokeMethod('$classType.start', _cachedBody);
  }

  /// Stops the current discover or broadcast.
  Future<void> stop() async {
    await channel.invokeMethod('$classType.stop', _cachedBody);
    _isStopped = true;
  }

  /// Converts this Bonsoir class to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': _id,
        'printLogs': printLogs,
      };

  /// Allows to generate a random identifier.
  static int _createRandomId() => Random().nextInt(100000);

  @override
  Stream get eventStream => _eventStream;
}
