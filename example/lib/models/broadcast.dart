import 'package:bonsoir/bonsoir.dart';
import 'package:bonsoir_example/models/app_service.dart';
import 'package:flutter/material.dart';

/// Provider model that allows to handle Bonsoir broadcasts.
class BonsoirBroadcastModel extends ChangeNotifier {
  /// The current Bonsoir broadcast object instance.
  BonsoirBroadcast _bonsoirBroadcast;

  /// Whether Bonsoir is currently broadcasting the app's service.
  bool _isBroadcasting = false;

  /// Returns wether Bonsoir is currently broadcasting the app's service.
  bool get isBroadcasting => _isBroadcasting;

  /// Starts the Bonsoir broadcast.
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

  /// Stops the Bonsoir broadcast.
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
