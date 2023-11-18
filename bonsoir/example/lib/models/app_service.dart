import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/data.dart';
import 'package:uuid/uuid.dart';

/// Allows to get the Bonsoir service corresponding to the current device.
class AppService {
  /// The service type.
  static const String type = '_bonsoirdemo._tcp';

  /// The service port (in this example we're not doing anything on that port, but you should).
  static const int port = 4000;

  /// The "OS" attribute.
  static const String attributeOs = 'os';

  /// The "UUID" attribute.
  static const String attributeUuid = 'uuid';

  /// The cached service.
  static BonsoirService? _service;

  /// Returns (and create if needed) the app Bonsoir service.
  static Future<BonsoirService> getService() async {
    if (_service != null) {
      return _service!;
    }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String name;
    String os;
    if (Platform.isAndroid) {
      name = (await deviceInfo.androidInfo).model;
      os = 'Android';
    } else if (Platform.isIOS) {
      name = (await deviceInfo.iosInfo).localizedModel;
      os = 'iOS';
    } else if (Platform.isMacOS) {
      name = (await deviceInfo.macOsInfo).computerName;
      os = 'macOS';
    } else if (Platform.isWindows) {
      name = (await deviceInfo.windowsInfo).computerName;
      os = 'Windows';
    } else if (Platform.isLinux) {
      name = (await deviceInfo.linuxInfo).name;
      os = 'Linux';
    } else {
      name = 'Flutter';
      os = 'Unknown';
    }
    name += ' Bonsoir Demo';

    _service = BonsoirService(
      name: name,
      type: type,
      port: port,
      attributes: {attributeOs: os, attributeUuid: const Uuid().v6(config: V6Options(null, null, null, null, name.codeUnits))},
    );
    return _service!;
  }
}
