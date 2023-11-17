library bonsoir_linux_dbus;

import 'dart:convert';

import 'package:bonsoir_linux/actions/broadcast.dart';
import 'package:bonsoir_linux/actions/discovery/discovery.dart';
import 'package:bonsoir_linux/avahi/server.dart';
import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart';

/// Allows to create a Bonsoir discovery instance.
typedef DiscoveryFactory = AvahiBonsoirDiscovery Function({String type, bool printLogs});

/// Class for Linux implementation through Bonjour interface.
class AvahiBonsoir extends BonsoirPlatformInterface {
  /// Whether we should fallback to the legacy discovery.
  bool? _legacyDiscovery;

  /// Attaches Bonsoir for Linux to the Bonsoir platform interface.
  static void registerWith() {
    AvahiBonsoir avahiBonsoir = AvahiBonsoir();
    avahiBonsoir.initialize();
    BonsoirPlatformInterface.instance = avahiBonsoir;
  }

  /// Initializes Bonsoir for Linux.
  @visibleForTesting
  Future<void> initialize() async {
    this._legacyDiscovery = await isModernAvahi();
  }

  /// Returns whether the installed version of Avahi is > 7.0.
  static Future<bool> isModernAvahi() async {
    var server = AvahiServer(DBusClient.system(), 'org.freedesktop.Avahi', DBusObjectPath('/'));
    var version = (await server.callGetVersionString()).split(" ").last;
    var mayor = int.parse(version.split('.').first);
    var minor = int.parse(version.split('.').last);
    return mayor > 7 && minor >= 0;
  }

  @override
  AvahiBonsoirBroadcast createBroadcastAction(BonsoirService service, {bool printLogs = kDebugMode}) => AvahiBonsoirBroadcast(
        service: service,
        printLogs: printLogs,
      );

  @override
  AvahiBonsoirDiscovery createDiscoveryAction(String type, {bool printLogs = kDebugMode}) {
    assert(_legacyDiscovery != null, "Bonsoir for Linux hasn't finished its initialization !");
    return AvahiBonsoirDiscovery(
      type: type,
      printLogs: printLogs,
      legacy: _legacyDiscovery!,
    );
  }
}

/// Various useful functions for services.
extension Description on BonsoirService {
  /// Returns a string describing the current service.
  String get description => jsonEncode(toJson(prefix: ""));

  /// Returns the TXT record of the current service.
  List<Uint8List> get txtRecord => attributes.entries.map((attribute) => utf8.encode("${attribute.key}=${attribute.value}")).toList();
}
