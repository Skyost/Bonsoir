// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object org.freedesktop.Avahi.Server.xml

import 'dart:convert' show utf8;

import 'package:bonsoir_linux/src/avahi/constants.dart';
import 'package:dbus/dbus.dart';

/// Return value of org.freedesktop.Avahi.Server.ResolveService.
class AvahiServerResolvedService extends DBusStruct {
  final List<DBusValue> values;

  AvahiServerResolvedService(Iterable<DBusValue> children)
      : values = children.toList(),
        super(children);

  int get interface => (values[0] as DBusInt32).value;

  AvahiProtocol? get protocol =>
      (values[1] as DBusInt32).value.toAvahiProtocol();

  String get name => (values[2] as DBusString).value;

  String get type => (values[3] as DBusString).value;

  String get domain => (values[4] as DBusString).value;

  String get host => (values[5] as DBusString).value;

  AvahiProtocol? get aprotocol =>
      (values[6] as DBusInt32).value.toAvahiProtocol();

  String get address => (values[7] as DBusString).value;

  int get port => (values[8] as DBusUint16).value;

  List<String> get txt => (values[9] as DBusArray)
      .children
      .map((child) => (child as DBusArray)
          .children
          .map((child) => (child as DBusByte).value)
          .toList())
      .map((e) => utf8.decode(e))
      .toList();

  int get flags => (values[10] as DBusUint32).value;
}

/// Signal data for org.freedesktop.Avahi.Server.StateChanged.
class AvahiServerStateChanged extends DBusSignal {
  int get state => (values[0] as DBusInt32).value;

  String get error => (values[1] as DBusString).value;

  AvahiServerStateChanged(DBusSignal signal)
      : super(
            sender: signal.sender,
            path: signal.path,
            interface: signal.interface,
            name: signal.name,
            values: signal.values);
}

class AvahiServer extends DBusRemoteObject {
  /// Stream of org.freedesktop.Avahi.Server.StateChanged signals.
  late final Stream<AvahiServerStateChanged> stateChanged;

