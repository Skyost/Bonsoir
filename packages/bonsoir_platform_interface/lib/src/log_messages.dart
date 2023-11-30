import 'package:bonsoir_platform_interface/src/events/types/broadcast.dart';
import 'package:bonsoir_platform_interface/src/events/types/discovery.dart';

/// Contains a set of messages that can be logged by the native platform interface.
/// This ensure a consistency accross platforms.
class BonsoirPlatformInterfaceLogMessages {
  /// Contains all broadcast messages.
  static final Map<String, String> broadcastMessages = {
    BonsoirBroadcastEventType.broadcastStarted.id: 'Bonsoir service broadcast started : %s.',
    BonsoirBroadcastEventType.broadcastNameAlreadyExists.id: 'Trying to broadcast a service with a name that already exists : %s (old name was %s).',
    BonsoirBroadcastEventType.broadcastStopped.id: 'Bonsoir service broadcast stopped : %s.',
    'broadcastInitialized': 'Bonsoir service broadcast initialized : %s.',
    'broadcastError': 'Bonsoir service failed to broadcast : %s (error : %s).',
  };

  /// Contains all discovery messages.
  static final Map<String, String> discoveryMessages = {
    BonsoirDiscoveryEventType.discoveryStarted.id: 'Bonsoir discovery started : %s.',
    BonsoirDiscoveryEventType.discoveryServiceFound.id: 'Bonsoir has found a service : %s.',
    BonsoirDiscoveryEventType.discoveryServiceResolved.id: 'Bonsoir has resolved a service : %s.',
    BonsoirDiscoveryEventType.discoveryServiceResolveFailed.id: 'Bonsoir has failed to resolve a service : %s (error : %s).',
    BonsoirDiscoveryEventType.discoveryServiceLost.id: 'A Bonsoir service has been lost : %s.',
    BonsoirDiscoveryEventType.discoveryStopped.id: 'Bonsoir discovery stopped : %s.',
    'discoveryUndiscoveredServiceResolveFailed': 'Trying to resolve an undiscovered service : %s of type %s.',
    'discoveryTxtResolved': 'Bonsoir has found the attributes of a service : %s (new attributes are : %s).',
    'discoveryTxtResolveFailed': 'Bonsoir has failed to get the TXT record of a service : %s (error %s).',
    'discoveryError': 'Bonsoir has encountered an error during discovery : %s (error %s).',
  };
}
