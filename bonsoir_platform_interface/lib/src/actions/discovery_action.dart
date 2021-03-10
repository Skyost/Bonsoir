import 'package:bonsoir_platform_interface/src/actions/action.dart';
import 'package:bonsoir_platform_interface/src/events/discovery_event.dart';
import 'package:flutter/foundation.dart';

/// Implementation of [MethodChannelBonsoirEvents] for the discovery action.
class BonsoirDiscoveryAction extends MethodChannelBonsoirAction<BonsoirDiscoveryEvent> {
  /// The service type.
  final String type;

  /// Creates a new method channel action instance for the discovery action.
  BonsoirDiscoveryAction({
    required this.type,
    bool printLogs = kDebugMode,
  }) : super(
          classType: 'discovery',
          printLogs: printLogs,
        );

  /// Transforms a platform event to a discovery event.
  @override
  @protected
  BonsoirDiscoveryEvent transformPlatformEvent(dynamic event) {
    Map<String, dynamic> data = Map<String, dynamic>.from(event);
    return BonsoirDiscoveryEvent.fromJson(data);
  }

  @override
  @protected
  Map<String, dynamic> toJson() => super.toJson()..['type'] = type;
}
