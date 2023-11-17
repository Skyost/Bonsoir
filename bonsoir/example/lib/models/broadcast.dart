import 'package:bonsoir/bonsoir.dart';
import 'package:bonsoir_example/models/app_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The model provider.
final broadcastModelProvider = ChangeNotifierProvider((ref) {
  BonsoirBroadcastModel model = BonsoirBroadcastModel();
  model.start();
  return model;
});

/// Provider model that allows to handle Bonsoir broadcasts.
class BonsoirBroadcastModel extends ChangeNotifier {
  /// The current Bonsoir broadcast object instance.
  BonsoirBroadcast? _bonsoirBroadcast;

  /// The current state.
  BonsoirBroadcastModelState _state = BonsoirBroadcastModelState.notReady;

  /// Returns the current state.
  BonsoirBroadcastModelState get state => _state;

  /// Starts the Bonsoir broadcast.
  Future<void> start({bool notify = true}) async {
    changeState(BonsoirBroadcastModelState.starting, notify: notify);
    if (_bonsoirBroadcast == null || _bonsoirBroadcast!.isStopped) {
      _bonsoirBroadcast = BonsoirBroadcast(service: await AppService.getService());
      await _bonsoirBroadcast!.ready;
      changeState(BonsoirBroadcastModelState.ready, notify: notify);
    }

    await _bonsoirBroadcast!.start();
    changeState(BonsoirBroadcastModelState.broadcasting, notify: notify);
  }

  /// Changes the model state.
  void changeState(BonsoirBroadcastModelState newState, {bool notify = true}) {
    _state = newState;
    if (notify) {
      notifyListeners();
    }
  }

  /// Stops the Bonsoir broadcast.
  void stop({bool notify = true}) {
    _bonsoirBroadcast?.stop();
    changeState(BonsoirBroadcastModelState.notReady, notify: notify);
  }

  @override
  void dispose() {
    stop(notify: false);
    super.dispose();
  }
}

/// Represents the model state.
enum BonsoirBroadcastModelState {
  /// The model is starting.
  starting,

  /// The model is not ready to broadcast.
  notReady,

  /// The model is ready to broadcast.
  ready,

  /// The model is broadcasting.
  broadcasting;
}
