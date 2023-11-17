// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object org.freedesktop.Avahi.ServiceBrowser.xml

import 'package:dbus/dbus.dart';

/// Signal data for org.freedesktop.Avahi.ServiceBrowser.ItemNew.
class AvahiServiceBrowserItemNew extends DBusSignal {
  int get interfaceValue => (values[0] as DBusInt32).value;

  int get protocol => (values[1] as DBusInt32).value;

  String get serviceName => (values[2] as DBusString).value;

  String get type => (values[3] as DBusString).value;

  String get domain => (values[4] as DBusString).value;

  int get flags => (values[5] as DBusUint32).value;

  AvahiServiceBrowserItemNew(DBusSignal signal)
      : super(
            sender: signal.sender,
            path: signal.path,
            interface: signal.interface,
            name: signal.name,
            values: signal.values);
}

/// Signal data for org.freedesktop.Avahi.ServiceBrowser.ItemRemove.
class AvahiServiceBrowserItemRemove extends DBusSignal {
  int get interfaceValue => (values[0] as DBusInt32).value;

  int get protocol => (values[1] as DBusInt32).value;

  String get serviceName => (values[2] as DBusString).value;

  String get type => (values[3] as DBusString).value;

  String get domain => (values[4] as DBusString).value;

  int get flags => (values[5] as DBusUint32).value;

  AvahiServiceBrowserItemRemove(DBusSignal signal)
      : super(
            sender: signal.sender,
            path: signal.path,
            interface: signal.interface,
            name: signal.name,
            values: signal.values);
}

/// Signal data for org.freedesktop.Avahi.ServiceBrowser.Failure.
class AvahiServiceBrowserFailure extends DBusSignal {
  String get error => (values[0] as DBusString).value;

  AvahiServiceBrowserFailure(DBusSignal signal)
      : super(
            sender: signal.sender,
            path: signal.path,
            interface: signal.interface,
            name: signal.name,
            values: signal.values);
}

/// Signal data for org.freedesktop.Avahi.ServiceBrowser.AllForNow.
class AvahiServiceBrowserAllForNow extends DBusSignal {
  AvahiServiceBrowserAllForNow(DBusSignal signal)
      : super(
            sender: signal.sender,
            path: signal.path,
            interface: signal.interface,
            name: signal.name,
            values: signal.values);
}

/// Signal data for org.freedesktop.Avahi.ServiceBrowser.CacheExhausted.
class AvahiServiceBrowserCacheExhausted extends DBusSignal {
  AvahiServiceBrowserCacheExhausted(DBusSignal signal)
      : super(
            sender: signal.sender,
            path: signal.path,
            interface: signal.interface,
            name: signal.name,
            values: signal.values);
}

class AvahiServiceBrowser extends DBusRemoteObject {
  /// Stream of org.freedesktop.Avahi.ServiceBrowser.ItemNew signals.
  late final Stream<AvahiServiceBrowserItemNew> itemNew;

  /// Stream of org.freedesktop.Avahi.ServiceBrowser.ItemRemove signals.
  late final Stream<AvahiServiceBrowserItemRemove> itemRemove;

  /// Stream of org.freedesktop.Avahi.ServiceBrowser.Failure signals.
  late final Stream<AvahiServiceBrowserFailure> failure;

  /// Stream of org.freedesktop.Avahi.ServiceBrowser.AllForNow signals.
  late final Stream<AvahiServiceBrowserAllForNow> allForNow;

  /// Stream of org.freedesktop.Avahi.ServiceBrowser.CacheExhausted signals.
  late final Stream<AvahiServiceBrowserCacheExhausted> cacheExhausted;

  AvahiServiceBrowser(
      DBusClient client, String destination, DBusObjectPath path)
      : super(client, name: destination, path: path) {
    itemNew = DBusRemoteObjectSignalStream(
            object: this,
            interface: 'org.freedesktop.Avahi.ServiceBrowser',
            name: 'ItemNew',
            signature: DBusSignature('iisssu'))
        .asBroadcastStream()
        .map((signal) => AvahiServiceBrowserItemNew(signal));

    itemRemove = DBusRemoteObjectSignalStream(
            object: this,
            interface: 'org.freedesktop.Avahi.ServiceBrowser',
            name: 'ItemRemove',
            signature: DBusSignature('iisssu'))
        .asBroadcastStream()
        .map((signal) => AvahiServiceBrowserItemRemove(signal));

    failure = DBusRemoteObjectSignalStream(
            object: this,
            interface: 'org.freedesktop.Avahi.ServiceBrowser',
            name: 'Failure',
            signature: DBusSignature('s'))
        .asBroadcastStream()
        .map((signal) => AvahiServiceBrowserFailure(signal));

    allForNow = DBusRemoteObjectSignalStream(
            object: this,
            interface: 'org.freedesktop.Avahi.ServiceBrowser',
            name: 'AllForNow',
            signature: DBusSignature(''))
        .asBroadcastStream()
        .map((signal) => AvahiServiceBrowserAllForNow(signal));

    cacheExhausted = DBusRemoteObjectSignalStream(
            object: this,
            interface: 'org.freedesktop.Avahi.ServiceBrowser',
            name: 'CacheExhausted',
            signature: DBusSignature(''))
        .asBroadcastStream()
        .map((signal) => AvahiServiceBrowserCacheExhausted(signal));
  }

  /// Invokes org.freedesktop.DBus.Introspectable.Introspect()
  Future<String> callIntrospect(
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.DBus.Introspectable', 'Introspect', [],
        replySignature: DBusSignature('s'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusString).value;
  }

  /// Invokes org.freedesktop.Avahi.ServiceBrowser.Free()
  Future<void> callFree(
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.Avahi.ServiceBrowser', 'Free', [],
        replySignature: DBusSignature(''),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.Avahi.ServiceBrowser.Start()
  Future<void> callStart(
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.Avahi.ServiceBrowser', 'Start', [],
        replySignature: DBusSignature(''),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
  }
}
