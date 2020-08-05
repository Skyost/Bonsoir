import 'dart:async';
import 'dart:math';

import 'package:bonsoir/src/discovery/discovered_service.dart';
import 'package:bonsoir/src/service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract class BonsoirClass<T> {
  static const String _channelName = 'fr.skyost.bonsoir';
  static const MethodChannel channel = const MethodChannel(_channelName);

  @protected
  final int _id;
  final String _classType;
  final bool printLogs;

  bool _isStopped = false;
  Stream<T> _eventStream;

  BonsoirClass({
    String classType,
    this.printLogs,
  })  : _id = _createRandomId(),
        _classType = classType;

  Stream<T> get eventStream => _eventStream;

  Future<void> get ready async {
    await channel.invokeMethod('$_classType.initialize', toJson());
    _eventStream = EventChannel('$_channelName.$_classType.$_id').receiveBroadcastStream().map(transformPlatformEvent);
  }

  bool get isReady => _eventStream != null && !_isStopped;

  bool get isStopped => _isStopped;

  Future<void> start() {
  	assert(isReady);
  	channel.invokeMethod('$_classType.start', toJson());
  }

  Future<void> stop() async {
    await channel.invokeMethod('$_classType.stop', toJson());
    _isStopped = true;
  }

  @protected
  T transformPlatformEvent(dynamic event);

  @protected
  Map<String, dynamic> toJson() => {
  	'id': _id,
  	'printLogs': printLogs,
  };

  @protected
  DiscoveredBonsoirService jsonToService(Map<String, dynamic> json) => DiscoveredBonsoirService.fromJson(
        json.map(
          (key, value) => MapEntry<String, dynamic>(
            key.startsWith('service.') ? key.substring('service.'.length) : key,
            value,
          ),
        ),
      );

  @protected
  Map<String, dynamic> serviceToJson(BonsoirService service) => service.toJson().map((key, value) => MapEntry<String, dynamic>('service.$key', value));

  static int _createRandomId() => Random().nextInt(100000);
}
