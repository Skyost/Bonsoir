import 'dart:math';

import 'package:bonsoir_platform_interface/src/events/event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// This class serves as the stream source for the implementations to override.
abstract class BonsoirAction<T extends BonsoirEvent> {
  /// Regular event stream.
  Stream<T>? get eventStream;

  /// The ready getter, that returns when the platform is ready for the operation requested.
  Future<void> get ready;

  /// This starts the required action (eg. Discovery, or Broadcast).
  Future<void> start();

  /// This stops the action (eg. stops discovery or broadcast).
  Future<void> stop();

  /// This returns whether the platform is ready for this event.
  bool get isReady;

  /// This returns whether the platform has discarded this event.
  bool get isStopped;

  /// This returns a JSON representation of the event.
  Map<String, dynamic> toJson();
}

/// Abstract class that contains all methods that are communicating with the native side of the plugin.
abstract class MethodChannelBonsoirAction<T extends BonsoirEvent>
    extends BonsoirAction<T> {
  /// The channel name.
  static const String _channelName = 'fr.skyost.bonsoir';

  /// The channel.
  static const MethodChannel channel = MethodChannel(_channelName);

  /// The class identifier.
  final int _id;

  /// The class type.
  final String _classType;

  /// Whether to print logs.
  final bool printLogs;

  /// Whether this instance has been stopped.
  bool _isStopped = false;

  /// The current event stream.
  Stream<T>? _eventStream;

  /// Creates a new Bonsoir class instance.
  MethodChannelBonsoirAction({
    required String classType,
    this.printLogs = kDebugMode,
  })  : _id = _createRandomId(),
        _classType = classType;

  /// The event stream.
  /// Subscribe to it to receive this instance updates.
  Stream<T>? get eventStream => _eventStream;

  /// Await this method to know when the plugin will be ready.
  Future<void> get ready async {
    await channel.invokeMethod('$_classType.initialize', toJson());
    _eventStream = EventChannel('$_channelName.$_classType.$_id')
        .receiveBroadcastStream()
        .map(transformPlatformEvent);
  }

  /// Returns whether this instance can be used.
  bool get isReady => _eventStream != null && !_isStopped;

  /// Returns whether this instance has been stopped.
  bool get isStopped => _isStopped;

  /// Starts to do either a discover or a broadcast.
  Future<void> start() {
    assert(isReady,
        '''$runtimeType should be ready to start in order to call this method.
You must wait until this instance is ready by calling "await $runtimeType.ready".
If you have previously called "$runtimeType.stop()" on this instance, you have to create a new instance of this class.''');
    return channel.invokeMethod('$_classType.start', toJson());
  }

  /// Stops the current discover or broadcast.
  Future<void> stop() async {
    await channel.invokeMethod('$_classType.stop', toJson());
    _isStopped = true;
  }

  /// Transforms the stream data to a [T].
  @protected
  T transformPlatformEvent(dynamic event);

  /// Converts this Bonsoir class to a JSON map.
  @protected
  Map<String, dynamic> toJson() => {
        'id': _id,
        'printLogs': printLogs,
      };

  /// Allows to generate a random identifier.
  static int _createRandomId() => Random().nextInt(100000);
}
