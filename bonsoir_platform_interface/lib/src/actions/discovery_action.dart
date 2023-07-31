import 'package:bonsoir_platform_interface/src/actions/action.dart';
import 'package:bonsoir_platform_interface/src/events/discovery_event.dart';
import 'package:bonsoir_platform_interface/src/service/service.dart';
import 'package:flutter/foundation.dart';

/// Implementation of [MethodChannelBonsoirEvents] for the discovery action.
class MethodChannelBonsoirDiscoveryAction extends MethodChannelBonsoirAction<BonsoirDiscoveryEvent> with AutoStopBonsoirAction, ServiceResolver {
  /// The service type.
  final String type;

  /// Creates a new method channel action instance for the discovery action.
  MethodChannelBonsoirDiscoveryAction({
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

  @override
  Future<void> resolveService(BonsoirService service) => invokeMethod('resolveService', service.toJson(prefix: ''));
}
