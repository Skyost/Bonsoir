import 'package:bonsoir/src/bonsoir_class.dart';
import 'package:bonsoir/src/broadcast/broadcast_event.dart';
import 'package:bonsoir/src/service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BonsoirBroadcast extends BonsoirClass<BonsoirBroadcastEvent> {
  final BonsoirService service;

  BonsoirBroadcast({
    bool printLogs = kDebugMode,
    @required this.service,
  }) : super(
          classType: 'broadcast',
          printLogs: printLogs,
        );

  @override
  BonsoirBroadcastEvent transformPlatformEvent(dynamic event) {
    Map<dynamic, dynamic> data = Map<String, dynamic>.from(event);
    String id = data['id'];
    return BonsoirBroadcastEvent(type: BonsoirBroadcastEventType.values.firstWhere((type) => type.name.toLowerCase() == id, orElse: () => BonsoirBroadcastEventType.UNKNOWN));
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    ...(serviceToJson(service)),
  };
}
