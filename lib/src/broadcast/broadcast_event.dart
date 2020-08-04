import 'package:flutter/material.dart';

class BonsoirBroadcastEvent {
  final BonsoirBroadcastEventType type;

  const BonsoirBroadcastEvent({
    @required this.type,
  });
}

enum BonsoirBroadcastEventType {
  BROADCAST_STARTED,
  BROADCAST_STOPPED,
  UNKNOWN,
}

extension BonsoirBroadcastEventTypeName on BonsoirBroadcastEventType {
  String get name => toString().split('.').last;
}