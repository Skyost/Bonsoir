import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:bonsoir_example/models/app_service.dart';
import 'package:flutter/material.dart';

class BonsoirDiscoveryModel extends ChangeNotifier {
  BonsoirDiscovery _bonsoirDiscovery;
  final List<DiscoveredBonsoirService> _discoveredServices = [];

  StreamSubscription<BonsoirDiscoveryEvent> _subscription;

  BonsoirDiscoveryModel() {
    start();
  }

  List<DiscoveredBonsoirService> get discoveredServices => List.of(_discoveredServices);

  Future<void> start() async {
    if(_bonsoirDiscovery == null || _bonsoirDiscovery.isStopped) {
      _bonsoirDiscovery = BonsoirDiscovery(type: (await AppService.getService()).type);
      await _bonsoirDiscovery.ready;
    }

    await _bonsoirDiscovery.start();
    _subscription = _bonsoirDiscovery.eventStream.listen(_onEventOccurred);
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _bonsoirDiscovery?.stop();
  }

  void _onEventOccurred(BonsoirDiscoveryEvent event) {
    if(event.service?.ip == null) {
      return;
    }

    if (event.type == BonsoirDiscoveryEventType.DISCOVERY_SERVICE_FOUND) {
      _discoveredServices.add(event.service);
      notifyListeners();
    } else if (event.type == BonsoirDiscoveryEventType.DISCOVERY_SERVICE_LOST) {
      _discoveredServices.remove(event.service);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
