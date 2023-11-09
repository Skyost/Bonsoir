import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Allows to get the Bonsoir service corresponding to the current device.
class AppService {
  /// The service type.
  static const String type = '_bonsoirdemo._tcp';

  /// The service port (in this example we're not doing anything on that port, but you should).
  static const int port = 4000;

  /// The cached service.
  static BonsoirService? _service;

  /// Returns (and create if needed) the app Bonsoir service.
  static Future<BonsoirService> getService() async {
    if (_service != null) {
      return _service!;
    }

    String name;
    if (Platform.isAndroid) {
      name = (await DeviceInfoPlugin().androidInfo).model;
    } else if (Platform.isIOS) {
      name = (await DeviceInfoPlugin().iosInfo).localizedModel;
    } else if (Platform.isMacOS) {
      name = (await DeviceInfoPlugin().macOsInfo).computerName;
    } else {
      name = 'Flutter';
    }
    name += ' Bonsoir Demo';

    _service = BonsoirService(
      name: name,
      type: type,
      port: port,
      attributes: {},
    );
    return _service!;
  }
}
