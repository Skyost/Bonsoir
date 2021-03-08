/// Flutter Week View, created by Skyost
/// Github : https://github.com/Skyost/Bonsoir

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:flutter/services.dart';

abstract class MethodChannelBonsoirEvents<T> extends BonsoirPlatformEvents<T> {
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
  Stream<T> _eventStream;

  /// Creates a new Bonsoir class instance.
  MethodChannelBonsoirEvents({
    @required String classType,
    this.printLogs,
  })  : _id = _createRandomId(),
        _classType = classType;

  /// The event stream.
  /// Subscribe to it to receive this instance updates.
  Stream<T> get eventStream => _eventStream;

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

class MethodChannelBroadcastEvents
    extends MethodChannelBonsoirEvents<BonsoirBroadcastEvent> {
  final BonsoirService service;
  BonsoirBroadcastEvent transformPlatformEvent(dynamic event) {
    Map<dynamic, dynamic> data = Map<String, dynamic>.from(event);
    return BonsoirBroadcastEvent.fromJson(data);
  }

  MethodChannelBroadcastEvents(this.service,{bool printLogs}): super(classType: 'broadcast', printLogs: printLogs);

  @override
  @protected
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    ...service.toJson(),
  };
}

class MethodChannelDiscoveryEvents
    extends MethodChannelBonsoirEvents<BonsoirDiscoveryEvent> {
  final String type;

  BonsoirDiscoveryEvent transformPlatformEvent(dynamic event) {
    Map<String, dynamic> data = Map<String, dynamic>.from(event);
    return BonsoirDiscoveryEvent.fromJson(data);
  }

  MethodChannelDiscoveryEvents(this.type, {bool printLogs}): super(classType: 'discovery', printLogs: printLogs);

  @override
  @protected
  Map<String, dynamic> toJson() => super.toJson()..['type'] = type;
}

/// A Bonsoir class that allows to either broadcast a service or to discover services on the network.
class MethodChannelBonsoir extends BonsoirPlatformInterface {
  @override
  BonsoirPlatformEvents<BonsoirBroadcastEvent> createBroadcast(
      BonsoirService service, {bool printLogs = kDebugMode}) {
    return MethodChannelBroadcastEvents(service,printLogs: printLogs);
  }

  @override
  BonsoirPlatformEvents<BonsoirDiscoveryEvent> createDiscovery(String type,{bool printLogs = kDebugMode}) {
    return MethodChannelDiscoveryEvents(type,printLogs: printLogs);
  }
}
