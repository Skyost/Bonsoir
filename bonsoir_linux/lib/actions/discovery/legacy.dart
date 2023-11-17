import 'dart:async';

import 'package:bonsoir_linux/actions/discovery/discovery.dart';
import 'package:bonsoir_linux/avahi/constants.dart';
import 'package:bonsoir_linux/avahi/server.dart';
import 'package:bonsoir_linux/avahi/service_browser.dart';
import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:dbus/dbus.dart';

/// Uses older Avahi versions to discover a given service [type].
class AvahiDiscoveryLegacy extends AvahiHandler {
  /// The Avahi server instance.
  late AvahiServer _server;

  /// Creates a new legacy Avahi discovery instance.
  AvahiDiscoveryLegacy({
    required super.busClient,
  });

  @override
  void initialize() {
    _server = AvahiServer(busClient, 'org.freedesktop.Avahi', DBusObjectPath('/'));
  }

  @override
  Future<AvahiServiceBrowser> createAvahiServiceBrowser(String serviceType) async {
    String browserPath = await _server.callServiceBrowserNew(
      interface: AvahiIfIndexUnspecified,
      protocol: AvahiProtocolUnspecified,
      type: serviceType,
      domain: '',
      flags: 0,
    );
    return AvahiServiceBrowser(busClient, 'org.freedesktop.Avahi', DBusObjectPath(browserPath));
  }

  @override
  Future<void> registerSubscriptions(AvahiBonsoirDiscovery discovery, AvahiServiceBrowser browser) async {
    discovery.registerSubscription(
      'workaround_ItemNew',
      DBusSignalStream(
        busClient,
        sender: 'org.freedesktop.Avahi',
        interface: 'org.freedesktop.Avahi.ServiceBrowser',
        name: 'ItemNew',
      ).listen(discovery.onServiceFound),
    );
    discovery.registerSubscription(
      'workaround_ItemRemove',
      DBusSignalStream(
        busClient,
        sender: 'org.freedesktop.Avahi',
        interface: 'org.freedesktop.Avahi.ServiceBrowser',
        name: 'ItemRemove',
      ).listen(discovery.onServiceLost),
    );
    discovery.registerSubscription(
      'workaround_Failure',
      DBusSignalStream(
        busClient,
        sender: 'org.freedesktop.Avahi',
        interface: 'org.freedesktop.Avahi.ServiceResolver',
        name: 'Failure',
      ).listen(discovery.onServiceResolveFailure),
    );
    discovery.registerSubscription(
      'workaround_Found',
      DBusSignalStream(
        busClient,
        sender: 'org.freedesktop.Avahi',
        interface: 'org.freedesktop.Avahi.ServiceResolver',
        name: 'Found',
      ).listen(discovery.onServiceResolved),
    );
  }

  @override
  Future<void> resolveService(AvahiBonsoirDiscovery discovery, BonsoirService service, AvahiServiceBrowserItemNew event) async {
    await _server.callServiceResolverNew(
      interface: event.interfaceValue,
      protocol: event.protocol,
      name: event.serviceName,
      type: event.type,
      domain: event.domain,
      aprotocol: AvahiProtocolUnspecified,
      flags: 0,
    );
  }
}
