library bonsoir_linux_dbus;

import 'dart:convert';

import 'package:bonsoir_linux/actions/broadcast.dart';
import 'package:bonsoir_linux/actions/discovery/discovery.dart';
import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:flutter/foundation.dart';

/// Class for Linux implementation through Bonjour interface.
class AvahiBonsoir extends BonsoirPlatformInterface {
  /// Attaches Bonsoir for Linux to the Bonsoir platform interface.
  static void registerWith() => BonsoirPlatformInterface.instance = AvahiBonsoir();

  @override
  AvahiBonsoirBroadcast createBroadcastAction(BonsoirService service, {bool printLogs = kDebugMode}) => AvahiBonsoirBroadcast(
        service: service,
        printLogs: printLogs,
      );

  @override
  AvahiBonsoirDiscovery createDiscoveryAction(String type, {bool printLogs = kDebugMode}) => AvahiBonsoirDiscovery(
        type: type,
        printLogs: printLogs,
      );
}

/// Various useful functions for services.
extension Description on BonsoirService {
  /// Returns a string describing the current service.
  String get description => jsonEncode(toJson(prefix: ''));

  /// Returns the TXT record of the current service.
  List<Uint8List> get txtRecord => attributes.entries.map((attribute) => utf8.encode('${attribute.key}=${attribute.value}')).toList();
}
