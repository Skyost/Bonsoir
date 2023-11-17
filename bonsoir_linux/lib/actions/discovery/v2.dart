import 'dart:async';

import 'package:bonsoir_linux/actions/discovery/discovery.dart';
import 'package:bonsoir_linux/avahi/constants.dart';
import 'package:bonsoir_linux/avahi/server2.dart';
import 'package:bonsoir_linux/avahi/service_browser.dart';
import 'package:bonsoir_linux/avahi/service_resolver.dart';
import 'package:bonsoir_linux/bonsoir_linux.dart';
import 'package:bonsoir_linux/error.dart';
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
    _server = AvahiServer2(busClient, 'org.freedesktop.Avahi', DBusObjectPath('/'));
  }

  @override
  Future<AvahiServiceBrowser> createAvahiServiceBrowser(String serviceType) async {
    String serviceBrowserPath = await _server.callServiceBrowserPrepare(
      AvahiIfIndexUnspecified,
      AvahiProtocolUnspecified,
      serviceType,
      '',
      0,
    );
    return AvahiServiceBrowser(busClient, 'org.freedesktop.Avahi', DBusObjectPath(serviceBrowserPath));
  }

  @override
  Future<void> registerSubscriptions(AvahiBonsoirDiscovery discovery, AvahiServiceBrowser browser) async {
    discovery.registerSubscription('ItemNew', browser.itemNew.listen(discovery.onServiceFound));
    discovery.registerSubscription('ItemRm', browser.itemRemove.listen(discovery.onServiceLost));
  }

  @override
  Future<void> resolveService(AvahiBonsoirDiscovery discovery, BonsoirService service, AvahiServiceBrowserItemNew event) async {
    String serviceResolverPath = await _server.callServiceResolverPrepare(
      event.interfaceValue,
      event.protocol,
      event.name,
      event.type,
      event.domain,
      AvahiProtocolUnspecified,
      0,
    );
    AvahiServiceResolver resolver = AvahiServiceResolver(busClient, 'org.freedesktop.Avahi', DBusObjectPath(serviceResolverPath));
    Object? oneOf = await Future.any(
      [resolver.failure.first, resolver.found.first],
    );
    if (oneOf is AvahiServiceResolverFound) {
      discovery.onServiceResolved(oneOf);
    } else if (oneOf is AvahiServiceResolverFailure) {
      discovery.onServiceLost(oneOf);
    } else {
      discovery.onError(AvahiBonsoirError('Unknown error while resolving the service ${service.description}', oneOf));
    }
  }
}
