import 'dart:async';

import 'package:bonsoir_linux/avahi_defs/constants.dart';
import 'package:bonsoir_linux/avahi_defs/server.dart';
import 'package:bonsoir_linux/avahi_defs/server2.dart';
import 'package:bonsoir_linux/avahi_defs/service_browser.dart';
import 'package:bonsoir_linux/avahi_defs/service_resolver.dart';
import 'package:bonsoir_linux/events.dart';
import 'package:bonsoir_linux/exceptions.dart';
import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:dbus/dbus.dart';

extension KGResolver on AvahiServiceResolverFound {
  String get key => '$protocol.$interfaceValue.$serviceName.$type';
}

extension KGBrowserNew on AvahiServiceBrowserItemNew {
  String get key => '$protocol.$interfaceValue.$serviceName.$type';
}

extension KGBrowser on AvahiServiceBrowserItemRemove {
  String get key => '$protocol.$interfaceValue.$serviceName.$type';
}

ResolvedBonsoirService bonsoirServiceFromFoundService(AvahiServiceResolverFound resolvedService) {
  return ResolvedBonsoirService(
      name: resolvedService.serviceName,
      type: resolvedService.type,
      host: resolvedService.address,
      port: resolvedService.port,
      attributes: Map.fromEntries(resolvedService.txt.map((e) => MapEntry(e.split("=").first, e.split("=").last))));
}

abstract class AvahiBonsoirDiscovery extends AvahiBonsoirEvents<BonsoirDiscoveryEvent> {
  final Map<String, StreamSubscription> _subscriptions = {};
  final String type; // Service type.
  AvahiBonsoirDiscovery(this.type, bool printLogs) : super(printLogs);

  @override
  Future<void> stop() async {
    for (var entries in _subscriptions.entries) {
      // Not awaiting because DBus has a bug where the cancelation never ends?
      await entries.value.cancel();
    }
    _subscriptions.clear();
    controller!.add(BonsoirDiscoveryEvent(type: BonsoirDiscoveryEventType.discoveryStopped));
    super.stop();
  }

  Future<ResolvedBonsoirService> resolveService(AvahiServiceBrowserItemNew newService);
}

class LegacyClient extends AvahiBonsoirDiscovery {
  final Map<String, ResolvedBonsoirService> _resolvedServices = {};
  final Map<String, List<String>> _pendingReasons = {};

  late AvahiServiceBrowser _browser;
  late AvahiServer _server;

  LegacyClient(String type, bool printLogs) : super(type, printLogs);

  @override
  Future<void> get ready async {
    _server = AvahiServer(busClient, 'org.freedesktop.Avahi', DBusObjectPath('/'));
    controller = StreamController();
    // Setting all the work around listeners.
    _subscriptions['workaround_ItemNew'] = DBusSignalStream(busClient, sender: 'org.freedesktop.Avahi', interface: 'org.freedesktop.Avahi.ServiceBrowser', name: 'ItemNew').listen((signal) async {
      var event = AvahiServiceBrowserItemNew(signal);
      if (event.type == this.type) {
        print("Service found: ${event.friendlyString}");
        if (controller != null) {
          var svc = BonsoirService(
            name: event.name,
            type: event.type,
            port: -1,
          );
          controller!.add(
            BonsoirDiscoveryEvent(
              type: BonsoirDiscoveryEventType.discoveryServiceFound,
              service: svc,
            ),
          );
          final service = await resolveService(event);
          controller!.add(BonsoirDiscoveryEvent(type: BonsoirDiscoveryEventType.discoveryServiceResolved, service: service));
        } else {
          throw 'Controller should be defined already!';
        }
      }
    });
    _subscriptions['workaround_ItemRemove'] = DBusSignalStream(busClient, sender: 'org.freedesktop.Avahi', interface: 'org.freedesktop.Avahi.ServiceBrowser', name: 'ItemRemove').listen((signal) {
      final event = AvahiServiceBrowserItemRemove(signal);
      if (event.type == this.type) {
        print("Service lost: ${event.friendlyString}");
        if (controller != null) {
          var svc = BonsoirService(
            name: event.name,
            type: event.type,
            port: -1,
          );
          controller!.add(BonsoirDiscoveryEvent(type: BonsoirDiscoveryEventType.discoveryServiceLost, service: svc));
        } else {
          throw 'Controller should be defined already!';
        }
      }
    });
    _subscriptions['workaround_Failure'] = DBusSignalStream(busClient, sender: 'org.freedesktop.Avahi', interface: 'org.freedesktop.Avahi.ServiceResolver', name: 'Failure').listen((signal) {
      final event = AvahiServiceResolverFailure(signal);
      // Try to match the event to the pending failure.
      _pendingReasons.putIfAbsent(event.path.value, () => []).add(event.error);
    });
    _subscriptions['workaround_Found'] = DBusSignalStream(busClient, sender: 'org.freedesktop.Avahi', interface: 'org.freedesktop.Avahi.ServiceResolver', name: 'Found').listen((signal) {
      final event = AvahiServiceResolverFound(signal);
      _resolvedServices[event.key] = bonsoirServiceFromFoundService(event);
    });
  }

