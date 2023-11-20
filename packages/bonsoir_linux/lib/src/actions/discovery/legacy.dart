import 'dart:async';

import 'package:bonsoir_linux/bonsoir_linux.dart';
import 'package:bonsoir_linux/src/actions/discovery/discovery.dart';
import 'package:bonsoir_linux/src/avahi/constants.dart';
import 'package:bonsoir_linux/src/avahi/record_browser.dart';
import 'package:bonsoir_linux/src/avahi/server.dart';
import 'package:bonsoir_linux/src/avahi/service_browser.dart';
import 'package:bonsoir_linux/src/service.dart';
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
    _server = AvahiServer(busClient, BonsoirLinux.avahi, DBusObjectPath('/'));
  }

  @override
  Future<String> getAvahiServiceBrowserPath(String serviceType) => _server.callServiceBrowserNew(
        interface: AvahiIfIndexUnspecified,
        protocol: AvahiProtocolUnspecified,
        type: serviceType,
        domain: '',
        flags: 0,
      );

  @override
  Future<AvahiRecordBrowser> createAvahiRecordBrowser(AvahiBonsoirDiscovery discovery, BonsoirService service) async {
    String recordBrowserPath = await _server.callRecordBrowserNew(
      AvahiIfIndexUnspecified,
      AvahiProtocolUnspecified,
      service.fqdn,
      0x01,
      0x10,
      0,
    );
    return AvahiRecordBrowser(busClient, BonsoirLinux.avahi, DBusObjectPath(recordBrowserPath));
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
