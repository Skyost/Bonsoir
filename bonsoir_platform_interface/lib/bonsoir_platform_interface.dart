/// Flutter Week View, created by Skyost
/// Github : https://github.com/Skyost/Bonsoir

export 'package:bonsoir_platform_interface/src/broadcast/broadcast.dart';
export 'package:bonsoir_platform_interface/src/broadcast/broadcast_event.dart';
export 'package:bonsoir_platform_interface/src/discovery/discovery.dart';
export 'package:bonsoir_platform_interface/src/discovery/discovery_event.dart';
export 'package:bonsoir_platform_interface/src/discovery/resolved_service.dart';
export 'package:bonsoir_platform_interface/src/service.dart';

import 'dart:async';
import 'dart:math';
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// A Bonsoir class that allows to either broadcast a service or to discover services on the network.
abstract class BonsoirPlatformInterface<T> extends PlatformInterface {
  /// The class identifier.
  final int _id;

  /// The class type.
  final String _classType;

  /// Whether to print logs.
  final bool printLogs;

  /// Whether this instance has been stopped.
  bool _isStopped = false;

  /// The current event stream.
  Stream<T> _eventStream;

  /// Creates a new Bonsoir class instance.
  BonsoirPlatformInterface({
    String classType,
    this.printLogs,
  })  : _id = _createRandomId(),
        _classType = classType;

  /// The event stream.
  /// Subscribe to it to receive this instance updates.
  Stream<T> get eventStream => _eventStream;

  /// Await this method to know when the plugin will be ready.
  Future<void> get ready async {
    throw UnimplementedError('ready() has not been implemented');
  }

  /// Returns whether this instance can be used.
  bool get isReady => _eventStream != null && !_isStopped;

  /// Returns whether this instance has been stopped.
  bool get isStopped => _isStopped;

  /// Starts to do either a discover or a broadcast.
  Future<void> start() {
    throw UnimplementedError('start() has not been implemented');
  }

  /// Stops the current discover or broadcast.
  Future<void> stop() async {
    throw UnimplementedError('stop() has not been implemented');
  }

  /// Transforms the stream data to a [T].
  @protected
  T transformPlatformEvent(dynamic event){
    throw UnimplementedError('transformPlatformEvent(event) has not been implemented');
  }

  /// Converts this Bonsoir class to a JSON map.
  @protected
  Map<String, dynamic> toJson() => {
    'id': _id,
    'printLogs': printLogs,
  };

  /// Allows to generate a random identifier.
  static int _createRandomId() => Random().nextInt(100000);
}
