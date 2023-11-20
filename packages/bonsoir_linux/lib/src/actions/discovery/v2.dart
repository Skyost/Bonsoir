import 'dart:async';

import 'package:bonsoir_linux/bonsoir_linux.dart';
import 'package:bonsoir_linux/src/actions/discovery/discovery.dart';
import 'package:bonsoir_linux/src/avahi/constants.dart';
import 'package:bonsoir_linux/src/avahi/record_browser.dart';
import 'package:bonsoir_linux/src/avahi/server2.dart';
import 'package:bonsoir_linux/src/avahi/service_browser.dart';
import 'package:bonsoir_linux/src/avahi/service_resolver.dart';
import 'package:bonsoir_linux/src/service.dart';
import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:dbus/dbus.dart';

/// Uses newer Avahi versions to discover a given service [type].
class AvahiDiscoveryV2 extends AvahiHandler {
  /// The Avahi server instance.
  late final AvahiServer2 _server;

  /// Creates a new Avahi discovery v2 instance.
  AvahiDiscoveryV2({
    required super.busClient,
  });

  @override
  void initialize() {
    _server = AvahiServer2(busClient, BonsoirLinux.avahi, DBusObjectPath('/'));
  }

  @override
  Future<String> getAvahiServiceBrowserPath(String serviceType) => _server.callServiceBrowserPrepare(
        AvahiIfIndexUnspecified,
        AvahiProtocolUnspecified,
        serviceType,
        '',
        0,
      );

  @override
  Future<AvahiRecordBrowser> createAvahiRecordBrowser(AvahiBonsoirDiscovery discovery, BonsoirService service) async {
    String recordBrowserPath = await _server.callRecordBrowserPrepare(
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
    String serviceResolverPath = await _server.callServiceResolverPrepare(
      event.interfaceValue,
      event.protocol,
      event.serviceName,
      event.type,
      event.domain,
      AvahiProtocolUnspecified,
      0,
    );
    AvahiServiceResolver resolver = AvahiServiceResolver(busClient, BonsoirLinux.avahi, DBusObjectPath(serviceResolverPath));
    resolver.callStart();
  }
}
