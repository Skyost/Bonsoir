import 'dart:async';

import 'package:bonsoir_linux/actions/action.dart';
import 'package:bonsoir_linux/actions/discovery/legacy.dart';
import 'package:bonsoir_linux/actions/discovery/v2.dart';
import 'package:bonsoir_linux/avahi/record_browser.dart';
import 'package:bonsoir_linux/avahi/server.dart';
import 'package:bonsoir_linux/avahi/service_browser.dart';
import 'package:bonsoir_linux/avahi/service_resolver.dart';
import 'package:bonsoir_linux/bonsoir_linux.dart';
import 'package:bonsoir_linux/error.dart';
import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:dbus/dbus.dart';

/// Allows to register subscriptions.
typedef SubscriptionRegisterer = Function(String name, StreamSubscription subscription);

/// Discovers a given service [type] on the network.
class AvahiBonsoirDiscovery extends AvahiBonsoirAction<BonsoirDiscoveryEvent> with ServiceResolver {
  /// The service type to discover.
  final String type;

  /// The service browser.
  AvahiServiceBrowser? _serviceBrowser;

  /// The Avahi handler instance.
  AvahiHandler? _avahiHandler;

  /// Contains all found services.
  final Map<BonsoirService, AvahiServiceBrowserItemNew> _foundServices = {};
  
  /// Contains all record browsers.
  final List<AvahiRecordBrowser> _recordBrowsers = [];

  /// Creates a new Avahi Bonsoir discovery instance.
  AvahiBonsoirDiscovery({
    required this.type,
    required super.printLogs,BonsoirService service
  }) : super(
          action: 'discovery',
        );

  @override
  Future<void> get ready async {
    if (_recordBrowser == null) {
      _avahiHandler = ((await _isModernAvahi) ? AvahiDiscoveryV2.new : AvahiDiscoveryLegacy.new)(busClient: busClient);
      _avahiHandler!.initialize();
      _serviceBrowser = AvahiServiceBrowser(busClient, AvahiBonsoir.avahi, DBusObjectPath(await _avahiHandler!.getAvahiServiceBrowserPath(type)));
    }
  }

  @override
  bool get isReady => super.isReady && _recordBrowser != null;

  @override
  Future<void> start() async {
    await super.start();
    List<StreamSubscription> subscriptions = await _avahiHandler!.getSubscriptions(this, _serviceBrowser!, _recordBrowser!);
    for (StreamSubscription subscription in subscriptions) {
      registerSubscription(subscription);
    }
    await _serviceBrowser!.callStart();
    onEvent(
      const BonsoirDiscoveryEvent(type: BonsoirDiscoveryEventType.discoveryStarted),
      'Bonsoir discovery started : $type',
    );
  }

  @override
  Future<void> resolveService(BonsoirService service) async {
    BonsoirService? serviceInstance = _findService(service.name, service.type);
    if (serviceInstance == null) {
      onError(AvahiBonsoirError('Trying to resolve an undiscovered service : ${service.name}', service.name));
      return;
    }
    _avahiHandler!.resolveService(this, serviceInstance, _foundServices[serviceInstance]!);
  }

  @override
  Future<void> stop() async {
    _serviceBrowser!.callFree();
    for (AvahiRecordBrowser recordBrowser in recordBrowsers) {
      _recordBrowser.callFree();
    }
    cancelSubscriptions();
    onEvent(
      const BonsoirDiscoveryEvent(type: BonsoirDiscoveryEventType.discoveryStopped),
      'Bonsoir discovery stopped : $type',
    );
    await super.stop();
  }

