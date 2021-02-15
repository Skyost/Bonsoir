import 'dart:convert';
import 'package:flutter_driver/driver_extension.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:bonsoir_tests/main.dart' as app;

void main() {
  String type = '_bonsoirdemo._tcp';
  BonsoirDiscovery discovery = BonsoirDiscovery(type: type);

  enableFlutterDriverExtension(handler: (payload) async {
    switch(payload) {
      case 'ready':
        try {
          await discovery.ready;
          return 'SUCCESS';
        } catch(e) {
          return 'ERROR';
        }
        break;
      case 'start':
        try {
          await discovery.start();
          return 'SUCCESS';
        } catch(e) {
          return 'ERROR';
        }
        break;
      case 'stop':
        try {
          await discovery.stop();
          return 'SUCCESS';
        } catch(e) {
          return 'ERROR';
        }
        break;
      case 'discover':
        try {
          String service = 'ERROR';
          discovery = BonsoirDiscovery(type: type);
          await discovery.ready;
          await discovery.start();
          await for(BonsoirDiscoveryEvent event in discovery.eventStream) {
            if (event.type == BonsoirDiscoveryEventType.DISCOVERY_SERVICE_RESOLVED) {
              service = jsonEncode(event.service.toJson());
              break; 
            }
          }
          await discovery.stop();
          return service;
        } catch(e) {
          return 'ERROR';
        }
        break;
      default:
        return null;
    }
  });

  app.main();
}