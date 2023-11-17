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
  final List<StreamSubscription> _subscriptions = [];

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
  Future<void> start() async {
    assert(isReady, '''AvahiBonsoirDiscovery should be ready to start in order to call this method.
You must wait until this instance is ready by calling "await AvahiBonsoirDiscovery.ready".
If you have previously called "AvahiBonsoirDiscovery.stop()" on this instance, you have to create a new instance of this class.''');
  }

  @override
  @mustCallSuper
  Future<void> stop() async {
    cancelSubscriptions();
    _controller.close();
    _isStopped = true;
  }

  /// Registers a subscription.
  void registerSubscription(StreamSubscription subscription) => _subscriptions.add(subscription);

  /// Cancels all subscriptions.
  void cancelSubscriptions() {
    for (StreamSubscription subscription in _subscriptions) {
      subscription.cancel();
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
