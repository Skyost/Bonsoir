// Imports the Flutter Driver API.
import 'dart:convert';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Bonsoir', () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        await driver.close();
      }
    });

    test('ready', () async {
      expect(await driver.requestData('ready'), 'SUCCESS');
    });

    test('starting', () async {
      expect(await driver.requestData('start'), 'SUCCESS');
    });

    test('stopping', () async {
      expect(await driver.requestData('stop'), 'SUCCESS');
    });

    test('service discovery', () async {
      final data = await driver.requestData('discover');
      expect(data, isNot(equals('ERROR')));

      Map<String, dynamic> service = jsonDecode(data);
      print('Service discovery result: $data');

      expect(service['service.type'], '._bonsoirdemo._tcp');
      expect(service['service.name'], isNotNull);
      expect(service['service.port'], isNotNull);
      expect(service['service.ip'], isNotNull);
      expect(service['service.attributes']['Bonsoir'], 'Salut');
    });
  });
}