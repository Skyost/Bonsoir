import 'package:bonsoir_platform_interface/src/actions/action.dart';
import 'package:bonsoir_platform_interface/src/actions/broadcast.dart';
import 'package:bonsoir_platform_interface/src/actions/discovery.dart';
import 'package:bonsoir_platform_interface/src/events/broadcast.dart';
import 'package:bonsoir_platform_interface/src/events/discovery.dart';
import 'package:bonsoir_platform_interface/src/service/service.dart';
import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// A Bonsoir class that allows to either broadcast a service or to discover services on the network.
abstract class BonsoirPlatformInterface extends PlatformInterface {
  /// This object is needed to check if the platform instance registering is actually extending the platform interface (this class)
  static final Object _token = Object();

  /// Setting a default platform instance implementation.
  static BonsoirPlatformInterface _instance = MethodChannelBonsoir();

  /// Creates a new Bonsoir platform interface instance.
  BonsoirPlatformInterface() : super(token: _token);

  /// Getter for better control.
  static BonsoirPlatformInterface get instance => _instance;

  /// This function checks if the instance passed is extending this class.
  static set instance(BonsoirPlatformInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// This method returns an initialized subclass of [BonsoirAction] holding the eventStreams and other state needed for the implementations.
  BonsoirAction<BonsoirBroadcastEvent> createBroadcastAction(BonsoirService service, {bool printLogs = kDebugMode});

  /// This method returns an initialized subclass of [BonsoirAction] holding the eventStreams and other state needed for the implementations.
  BonsoirAction<BonsoirDiscoveryEvent> createDiscoveryAction(String type, {bool printLogs = kDebugMode});
}

/// A Bonsoir class that allows to either broadcast a service or to discover services on the network using a method channel.
class MethodChannelBonsoir extends BonsoirPlatformInterface {
  @override
  BonsoirAction<BonsoirBroadcastEvent> createBroadcastAction(BonsoirService service, {bool printLogs = kDebugMode}) => MethodChannelBonsoirBroadcastAction(service: service, printLogs: printLogs);

  @override
  BonsoirAction<BonsoirDiscoveryEvent> createDiscoveryAction(String type, {bool printLogs = kDebugMode}) => MethodChannelBonsoirDiscoveryAction(type: type, printLogs: printLogs);
}
