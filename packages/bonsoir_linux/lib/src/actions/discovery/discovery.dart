import 'dart:async';
import 'dart:convert';

import 'package:bonsoir_linux/bonsoir_linux.dart';
import 'package:bonsoir_linux/src/actions/action.dart';
import 'package:bonsoir_linux/src/actions/discovery/legacy.dart';
import 'package:bonsoir_linux/src/actions/discovery/v2.dart';
import 'package:bonsoir_linux/src/avahi/record_browser.dart';
import 'package:bonsoir_linux/src/avahi/server.dart';
import 'package:bonsoir_linux/src/avahi/service_browser.dart';
import 'package:bonsoir_linux/src/avahi/service_resolver.dart';
import 'package:bonsoir_linux/src/error.dart';
import 'package:bonsoir_linux/src/service.dart';
import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart';

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
    required super.printLogs,
  }) : super(
          action: 'discovery',
        );

  @override
  Future<void> get ready async {
    if (_serviceBrowser == null) {
      _avahiHandler = ((await _isModernAvahi) ? AvahiDiscoveryV2.new : AvahiDiscoveryLegacy.new)(busClient: busClient);
      _avahiHandler!.initialize();
      _serviceBrowser = AvahiServiceBrowser(busClient, BonsoirLinux.avahi, DBusObjectPath(await _avahiHandler!.getAvahiServiceBrowserPath(type)));
    }
  }

  @override
  bool get isReady => super.isReady && _serviceBrowser != null;

  @override
  Future<void> start() async {
    await super.start();
    List<StreamSubscription> subscriptions = [
      DBusSignalStream(
        busClient,
        sender: BonsoirLinux.avahi,
        interface: '${BonsoirLinux.avahi}.ServiceBrowser',
        name: 'ItemNew',
      ).listen(_onServiceFound),
      DBusSignalStream(
        busClient,
        sender: BonsoirLinux.avahi,
        interface: '${BonsoirLinux.avahi}.ServiceBrowser',
        name: 'ItemRemove',
      ).listen(_onServiceLost),
      DBusSignalStream(
        busClient,
        sender: BonsoirLinux.avahi,
        interface: '${BonsoirLinux.avahi}.ServiceResolver',
        name: 'Failure',
      ).listen(_onServiceResolveFailure),
      DBusSignalStream(
        busClient,
        sender: BonsoirLinux.avahi,
        interface: '${BonsoirLinux.avahi}.ServiceResolver',
        name: 'Found',
      ).listen(_onServiceResolved),
      DBusSignalStream(
        busClient,
        sender: BonsoirLinux.avahi,
        interface: '${BonsoirLinux.avahi}.RecordBrowser',
        name: 'ItemNew',
      ).listen(_onServiceTXTRecordFound),
      DBusSignalStream(
        busClient,
        sender: BonsoirLinux.avahi,
        interface: '${BonsoirLinux.avahi}.RecordBrowser',
        name: 'Failure',
      ).listen(_onServiceTXTRecordNotFound),
    ];
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
      onError(BonsoirLinuxError('Trying to resolve an undiscovered service : ${service.name}', service.name));
      return;
    }
    _avahiHandler!.resolveService(this, serviceInstance, _foundServices[serviceInstance]!);
  }

  @override
  Future<void> stop() async {
    _serviceBrowser!.callFree();
    for (AvahiRecordBrowser recordBrowser in _recordBrowsers) {
      recordBrowser.callFree();
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
  Future<void> _onServiceFound(DBusSignal signal) async {
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
      AvahiRecordBrowser recordBrowser = await _avahiHandler!.createAvahiRecordBrowser(this, service);
      recordBrowser.callStart();
    }
  }

  /// Triggered when a service has been lost.
  void _onServiceLost(DBusSignal signal) {
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
  void _onServiceResolved(DBusSignal signal) {
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
  void _onServiceResolveFailure(DBusSignal signal) {
    AvahiServiceResolverFailure event = AvahiServiceResolverFailure(signal);
    onEvent(
      const BonsoirDiscoveryEvent(type: BonsoirDiscoveryEventType.discoveryServiceResolveFailed),
      'Bonsoir has failed to resolve a service : ${event.error}',
    );
  }

  /// Triggered when a Bonsoir service TXT record has been found.
  void _onServiceTXTRecordFound(DBusSignal signal) {
    AvahiRecordBrowserItemNew event = AvahiRecordBrowserItemNew(signal);
    (String, String)? serviceData = _parseBonjourFqdn(_unescapeAscii(event.recordName));
    BonsoirService? service = serviceData == null ? null : _findService(serviceData.$1, serviceData.$2);
    if (service == null) {
      return;
    }

    Map<String, String> attributes = _parseTXTRecordData(event.rdata);
    if (!mapEquals(service.attributes, attributes)) {
      log('Bonsoir has found the attributes of a service : $service');
      onEvent(BonsoirDiscoveryEvent(type: BonsoirDiscoveryEventType.discoveryServiceLost, service: service));
      AvahiServiceBrowserItemNew serviceEvent = _foundServices[service]!;
      _foundServices.remove(service);
      service = service.copyWith(attributes: attributes);
      _foundServices[service] = serviceEvent;
      onEvent(BonsoirDiscoveryEvent(type: BonsoirDiscoveryEventType.discoveryServiceFound, service: service));
    }
  }

  /// Triggered when a Bonsoir service TXT record has not been found.
  void _onServiceTXTRecordNotFound(DBusSignal signal) {
    AvahiRecordBrowserFailure event = AvahiRecordBrowserFailure(signal);
    log('Bonsoir has failed to get the TXT record of a service : ${event.error}');
  }

  /// Allows to unescape services FQDN.
  String _unescapeAscii(String input) {
    String result = '';
    for (int i = 0; i < input.length; i++) {
      if (input[i] == '\\' && i + 1 < input.length) {
        String asciiCode = '';
        int j = 1;
        for (; j < 4; j++) {
          if (i + j >= input.length || int.tryParse(input[i + j]) == null) {
            break;
          }
          asciiCode += input[i + j];
        }
        int asciiCodeInteger = int.parse(asciiCode);
        if (0 <= asciiCodeInteger && asciiCodeInteger <= 127) {
          result += ascii.decode([asciiCodeInteger]);
        } else {
          result += '\\${asciiCode}';
        }
        i += (j - 1);
      } else {
        result += input[i];
      }
    }
    return result;
  }

  /// Parses a Bonjour FQDN.
  (String, String)? _parseBonjourFqdn(String fqdn) {
    final RegExp regex = RegExp(r'^(.*?)\._(.*?)\.?(?:local)?\.?$');
    final Match? match = regex.firstMatch(fqdn);

    if (match != null && match.groupCount >= 2) {
      final serviceName = match.group(1)?.trim() ?? '';
      final serviceType = '_${match.group(2)}';

      return (serviceName, serviceType);
    }

    return null;
  }

  /// Parse a TXT record data.
  Map<String, String> _parseTXTRecordData(List<int> txtRecordData) {
    Map<String, String> result = {};
    if (txtRecordData.isEmpty || listEquals(txtRecordData, [0])) {
      return result;
    }

    int currentIndex = 0;
    while (currentIndex < txtRecordData.length) {
      int lengthByte = txtRecordData[currentIndex];
      currentIndex++;
      if (currentIndex + lengthByte <= txtRecordData.length) {
        String string = utf8.decode(txtRecordData.sublist(currentIndex, currentIndex + lengthByte));
        int equalIndex = string.indexOf('=');
        String key = string;
        String value = '';
        if (equalIndex != -1) {
          key = string.substring(0, equalIndex);
          value = string.substring(equalIndex + 1);
        }
        if (!key.startsWith('=') && !result.containsKey(key)) {
          result[key] = value;
        }
        currentIndex += lengthByte;
      } else {
        break;
      }
    }
    return result;
  }

  /// Returns whether the installed version of Avahi is > 0.7.
  Future<bool> get _isModernAvahi async {
    AvahiServer server = AvahiServer(DBusClient.system(), BonsoirLinux.avahi, DBusObjectPath('/'));
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

  /// Creates a Avahi record browser for the given service.
  Future<AvahiRecordBrowser> createAvahiRecordBrowser(AvahiBonsoirDiscovery discovery, BonsoirService service);

  /// Resolves a service using its event.
  Future<void> resolveService(AvahiBonsoirDiscovery discovery, BonsoirService service, AvahiServiceBrowserItemNew event);
}
