library bonsoir_linux;

import 'package:bonsoir_linux/src/actions/broadcast.dart';
import 'package:bonsoir_linux/src/actions/discovery/discovery.dart';
import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:flutter/foundation.dart';

/// Class for Linux implementation through Bonjour interface.
class BonsoirLinux extends BonsoirPlatformInterface {
  /// The Avahi package name.
  static const String avahi = 'org.freedesktop.Avahi';

  /// Attaches Bonsoir for Linux to the Bonsoir platform interface.
  static void registerWith() => BonsoirPlatformInterface.instance = BonsoirLinux();

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