  @override
  Future<ResolvedBonsoirService> resolveService(AvahiServiceBrowserItemNew newService) async {
    final resolver = await _server.callServiceResolverNew(
        interface: newService.interfaceValue,
        protocol: newService.protocol,
        name: newService.serviceName,
        type: newService.type,
        domain: newService.domain,
        aprotocol: AvahiProtocolUnspecified,
        flags: 0);
    // Wait for the error or cached entry to enter.
    await Future.delayed(Duration(seconds: 1));
    for (final reason in _pendingReasons.putIfAbsent(resolver, () => []).reversed) {
      throw AvahiResolveFailureException(reason, details: newService);
    }
    final solvedService = _resolvedServices[newService.key];
    if (solvedService != null) {
      print("Service resolved: ${solvedService.toJson()}");
      return solvedService;
    } else {
      throw AvahiResolveFailureException('The service did not get resolved in time', details: newService);
    }
  }

  @override
  Future<void> start() async {
    controller!.add(BonsoirDiscoveryEvent(type: BonsoirDiscoveryEventType.discoveryStarted));
    final browserPath = await _server.callServiceBrowserNew(
      interface: AvahiIfIndexUnspecified,
      protocol: AvahiProtocolUnspecified,
      type: type,
      domain: '',
      flags: 0,
    );
    _browser = AvahiServiceBrowser(busClient, 'org.freedesktop.Avahi', DBusObjectPath(browserPath));
  }
}

class V2Client extends AvahiBonsoirDiscovery {
  late AvahiServiceBrowser _browser;
  late AvahiServer2 _server2;

  final Map<String, ResolvedBonsoirService> _resolvedServices = {};

  V2Client(String type, bool printLogs) : super(type, printLogs);

  @override
  Future<void> get ready async {
    _server2 = AvahiServer2(busClient, 'org.freedesktop.Avahi', DBusObjectPath('/'));
    var serviceBrowserPath = await _server2.callServiceBrowserPrepare(AvahiIfIndexUnspecified, AvahiProtocolUnspecified, type, '', 0);
    _browser = AvahiServiceBrowser(busClient, 'org.freedesktop.Avahi', DBusObjectPath(serviceBrowserPath));
    controller = StreamController();
  }

  @override
  Future<void> start() async {
    controller!.add(BonsoirDiscoveryEvent(type: BonsoirDiscoveryEventType.discoveryStarted));
    _subscriptions['ItemNew'] = _browser.itemNew.listen((event) async {
      print("Item added! ${event.friendlyString}");
      controller!.add(
        BonsoirDiscoveryEvent(
          type: BonsoirDiscoveryEventType.discoveryServiceFound,
          service: BonsoirService(name: event.name, type: event.type, port: -1),
        ),
      );
      var resolvedService = await resolveService(event);
      controller!.add(
        BonsoirDiscoveryEvent(
          type: BonsoirDiscoveryEventType.discoveryServiceResolved,
          service: resolvedService,
        ),
      );
      _resolvedServices[event.key] = resolvedService;
    });
    _subscriptions['ItemRm'] = _browser.itemRemove.listen((event) {
      print("Item removed! ${event.friendlyString}");
      var toRemove = _resolvedServices[event.key];
      _resolvedServices.remove(event.key);
      controller!.add(
        BonsoirDiscoveryEvent(
          type: BonsoirDiscoveryEventType.discoveryServiceLost,
          service: toRemove,
        ),
      );
    });
    await _browser.callStart();
  }

  @override
  Future<ResolvedBonsoirService> resolveService(AvahiServiceBrowserItemNew newService) async {
    var serviceResolverPath = await _server2.callServiceResolverPrepare(
      newService.interfaceValue,
      newService.protocol,
      newService.name,
      newService.type,
      newService.domain,
      AvahiProtocolUnspecified,
      0,
    );
    var resolver = AvahiServiceResolver(busClient, 'org.freedesktop.Avahi', DBusObjectPath(serviceResolverPath));
    Object? oneOf = await Future.any(
      [resolver.failure.first, resolver.found.first],
    );
    if (oneOf is AvahiServiceResolverFound) {
      return bonsoirServiceFromFoundService(oneOf);
    } else if (oneOf is AvahiServiceResolverFailure) {
      print('Error while trying to resolve this service: ${oneOf.error}');
      throw AvahiResolveFailureException(oneOf.error, details: newService);
    } else {
      throw AvahiResolveFailureException('Unknown error');
    }
  }
}
