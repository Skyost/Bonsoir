import 'package:bonsoir_platform_interface/src/events/broadcast.dart';
import 'package:bonsoir_platform_interface/src/events/discovery.dart';

/// Contains a set of messages that can be logged by the native platform interface.
/// This ensure a consistency across platforms.
class BonsoirPlatformInterfaceLogMessages {
  /// Contains all broadcast messages.
  static final Map<String, String> broadcastMessages = {
    BonsoirBroadcastStartedEvent.broadcastStarted: 'Bonsoir service broadcast started : %s.',
    BonsoirBroadcastNameAlreadyExistsEvent.broadcastNameAlreadyExists: 'Trying to broadcast a service with a name that already exists : %s (old name was %s).',
    BonsoirBroadcastStoppedEvent.broadcastStopped: 'Bonsoir service broadcast stopped : %s.',
    'broadcastInitialized': 'Bonsoir service broadcast initialized : %s.',
    'broadcastError': 'Bonsoir service failed to broadcast : %s (error : %s).',
  };

  /// Contains all discovery messages.
  static final Map<String, String> discoveryMessages = {
    BonsoirDiscoveryStartedEvent.discoveryStarted: 'Bonsoir discovery started : %s.',
    BonsoirDiscoveryServiceFoundEvent.discoveryServiceFound: 'Bonsoir has found a service : %s.',
    BonsoirDiscoveryServiceResolvedEvent.discoveryServiceResolved: 'Bonsoir has resolved a service : %s.',
    BonsoirDiscoveryServiceUpdatedEvent.discoveryServiceUpdated: 'A Bonsoir service has been updated : %s.',
    BonsoirDiscoveryServiceResolveFailedEvent.discoveryServiceResolveFailed: 'Bonsoir has failed to resolve a service : %s (error : %s).',
    BonsoirDiscoveryServiceLostEvent.discoveryServiceLost: 'A Bonsoir service has been lost : %s.',
    BonsoirDiscoveryStoppedEvent.discoveryStopped: 'Bonsoir discovery stopped : %s.',
    'discoveryUndiscoveredServiceResolveFailed': 'Trying to resolve an undiscovered service : %s of type %s.',
    'discoveryTxtResolved': 'Bonsoir has found the attributes of a service : %s (new attributes are : %s).',
    'discoveryTxtResolveFailed': 'Bonsoir has failed to get the TXT record of a service : %s (error %s).',
    'discoveryError': 'Bonsoir has encountered an error during discovery : %s (error %s).',
  };
}
