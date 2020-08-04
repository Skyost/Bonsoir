import 'package:bonsoir/bonsoir.dart';
import 'package:bonsoir_example/models/app_service.dart';
import 'package:flutter/material.dart';

class BonsoirBroadcastModel extends ChangeNotifier {
  BonsoirBroadcast _bonsoirBroadcast;
  bool _isBroadcasting = false;

  bool get isBroadcasting => _isBroadcasting;

  Future<void> start({bool notify = true}) async {
    if (_bonsoirBroadcast == null || _bonsoirBroadcast.isStopped) {
      _bonsoirBroadcast = BonsoirBroadcast(service: await AppService.getService());
      await _bonsoirBroadcast.ready;
    }

    await _bonsoirBroadcast.start();
    _isBroadcasting = true;
    if (notify) {
      notifyListeners();
    }
  }

  void stop({bool notify = true}) {
    _bonsoirBroadcast?.stop();
    _isBroadcasting = false;
    if (notify) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stop(notify: false);
    super.dispose();
  }
}
