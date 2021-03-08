import 'dart:async';
import 'dart:math';

import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:bonsoir_platform_interface/events/broadcast_event.dart';
import 'package:bonsoir_platform_interface/events/discovery_event.dart';
import 'package:bonsoir_platform_interface/service/service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

/// Abstract class that contains all methods that are communicating with the native side of the plugin.
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
  Stream<T>? _eventStream;

  /// Creates a new Bonsoir class instance.
  MethodChannelBonsoirEvents({
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
    _eventStream = EventChannel('$_channelName.$_classType.$_id').receiveBroadcastStream().map(transformPlatformEvent);
  }

  /// Returns whether this instance can be used.
  bool get isReady => _eventStream != null && !_isStopped;

  /// Returns whether this instance has been stopped.
  bool get isStopped => _isStopped;

  /// Starts to do either a discover or a broadcast.
  Future<void> start() {
    assert(isReady, '''$runtimeType should be ready to start in order to call this method.
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

/// Implementation of [MethodChannelBonsoirEvents] for broadcast events.
class MethodChannelBroadcastEvents extends MethodChannelBonsoirEvents<BonsoirBroadcastEvent> {
  /// The Bonsoir service.
  final BonsoirService service;

  /// Creates a new method channel instance for broadcast events.
  MethodChannelBroadcastEvents({
    required this.service,
    bool printLogs = kDebugMode,
  }) : super(
          classType: 'broadcast',
          printLogs: printLogs,
        );

  /// Transforms a platform event to a broadcast event.
  BonsoirBroadcastEvent transformPlatformEvent(dynamic event) {
    Map<String, dynamic> data = Map<String, dynamic>.from(event);
    return BonsoirBroadcastEvent.fromJson(data);
  }

  @override
  @protected
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ...service.toJson(),
      };
}

/// Implementation of [MethodChannelBonsoirEvents] for discovery events.
class MethodChannelDiscoveryEvents extends MethodChannelBonsoirEvents<BonsoirDiscoveryEvent> {
  /// The service type.
  final String type;

  /// Creates a new method channel instance for discovery events.
  MethodChannelDiscoveryEvents({
    required this.type,
    bool printLogs = kDebugMode,
  }) : super(
          classType: 'discovery',
          printLogs: printLogs,
        );

  /// Transforms a platform event to a discovery event.
  BonsoirDiscoveryEvent transformPlatformEvent(dynamic event) {
    Map<String, dynamic> data = Map<String, dynamic>.from(event);
    return BonsoirDiscoveryEvent.fromJson(data);
  }

  @override
  @protected
  Map<String, dynamic> toJson() => super.toJson()..['type'] = type;
}

/// A Bonsoir class that allows to either broadcast a service or to discover services on the network.
class MethodChannelBonsoir extends BonsoirPlatformInterface {
  @override
  BonsoirPlatformEvents<BonsoirBroadcastEvent> createBroadcast(BonsoirService service, {bool printLogs = kDebugMode}) {
    return MethodChannelBroadcastEvents(service: service, printLogs: printLogs);
  }

  @override
  BonsoirPlatformEvents<BonsoirDiscoveryEvent> createDiscovery(String type, {bool printLogs = kDebugMode}) {
    return MethodChannelDiscoveryEvents(type: type, printLogs: printLogs);
  }
}
