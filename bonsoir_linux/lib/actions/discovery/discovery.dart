import 'dart:async';

import 'package:bonsoir_linux/actions/action.dart';
import 'package:bonsoir_linux/actions/discovery/legacy.dart';
import 'package:bonsoir_linux/actions/discovery/v2.dart';
import 'package:bonsoir_linux/avahi/service_browser.dart';
import 'package:bonsoir_linux/avahi/service_resolver.dart';
import 'package:bonsoir_linux/bonsoir_linux.dart';
import 'package:bonsoir_linux/error.dart';
import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart';

/// Discovers a given service [type] on the network.
abstract class AvahiBonsoirDiscovery extends AvahiBonsoirAction<BonsoirDiscoveryEvent> with ServiceResolver {
  /// The service type to discover.
  final String type;

  /// The service browser.
  late final AvahiServiceBrowser browser;

  /// Contains all found services.
  final Map<BonsoirService, AvahiServiceBrowserItemNew> _foundServices = {};

  /// Creates a new Avahi Bonsoir discovery instance.
  @protected
  AvahiBonsoirDiscovery.internal({
    required this.type,
    required super.printLogs,
  }) : super(
          action: 'discovery',
        );

  /// Creates an Avahi Bonsoir discovery instance.
  factory AvahiBonsoirDiscovery({
    required String type,
    required bool printLogs,
    bool legacy = false,
  }) =>
      legacy
          ? AvahiDiscoveryLegacy(
              type: type,
              printLogs: printLogs,
            )
          : AvahiDiscoveryV2(
              type: type,
              printLogs: printLogs,
            );

  @override
  Future<void> get ready async => browser = await createAvahiServiceBrowser();

  @override
  Future<void> start() async {
    await browser.callStart();
    onEvent(
      const BonsoirDiscoveryEvent(type: BonsoirDiscoveryEventType.discoveryStarted),
      'Bonsoir discovery started : $type',
    );
  }

  @override
  Future<void> resolveService(BonsoirService service) async {
    BonsoirService? serviceInstance = findService(service.name, service.type);
    if (serviceInstance == null) {
      onError(AvahiBonsoirError('Trying to resolve an undiscovered service : ${service.name}', service.name));
      return;
    }
    resolveServiceByEvent(serviceInstance, _foundServices[serviceInstance]!);
  }

  @override
  Future<void> stop() async {
    browser.callFree();
    cancelSubscriptions();
    onEvent(
      const BonsoirDiscoveryEvent(type: BonsoirDiscoveryEventType.discoveryStopped),
      'Bonsoir discovery stopped : $type',
    );
    await super.stop();
  }

  /// Creates the Avahi service browser.
  @protected
  Future<AvahiServiceBrowser> createAvahiServiceBrowser();

  /// Finds a service amongst found services.
  BonsoirService? findService(String name, [String? type]) {
    for (MapEntry<BonsoirService, AvahiServiceBrowserItemNew> entry in _foundServices.entries) {
      if (entry.key.name == name && (type == null || entry.key.type == type)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Triggered when a service has been found.
  @protected
  void onServiceFound(DBusSignal signal) {
    AvahiServiceBrowserItemNew event = AvahiServiceBrowserItemNew(signal);
    if (event.type != this.type) {
      return;
    }
    BonsoirService service = BonsoirService(
      name: event.name,
      type: event.type,
      port: 0,
    );
    _foundServices[service] = event;
    // TODO: Handle attributes.
    onEvent(
      BonsoirDiscoveryEvent(type: BonsoirDiscoveryEventType.discoveryServiceFound, service: service),
      'Bonsoir has found a service : ${service.description}',
    );
  }

  /// Triggered when a service has been lost.
  @protected
  void onServiceLost(DBusSignal signal) {
    AvahiServiceBrowserItemRemove event = AvahiServiceBrowserItemRemove(signal);
    if (event.type != this.type) {
      return;
    }
    BonsoirService? service = findService(event.name, event.type);
    if (service != null) {
      _foundServices.remove(service);
      onEvent(
        BonsoirDiscoveryEvent(type: BonsoirDiscoveryEventType.discoveryServiceLost, service: service),
        'A Bonsoir service has been lost : ${service.description}',
      );
    }
  }

  /// Triggered when a service has been resolved.
  @protected
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
          return MapEntry<String, String>(entry.substring(0, index), entry.substring(index, entry.length));
        }),
      ),
    );
    onEvent(
      BonsoirDiscoveryEvent(type: BonsoirDiscoveryEventType.discoveryServiceResolved, service: service),
      'Bonsoir has resolved a service : $service',
    );
  }

  /// Triggered when Bonsoir has failed to resolve a service.
  @protected
  void onServiceResolveFailure(DBusSignal signal) {
    BonsoirService? service = findService(signal.name);
    if (service == null) {
      return;
    }

    AvahiServiceResolverFailure event = AvahiServiceResolverFailure(signal);
    onEvent(
      BonsoirDiscoveryEvent(type: BonsoirDiscoveryEventType.discoveryServiceResolveFailed, service: service),
      'Bonsoir has failed to resolve a service : ${event.error}',
    );
  }

  /// Resolves a service using its event.
  @protected
  Future<void> resolveServiceByEvent(BonsoirService service, AvahiServiceBrowserItemNew event);
}
