import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';

/// A model that allows to control an action (broadcast / discovery) and
/// to broadcasts changes to the widgets tree.
abstract class BonsoirActionModel<T, A extends BonsoirActionHandler<E>, E extends BonsoirEvent> extends ChangeNotifier {
  /// A map containing all actions.
  final Map<String, A> _bonsoirActions = {};

  /// A map containing all states.
  final Map<String, BonsoirActionState> _bonsoirActionsState = {};

  /// Creates a Bonsoir action according to the specified argument.
  A createAction(T argument);

  /// Returns a map key from the given argument.
  String getKeyFromArgument(T argument) => argument.toString();

  /// Starts the Bonsoir broadcast.
  Future<void> start(T argument, {bool notify = true}) async {
    _changeState(argument, BonsoirActionState.starting, notify: notify);
    A? action = _bonsoirActions[argument];
    if (!(action == null || action.isStopped)) {
      return;
    }

    action = createAction(argument);
    await action.ready;
    _bonsoirActions[getKeyFromArgument(argument)] = action;
    _changeState(argument, BonsoirActionState.ready, notify: notify);
    action.eventStream?.listen(onEventOccurred);
    await action.start();
    _changeState(argument, BonsoirActionState.broadcasting, notify: notify);
  }

  /// Triggered when a Bonsoir event occurred.
  void onEventOccurred(E event) {}

  /// Changes the action state.
  void _changeState(T argument, BonsoirActionState newState, {bool notify = true}) {
    _bonsoirActionsState[getKeyFromArgument(argument)] = newState;
    if (notify) {
      notifyListeners();
    }
  }

  /// Returns the Bonsoir actions handled by this model.
  Iterable<A> get actions => _bonsoirActions.values;

  /// Returns the requested action.
  A? getAction(T argument) => _bonsoirActions[argument];

  /// Returns the requested action state.
  BonsoirActionState getActionState(T argument) => _bonsoirActionsState[argument] ?? BonsoirActionState.notReady;

  /// Stops the Bonsoir broadcast for the given service.
  Future<void> stop(T argument, {bool notify = true}) async {
    String key = getKeyFromArgument(argument);
    await _bonsoirActions[key]?.stop();
    _bonsoirActions.remove(key);
    _bonsoirActionsState.remove(key);
    if (notify) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (BonsoirActionHandler action in _bonsoirActions.values) {
      action.stop();
    }
    _bonsoirActions.clear();
    _bonsoirActionsState.clear();
    super.dispose();
  }
}

/// Represents a Bonsoir action state.
enum BonsoirActionState {
  /// The action is starting.
  starting,

  /// The action is not ready to broadcast.
  notReady,

  /// The action is ready to broadcast.
  ready,

  /// The action is broadcasting.
  broadcasting;
}