  /// Finds a service amongst found services.
  BonsoirService? _findService(String name, [String? type]) {
    for (MapEntry<BonsoirService, AvahiServiceBrowserItemNew> entry in _foundServices.entries) {
      if (entry.key.name == name && (type == null || entry.key.type == type)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Triggered when a service has been found.
  void onServiceFound(DBusSignal signal) {
    AvahiServiceBrowserItemNew event = AvahiServiceBrowserItemNew(signal);
    if (event.type != this.type) {
      return;
    }
    BonsoirService? service = _findService(event.serviceName, event.type);
    bool isNew = false;
    if (service == null) {
      service = BonsoirService(
        name: event.serviceName,
        type: event.type,
        port: 0,
      );
      isNew = true;
    }
    _foundServices[service] = event;
    if (isNew) {
      onEvent(
        BonsoirDiscoveryEvent(type: BonsoirDiscoveryEventType.discoveryServiceFound, service: service),
        'Bonsoir has found a service : ${service.description}',
      );
      AvahiRecordBrowser recordBrowser = AvahiRecordBrowser(busClient, AvahiBonsoir.avahi, DBusObjectPath(await _avahiHandler!.getAvahiRecordBrowserPath(type)));
      recordBrowser.callStart();
    }
  }

  /// Triggered when a service has been lost.
  void onServiceLost(DBusSignal signal) {
    AvahiServiceBrowserItemRemove event = AvahiServiceBrowserItemRemove(signal);
    if (event.type != this.type) {
      return;
    }
    BonsoirService? service = _findService(event.serviceName, event.type);
    if (service != null) {
      _foundServices.remove(service);
      onEvent(
        BonsoirDiscoveryEvent(type: BonsoirDiscoveryEventType.discoveryServiceLost, service: service),
        'A Bonsoir service has been lost : ${service.description}',
      );
    }
  }

  /// Triggered when a service has been resolved.
  void onServiceResolved(DBusSignal signal) {
    AvahiServiceResolverFound event = AvahiServiceResolverFound(signal);
    BonsoirService service = ResolvedBonsoirService(
      name: event.serviceName,
      type: event.type,
      host: event.address,
      port: event.port,
      attributes: Map.fromEntries(
        event.txt.map((entry) {
          int index = entry.indexOf('=');
          return MapEntry<String, String>(entry.substring(0, index), entry.substring(index + 1, entry.length));
        }),
      ),
    );
    onEvent(
      BonsoirDiscoveryEvent(type: BonsoirDiscoveryEventType.discoveryServiceResolved, service: service),
      'Bonsoir has resolved a service : $service',
    );
  }

  /// Triggered when Bonsoir has failed to resolve a service.
  void onServiceResolveFailure(DBusSignal signal) {
    AvahiServiceResolverFailure event = AvahiServiceResolverFailure(signal);
    onEvent(
      BonsoirDiscoveryEvent(type: BonsoirDiscoveryEventType.discoveryServiceResolveFailed),
      'Bonsoir has failed to resolve a service : ${event.error}',
    );
  }

  /// Triggered when a Bonsoir service TXT record has been found.
  void onServiceTXTRecordFound(DBusSignal signal) {
    AvahiRecordBrowserItemNew event = AvahiRecordBrowserItemNew(signal);
    // TODO: We need to handle this.
  }

  /// Returns whether the installed version of Avahi is > 0.7.
  Future<bool> get _isModernAvahi async {
    AvahiServer server = AvahiServer(DBusClient.system(), AvahiBonsoir.avahi, DBusObjectPath('/'));
    String version = (await server.callGetVersionString()).split(' ').last;
    int mayor = int.parse(version.split('.').first);
    int minor = int.parse(version.split('.').last);
    return minor > 7 && mayor >= 0;
  }
}

/// Handles communication with the Avahi daemon.
abstract class AvahiHandler {
  /// The DBus client.
  final DBusClient busClient;

  /// Creates a new Avahi handler instance.
  const AvahiHandler({
    required this.busClient,
  });

  /// Initializes the handler.
  void initialize();

  /// Creates the Avahi service browser path.
  Future<String> getAvahiServiceBrowserPath(String serviceType);

  /// Creates the Avahi record browser path.
  Future<String> getAvahiRecordBrowserPath(BonsoirService service);

  /// Returns the subscriptions.
  List<StreamSubscription> getSubscriptions(AvahiBonsoirDiscovery discovery, AvahiServiceBrowser serviceBrowser, AvahiRecordBrowser recordBrowser);

  /// Resolves a service using its event.
  Future<void> resolveService(AvahiBonsoirDiscovery discovery, BonsoirService service, AvahiServiceBrowserItemNew event);
}
