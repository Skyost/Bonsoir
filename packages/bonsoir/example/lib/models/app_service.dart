import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/data.dart';
import 'package:uuid/uuid.dart';

/// Allows to get the Bonsoir service corresponding to the current device.
class DefaultAppService {
  /// The service type name.
  static const String type = 'bonsoirdemo';

  /// The service type.
  static const String protocol = 'tcp';

  /// The service port (in this example we're not doing anything on that port, but you should).
  static const int port = 4000;

  /// The "OS" attribute.
  static const String attributeOs = 'os';

  /// The "UUID" attribute.
  static const String attributeUuid = 'uuid';

  /// The default app service.
  static late BonsoirService _service;

  /// Returns the default app service instance.
  static BonsoirService get service => _service;

  /// Initializes the Bonsoir service instance.
  static Future initialize() async {
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
      type: '_$type._$protocol',
      port: port,
      attributes: {attributeOs: os, attributeUuid: const Uuid().v6(config: V6Options(null, null, null, null, name.codeUnits))},
    );
  }
}
