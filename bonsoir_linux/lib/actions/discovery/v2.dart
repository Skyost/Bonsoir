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
class AvahiDiscoveryV2 extends AvahiBonsoirDiscovery {
  /// The Avahi server instance.
  late final AvahiServer2 _server;

  /// Creates a new Avahi discovery v2 instance.
  AvahiDiscoveryV2({
    required String type,
    required bool printLogs,
  }) : super.internal(
          type: type,
          printLogs: printLogs,
        );

  @override
  Future<void> get ready async {
    _server = AvahiServer2(busClient, 'org.freedesktop.Avahi', DBusObjectPath('/'));
    await super.ready;
  }

  @override
  Future<AvahiServiceBrowser> createAvahiServiceBrowser() async {
    String serviceBrowserPath = await _server.callServiceBrowserPrepare(
      AvahiIfIndexUnspecified,
      AvahiProtocolUnspecified,
      type,
      '',
      0,
    );
    return AvahiServiceBrowser(busClient, 'org.freedesktop.Avahi', DBusObjectPath(serviceBrowserPath));
  }

  @override
  Future<void> start() async {
    registerSubscription('ItemNew', browser.itemNew.listen(onServiceFound));
    registerSubscription('ItemRm', browser.itemRemove.listen(onServiceLost));
    await super.start();
  }

  @override
  Future<void> resolveServiceByEvent(BonsoirService service, AvahiServiceBrowserItemNew event) async {
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
      onServiceResolved(oneOf);
    } else if (oneOf is AvahiServiceResolverFailure) {
      onServiceLost(oneOf);
    } else {
      onError(AvahiBonsoirError('Unknown error while resolving the service ${service.description}', oneOf));
    }
  }
}
