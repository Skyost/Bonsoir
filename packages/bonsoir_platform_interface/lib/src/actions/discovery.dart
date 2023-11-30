import 'package:bonsoir_platform_interface/src/actions/action.dart';
import 'package:bonsoir_platform_interface/src/events/discovery.dart';
import 'package:bonsoir_platform_interface/src/events/types/discovery.dart';
import 'package:bonsoir_platform_interface/src/service/service.dart';
import 'package:flutter/foundation.dart';

/// Implementation of [MethodChannelBonsoirEvents] for the discovery action.
class MethodChannelBonsoirDiscoveryAction extends MethodChannelBonsoirAction<BonsoirDiscoveryEvent> with ServiceResolver {
  /// The service type.
  final String type;

  /// Creates a new method channel action instance for the discovery action.
  MethodChannelBonsoirDiscoveryAction({
    required this.type,
    super.printLogs,
  }) : super(
          classType: 'discovery',
        );

  @override
  @protected
  BonsoirDiscoveryEvent transformPlatformEvent(dynamic event) {
    Map<String, dynamic> data = Map<String, dynamic>.from(event);
    return BonsoirDiscoveryEvent(
      type: BonsoirDiscoveryEventType.getById(data['id']),
      service: data.containsKey('service') ? BonsoirService.fromJson(Map<String, dynamic>.from(data['service'])) : null,
    );
  }

  @override
  @protected
  Map<String, dynamic> toJson() => super.toJson()..['type'] = type;

  @override
  Future<void> resolveService(BonsoirService service) => invokeMethod('resolveService', service.toJson(prefix: ''));
}
