// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object org.freedesktop.Avahi.ServiceTypeBrowser.xml

import 'package:dbus/dbus.dart';

/// Signal data for org.freedesktop.Avahi.ServiceTypeBrowser.ItemNew.
class AvahiServiceTypeBrowserItemNew extends DBusSignal {
  int get interfaceValue => (values[0] as DBusInt32).value;

  int get protocol => (values[1] as DBusInt32).value;

  String get type => (values[2] as DBusString).value;

  String get domain => (values[3] as DBusString).value;

  int get flags => (values[4] as DBusUint32).value;

  AvahiServiceTypeBrowserItemNew(DBusSignal signal)
      : super(
            sender: signal.sender,
            path: signal.path,
            interface: signal.interface,
            name: signal.name,
            values: signal.values);
}

/// Signal data for org.freedesktop.Avahi.ServiceTypeBrowser.ItemRemove.
class AvahiServiceTypeBrowserItemRemove extends DBusSignal {
  int get interfaceValue => (values[0] as DBusInt32).value;

  int get protocol => (values[1] as DBusInt32).value;

  String get type => (values[2] as DBusString).value;

  String get domain => (values[3] as DBusString).value;

  int get flags => (values[4] as DBusUint32).value;

  AvahiServiceTypeBrowserItemRemove(DBusSignal signal)
      : super(
            sender: signal.sender,
            path: signal.path,
            interface: signal.interface,
            name: signal.name,
            values: signal.values);
}

/// Signal data for org.freedesktop.Avahi.ServiceTypeBrowser.Failure.
class AvahiServiceTypeBrowserFailure extends DBusSignal {
  String get error => (values[0] as DBusString).value;

  AvahiServiceTypeBrowserFailure(DBusSignal signal)
      : super(
            sender: signal.sender,
            path: signal.path,
            interface: signal.interface,
            name: signal.name,
            values: signal.values);
}

/// Signal data for org.freedesktop.Avahi.ServiceTypeBrowser.AllForNow.
class AvahiServiceTypeBrowserAllForNow extends DBusSignal {
  AvahiServiceTypeBrowserAllForNow(DBusSignal signal)
      : super(
            sender: signal.sender,
            path: signal.path,
            interface: signal.interface,
            name: signal.name,
            values: signal.values);
}

/// Signal data for org.freedesktop.Avahi.ServiceTypeBrowser.CacheExhausted.
class AvahiServiceTypeBrowserCacheExhausted extends DBusSignal {
  AvahiServiceTypeBrowserCacheExhausted(DBusSignal signal)
      : super(
            sender: signal.sender,
            path: signal.path,
            interface: signal.interface,
            name: signal.name,
            values: signal.values);
}

class AvahiServiceTypeBrowser extends DBusRemoteObject {
  /// Stream of org.freedesktop.Avahi.ServiceTypeBrowser.ItemNew signals.
  late final Stream<AvahiServiceTypeBrowserItemNew> itemNew;

  /// Stream of org.freedesktop.Avahi.ServiceTypeBrowser.ItemRemove signals.
  late final Stream<AvahiServiceTypeBrowserItemRemove> itemRemove;

  /// Stream of org.freedesktop.Avahi.ServiceTypeBrowser.Failure signals.
  late final Stream<AvahiServiceTypeBrowserFailure> failure;

  /// Stream of org.freedesktop.Avahi.ServiceTypeBrowser.AllForNow signals.
  late final Stream<AvahiServiceTypeBrowserAllForNow> allForNow;

  /// Stream of org.freedesktop.Avahi.ServiceTypeBrowser.CacheExhausted signals.
  late final Stream<AvahiServiceTypeBrowserCacheExhausted> cacheExhausted;

  AvahiServiceTypeBrowser(
      DBusClient client, String destination, DBusObjectPath path)
      : super(client, name: destination, path: path) {
    itemNew = DBusRemoteObjectSignalStream(
            object: this,
            interface: 'org.freedesktop.Avahi.ServiceTypeBrowser',
            name: 'ItemNew',
            signature: DBusSignature('iissu'))
        .asBroadcastStream()
        .map((signal) => AvahiServiceTypeBrowserItemNew(signal));

    itemRemove = DBusRemoteObjectSignalStream(
            object: this,
            interface: 'org.freedesktop.Avahi.ServiceTypeBrowser',
            name: 'ItemRemove',
            signature: DBusSignature('iissu'))
        .asBroadcastStream()
        .map((signal) => AvahiServiceTypeBrowserItemRemove(signal));

    failure = DBusRemoteObjectSignalStream(
            object: this,
            interface: 'org.freedesktop.Avahi.ServiceTypeBrowser',
            name: 'Failure',
            signature: DBusSignature('s'))
        .asBroadcastStream()
        .map((signal) => AvahiServiceTypeBrowserFailure(signal));

    allForNow = DBusRemoteObjectSignalStream(
            object: this,
            interface: 'org.freedesktop.Avahi.ServiceTypeBrowser',
            name: 'AllForNow',
            signature: DBusSignature(''))
        .asBroadcastStream()
        .map((signal) => AvahiServiceTypeBrowserAllForNow(signal));

    cacheExhausted = DBusRemoteObjectSignalStream(
            object: this,
            interface: 'org.freedesktop.Avahi.ServiceTypeBrowser',
            name: 'CacheExhausted',
            signature: DBusSignature(''))
        .asBroadcastStream()
        .map((signal) => AvahiServiceTypeBrowserCacheExhausted(signal));
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

  /// Invokes org.freedesktop.Avahi.ServiceTypeBrowser.Free()
  Future<void> callFree(
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.Avahi.ServiceTypeBrowser', 'Free', [],
        replySignature: DBusSignature(''),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.Avahi.ServiceTypeBrowser.Start()
  Future<void> callStart(
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.Avahi.ServiceTypeBrowser', 'Start', [],
        replySignature: DBusSignature(''),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
  }
}