  AvahiServer(DBusClient client, String destination, DBusObjectPath path)
      : super(client, name: destination, path: path) {
    stateChanged = DBusRemoteObjectSignalStream(
            object: this,
            interface: 'org.freedesktop.Avahi.Server',
            name: 'StateChanged',
            signature: DBusSignature('is'))
        .asBroadcastStream()
        .map((signal) => AvahiServerStateChanged(signal));
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

  /// Invokes org.freedesktop.Avahi.Server.GetVersionString()
  Future<String> callGetVersionString(
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server', 'GetVersionString', [],
        replySignature: DBusSignature('s'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusString).value;
  }

  /// Invokes org.freedesktop.Avahi.Server.GetAPIVersion()
  Future<int> callGetAPIVersion(
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server', 'GetAPIVersion', [],
        replySignature: DBusSignature('u'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusUint32).value;
  }

  /// Invokes org.freedesktop.Avahi.Server.GetHostName()
  Future<String> callGetHostName(
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server', 'GetHostName', [],
        replySignature: DBusSignature('s'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusString).value;
  }

  /// Invokes org.freedesktop.Avahi.Server.SetHostName()
  Future<void> callSetHostName(String name,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    await callMethod(
        'org.freedesktop.Avahi.Server', 'SetHostName', [DBusString(name)],
        replySignature: DBusSignature(''),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.Avahi.Server.GetHostNameFqdn()
  Future<String> callGetHostNameFqdn(
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server', 'GetHostNameFqdn', [],
        replySignature: DBusSignature('s'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusString).value;
  }

  /// Invokes org.freedesktop.Avahi.Server.GetDomainName()
  Future<String> callGetDomainName(
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server', 'GetDomainName', [],
        replySignature: DBusSignature('s'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusString).value;
  }

  /// Invokes org.freedesktop.Avahi.Server.IsNSSSupportAvailable()
  Future<bool> callIsNSSSupportAvailable(
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server', 'IsNSSSupportAvailable', [],
        replySignature: DBusSignature('b'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusBoolean).value;
  }

  /// Invokes org.freedesktop.Avahi.Server.GetState()
  Future<int> callGetState(
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server', 'GetState', [],
        replySignature: DBusSignature('i'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusInt32).value;
  }

  /// Invokes org.freedesktop.Avahi.Server.GetLocalServiceCookie()
  Future<int> callGetLocalServiceCookie(
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server', 'GetLocalServiceCookie', [],
        replySignature: DBusSignature('u'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusUint32).value;
  }

  /// Invokes org.freedesktop.Avahi.Server.GetAlternativeHostName()
  Future<String> callGetAlternativeHostName(String name,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server',
        'GetAlternativeHostName', [DBusString(name)],
        replySignature: DBusSignature('s'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusString).value;
  }

  /// Invokes org.freedesktop.Avahi.Server.GetAlternativeServiceName()
  Future<String> callGetAlternativeServiceName(String name,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server',
        'GetAlternativeServiceName', [DBusString(name)],
        replySignature: DBusSignature('s'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusString).value;
  }

  /// Invokes org.freedesktop.Avahi.Server.GetNetworkInterfaceNameByIndex()
  Future<String> callGetNetworkInterfaceNameByIndex(int index,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server',
        'GetNetworkInterfaceNameByIndex', [DBusInt32(index)],
        replySignature: DBusSignature('s'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusString).value;
  }

  /// Invokes org.freedesktop.Avahi.Server.GetNetworkInterfaceIndexByName()
  Future<int> callGetNetworkInterfaceIndexByName(String name,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server',
        'GetNetworkInterfaceIndexByName', [DBusString(name)],
        replySignature: DBusSignature('i'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusInt32).value;
  }

  /// Invokes org.freedesktop.Avahi.Server.ResolveHostName()
  Future<List<DBusValue>> callResolveHostName(
      int interface, int protocol, String name, int aprotocol, int flags,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server',
        'ResolveHostName',
        [
          DBusInt32(interface),
          DBusInt32(protocol),
          DBusString(name),
          DBusInt32(aprotocol),
          DBusUint32(flags)
        ],
        replySignature: DBusSignature('iisisu'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues;
  }

  /// Invokes org.freedesktop.Avahi.Server.ResolveAddress()
  Future<List<DBusValue>> callResolveAddress(
      int interface, int protocol, String address, int flags,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server',
        'ResolveAddress',
        [
          DBusInt32(interface),
          DBusInt32(protocol),
          DBusString(address),
          DBusUint32(flags)
        ],
        replySignature: DBusSignature('iiissu'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues;
  }

  /// Invokes org.freedesktop.Avahi.Server.ResolveService()
  Future<List<DBusValue>> callResolveService(
      {required int interface,
      required int protocol,
      required String name,
      required String type,
      required String domain,
      required int answerProtocol,
      required int flags,
      bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server',
        'ResolveService',
        [
          DBusInt32(interface),
          DBusInt32(protocol),
          DBusString(name),
          DBusString(type),
          DBusString(domain),
          DBusInt32(answerProtocol),
          DBusUint32(flags)
        ],
        replySignature: DBusSignature('iissssisqaayu'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues;
  }

  /// Invokes org.freedesktop.Avahi.Server.EntryGroupNew()
  Future<String> callEntryGroupNew(
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server', 'EntryGroupNew', [],
        replySignature: DBusSignature('o'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusObjectPath).value;
  }

  /// Invokes org.freedesktop.Avahi.Server.DomainBrowserNew()
  Future<String> callDomainBrowserNew(
      int interface, int protocol, String domain, int btype, int flags,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server',
        'DomainBrowserNew',
        [
          DBusInt32(interface),
          DBusInt32(protocol),
          DBusString(domain),
          DBusInt32(btype),
          DBusUint32(flags)
        ],
        replySignature: DBusSignature('o'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusObjectPath).value;
  }

  /// Invokes org.freedesktop.Avahi.Server.ServiceTypeBrowserNew()
  Future<String> callServiceTypeBrowserNew(
      int interface, int protocol, String domain, int flags,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server',
        'ServiceTypeBrowserNew',
        [
          DBusInt32(interface),
          DBusInt32(protocol),
          DBusString(domain),
          DBusUint32(flags)
        ],
        replySignature: DBusSignature('o'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusObjectPath).value;
  }

  /// Invokes org.freedesktop.Avahi.Server.ServiceBrowserNew()
  Future<String> callServiceBrowserNew({
    required int interface,
    required int protocol,
    required String type,
    required String domain,
    required int flags,
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server',
        'ServiceBrowserNew',
        [
          DBusInt32(interface),
          DBusInt32(protocol),
          DBusString(type),
          DBusString(domain),
          DBusUint32(flags)
        ],
        replySignature: DBusSignature('o'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusObjectPath).value;
  }

  /// Invokes org.freedesktop.Avahi.Server.ServiceResolverNew()
  Future<String> callServiceResolverNew(
      {required int interface,
      required int protocol,
      required String name,
      required String type,
      required String domain,
      required int aprotocol,
      required int flags,
      bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server',
        'ServiceResolverNew',
        [
          DBusInt32(interface),
          DBusInt32(protocol),
          DBusString(name),
          DBusString(type),
          DBusString(domain),
          DBusInt32(aprotocol),
          DBusUint32(flags)
        ],
        replySignature: DBusSignature('o'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusObjectPath).value;
  }

  /// Invokes org.freedesktop.Avahi.Server.HostNameResolverNew()
  Future<String> callHostNameResolverNew(
      {required int interface,
      required int protocol,
      required String name,
      required int answerProtocol,
      required int flags,
      bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server',
        'HostNameResolverNew',
        [
          DBusInt32(interface),
          DBusInt32(protocol),
          DBusString(name),
          DBusInt32(answerProtocol),
          DBusUint32(flags)
        ],
        replySignature: DBusSignature('o'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusObjectPath).value;
  }

  /// Invokes org.freedesktop.Avahi.Server.AddressResolverNew()
  Future<String> callAddressResolverNew(
      int interface, int protocol, String address, int flags,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server',
        'AddressResolverNew',
        [
          DBusInt32(interface),
          DBusInt32(protocol),
          DBusString(address),
          DBusUint32(flags)
        ],
        replySignature: DBusSignature('o'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusObjectPath).value;
  }

  /// Invokes org.freedesktop.Avahi.Server.RecordBrowserNew()
  Future<String> callRecordBrowserNew(
      int interface, int protocol, String name, int clazz, int type, int flags,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server',
        'RecordBrowserNew',
        [
          DBusInt32(interface),
          DBusInt32(protocol),
          DBusString(name),
          DBusUint16(clazz),
          DBusUint16(type),
          DBusUint32(flags)
        ],
        replySignature: DBusSignature('o'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusObjectPath).value;
  }
}
