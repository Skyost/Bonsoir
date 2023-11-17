import 'dart:async';

import 'package:bonsoir_linux/actions/discovery/discovery.dart';
import 'package:bonsoir_linux/avahi/constants.dart';
import 'package:bonsoir_linux/avahi/server.dart';
import 'package:bonsoir_linux/avahi/service_browser.dart';
import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:dbus/dbus.dart';

/// Uses older Avahi versions to discover a given service [type].
class AvahiDiscoveryLegacy extends AvahiBonsoirDiscovery {
  /// The Avahi server instance.
  late AvahiServer _server;

  /// Creates a new legacy Avahi discovery instance.
  AvahiDiscoveryLegacy({
    required String type,
    required bool printLogs,
  }) : super.internal(
    type: type,
    printLogs: printLogs,
  );

  @override
  Future<void> get ready async {
    _server = AvahiServer(busClient, 'org.freedesktop.Avahi', DBusObjectPath('/'));
  }

  @override
  Future<AvahiServiceBrowser> createAvahiServiceBrowser() async {
    String browserPath = await _server.callServiceBrowserNew(
      interface: AvahiIfIndexUnspecified,
      protocol: AvahiProtocolUnspecified,
      type: type,
      domain: '',
      flags: 0,
    );
    return AvahiServiceBrowser(busClient, 'org.freedesktop.Avahi', DBusObjectPath(browserPath));
  }

  @override
  Future<void> start() async {
    registerSubscription(
      'workaround_ItemNew',
      DBusSignalStream(
        busClient,
        sender: 'org.freedesktop.Avahi',
        interface: 'org.freedesktop.Avahi.ServiceBrowser',
        name: 'ItemNew',
      ).listen(onServiceFound),
    );
    registerSubscription(
      'workaround_ItemRemove',
      DBusSignalStream(
        busClient,
        sender: 'org.freedesktop.Avahi',
        interface: 'org.freedesktop.Avahi.ServiceBrowser',
        name: 'ItemRemove',
      ).listen(onServiceLost),
    );
    registerSubscription(
      'workaround_Failure',
      DBusSignalStream(
        busClient,
        sender: 'org.freedesktop.Avahi',
        interface: 'org.freedesktop.Avahi.ServiceResolver',
        name: 'Failure',
      ).listen(onServiceResolveFailure),
    );
    registerSubscription(
      'workaround_Found',
      DBusSignalStream(
        busClient,
        sender: 'org.freedesktop.Avahi',
        interface: 'org.freedesktop.Avahi.ServiceResolver',
        name: 'Found',
      ).listen(onServiceResolved),
    );
    await super.start();
  }

  @override
  Future<void> resolveServiceByEvent(BonsoirService service, AvahiServiceBrowserItemNew event) async {
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
