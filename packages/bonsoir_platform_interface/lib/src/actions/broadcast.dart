import 'package:bonsoir_platform_interface/src/actions/action.dart';
import 'package:bonsoir_platform_interface/src/events/broadcast.dart';
import 'package:bonsoir_platform_interface/src/events/types/broadcast.dart';
import 'package:bonsoir_platform_interface/src/service/service.dart';
import 'package:flutter/foundation.dart';

/// Implementation of [MethodChannelBonsoirEvents] for the broadcast action.
class MethodChannelBonsoirBroadcastAction extends MethodChannelBonsoirAction<BonsoirBroadcastEvent> {
  /// The Bonsoir service.
  final BonsoirService service;

  /// Creates a new method channel action instance for the broadcast action.
  MethodChannelBonsoirBroadcastAction({
    required this.service,
    super.printLogs,
  }) : super(
          classType: 'broadcast',
        );

  @override
  @protected
  BonsoirBroadcastEvent transformPlatformEvent(dynamic event) {
    Map<String, dynamic> data = Map<String, dynamic>.from(event);
    return BonsoirBroadcastEvent(
      type: BonsoirBroadcastEventType.getById(data['id']),
      service: data.containsKey('service') ? BonsoirService.fromJson(Map<String, dynamic>.from(data['service'])) : null,
    );
  }

  @override
  @protected
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ...service.toJson(),
      };
}
