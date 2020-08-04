import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:device_info/device_info.dart';

class AppService {
  static const String type = '_bonsoirdemo._tcp';
  static const int port = 4000;

  static BonsoirService _service;

  static Future<BonsoirService> getService() async {
    if (_service != null) {
      return _service;
    }

    String name;
    if (Platform.isAndroid) {
      name = (await DeviceInfoPlugin().androidInfo).model;
    } else if (Platform.isIOS) {
      name = (await DeviceInfoPlugin().iosInfo).localizedModel;
    } else {
      name = 'Flutter';
    }
    name += ' Bonsoir Demo';

    _service = BonsoirService(name: name, type: type, port: port);
    return _service;
  }
}
