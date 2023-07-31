import 'package:bonsoir_platform_interface/src/actions/action.dart';
import 'package:bonsoir_platform_interface/src/events/broadcast_event.dart';
import 'package:bonsoir_platform_interface/src/service/service.dart';
import 'package:flutter/foundation.dart';

/// Implementation of [MethodChannelBonsoirEvents] for the broadcast action.
class MethodChannelBonsoirBroadcastAction extends MethodChannelBonsoirAction<BonsoirBroadcastEvent> with AutoStopBonsoirAction<BonsoirBroadcastEvent> {
  /// The Bonsoir service.
  final BonsoirService service;

  /// Creates a new method channel action instance for the broadcast action.
  MethodChannelBonsoirBroadcastAction({
    required this.service,
    bool printLogs = kDebugMode,
  }) : super(
          classType: 'broadcast',
          printLogs: printLogs,
        );

  /// Transforms a platform event to a broadcast event.
  @override
  @protected
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
