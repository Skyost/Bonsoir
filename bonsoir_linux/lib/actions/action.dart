import 'dart:async';

import 'package:bonsoir_linux/avahi/constants.dart';
import 'package:bonsoir_linux/avahi/service_browser.dart';
import 'package:bonsoir_linux/error.dart';
import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:dbus/dbus.dart';
import 'package:meta/meta.dart';

/// Base implementation for [BonsoirAction] on Linux.
abstract class AvahiBonsoirAction<T extends BonsoirEvent> extends BonsoirAction<T> {
  /// A string describing the current action.
  final String action;

  /// Whether to print logs.
  final bool printLogs;

  /// The DBus client instance.
  final DBusClient busClient;

  /// The current stream controller instance.
  final StreamController<T> _controller = StreamController<T>();

  /// Contains the subscriptions instances.
  final Map<String, StreamSubscription> _subscriptions = {};

  /// Whether the action has been stopped.
  bool _isStopped = false;

  /// Creates a new Avahi bonsoir action instance.
  AvahiBonsoirAction({
    required this.action,
    required this.printLogs,
    DBusClient? busClient,
  }) : busClient = busClient ?? DBusClient.system();

  @override
  Stream<T>? get eventStream => _controller.stream;

  @override
  bool get isReady => !isStopped;

  @override
  bool get isStopped => _isStopped;

  /// Triggered when an event occurs.
  void onEvent(T event, String message) {
    log(message);
    _controller.add(event);
  }

  /// Triggered when an error occurs.
  void onError(AvahiBonsoirError error) {
    log(error.message);
    _controller.addError(error);
  }

  @override
  @mustCallSuper
  Future<void> stop() async {
    cancelSubscriptions();
    _controller.close();
    _isStopped = true;
  }

  /// Registers a subscription.
  void registerSubscription(String name, StreamSubscription subscription) => _subscriptions[name] = subscription;

  /// Cancels all subscriptions.
  void cancelSubscriptions() {
    for (MapEntry<String, StreamSubscription> entries in _subscriptions.entries) {
      entries.value.cancel();
    }
    _subscriptions.clear();
  }

  /// Prints a message to the console, if enabled.
  void log(String message) {
    if (printLogs) {
      print('[$action] $message');
    }
  }
}

extension ItemNewPrintHelpers on AvahiServiceBrowserItemNew {
  String get friendlyString {
    return "AvahiServiceBrowserItemNew(path: '$path',interface: '$interfaceValue',protocol: '${protocol.toAvahiProtocol().toString()}', name: '$name',type: '$type',domain: '${this.domain}'";
  }
}

extension ItemRemovePrintHelpers on AvahiServiceBrowserItemRemove {
  String get friendlyString {
    return "AvahiServiceBrowserItemRemove(path: '$path',interface: '$interfaceValue',protocol: '${protocol.toAvahiProtocol().toString()}', name: '$name',type: '$type',domain: '${this.domain}'";
  }
}
