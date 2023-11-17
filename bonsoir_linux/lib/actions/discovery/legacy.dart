import 'dart:async';

import 'package:bonsoir_linux/actions/discovery/discovery.dart';
import 'package:bonsoir_linux/avahi/constants.dart';
import 'package:bonsoir_linux/avahi/record_browser.dart';
import 'package:bonsoir_linux/avahi/server.dart';
import 'package:bonsoir_linux/avahi/service_browser.dart';
import 'package:bonsoir_linux/bonsoir_linux.dart';
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
    _server = AvahiServer(busClient, AvahiBonsoir.avahi, DBusObjectPath('/'));
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
    return AvahiRecordBrowser(busClient, AvahiBonsoir.avahi, DBusObjectPath(recordBrowserPath));
  }

  @override
  List<StreamSubscription> getSubscriptions(AvahiBonsoirDiscovery discovery, AvahiServiceBrowser serviceBrowser) => [
        DBusSignalStream(
          busClient,
          sender: AvahiBonsoir.avahi,
          interface: '${AvahiBonsoir.avahi}.ServiceBrowser',
          name: 'ItemNew',
        ).listen(discovery.onServiceFound),
        DBusSignalStream(
          busClient,
          sender: AvahiBonsoir.avahi,
          interface: '${AvahiBonsoir.avahi}.ServiceBrowser',
          name: 'ItemRemove',
        ).listen(discovery.onServiceLost),
        DBusSignalStream(
          busClient,
          sender: AvahiBonsoir.avahi,
          interface: '${AvahiBonsoir.avahi}.ServiceResolver',
          name: 'Failure',
        ).listen(discovery.onServiceResolveFailure),
        DBusSignalStream(
          busClient,
          sender: AvahiBonsoir.avahi,
          interface: '${AvahiBonsoir.avahi}.ServiceResolver',
          name: 'Found',
        ).listen(discovery.onServiceResolved),
        DBusSignalStream(
          busClient,
          sender: AvahiBonsoir.avahi,
          interface: '${AvahiBonsoir.avahi}.RecordBrowser',
          name: 'ItemNew',
        ).listen(discovery.onServiceTXTRecordFound),
      ];

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
