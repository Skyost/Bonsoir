// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object org.freedesktop.Avahi.Server2.xml

import 'package:dbus/dbus.dart';

/// Signal data for org.freedesktop.Avahi.Server2.StateChanged.
class AvahiServer2StateChanged extends DBusSignal {
  int get state => (values[0] as DBusInt32).value;

  String get error => (values[1] as DBusString).value;

  AvahiServer2StateChanged(DBusSignal signal)
      : super(
            sender: signal.sender,
            path: signal.path,
            interface: signal.interface,
            name: signal.name,
            values: signal.values);
}

class AvahiServer2 extends DBusRemoteObject {
  /// Stream of org.freedesktop.Avahi.Server2.StateChanged signals.
  late final Stream<AvahiServer2StateChanged> stateChanged;

  AvahiServer2(DBusClient client, String destination, DBusObjectPath path)
      : super(client, name: destination, path: path) {
    stateChanged = DBusRemoteObjectSignalStream(
            object: this,
            interface: 'org.freedesktop.Avahi.Server2',
            name: 'StateChanged',
            signature: DBusSignature('is'))
        .map((signal) => AvahiServer2StateChanged(signal));
  }

  /// Invokes org.freedesktop.DBus.Introspectable.Introspect()
  Future<String> callIntrospect() async {
    var result = await callMethod(
        'org.freedesktop.DBus.Introspectable', 'Introspect', []);
    if (result.signature != DBusSignature('s')) {
      throw 'org.freedesktop.DBus.Introspectable.Introspect returned invalid values \${result.values}';
    }
    return (result.returnValues[0] as DBusString).value;
  }

  /// Invokes org.freedesktop.Avahi.Server2.GetVersionString()
  Future<String> callGetVersionString(
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server2', 'GetVersionString', [],
        replySignature: DBusSignature('s'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusString).value;
  }

  /// Invokes org.freedesktop.Avahi.Server2.GetAPIVersion()
  Future<int> callGetAPIVersion(
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server2', 'GetAPIVersion', [],
        replySignature: DBusSignature('u'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusUint32).value;
  }

  /// Invokes org.freedesktop.Avahi.Server2.GetHostName()
  Future<String> callGetHostName(
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server2', 'GetHostName', [],
        replySignature: DBusSignature('s'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusString).value;
  }

  /// Invokes org.freedesktop.Avahi.Server2.SetHostName()
  Future<void> callSetHostName(String name,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    await callMethod(
        'org.freedesktop.Avahi.Server2', 'SetHostName', [DBusString(name)],
        replySignature: DBusSignature(''),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.Avahi.Server2.GetHostNameFqdn()
  Future<String> callGetHostNameFqdn(
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server2', 'GetHostNameFqdn', [],
        replySignature: DBusSignature('s'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusString).value;
  }

  /// Invokes org.freedesktop.Avahi.Server2.GetDomainName()
  Future<String> callGetDomainName(
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server2', 'GetDomainName', [],
        replySignature: DBusSignature('s'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusString).value;
  }

  /// Invokes org.freedesktop.Avahi.Server2.IsNSSSupportAvailable()
  Future<bool> callIsNSSSupportAvailable(
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server2', 'IsNSSSupportAvailable', [],
        replySignature: DBusSignature('b'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusBoolean).value;
  }

  /// Invokes org.freedesktop.Avahi.Server2.GetState()
  Future<int> callGetState(
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server2', 'GetState', [],
        replySignature: DBusSignature('i'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusInt32).value;
  }

  /// Invokes org.freedesktop.Avahi.Server2.GetLocalServiceCookie()
  Future<int> callGetLocalServiceCookie(
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server2', 'GetLocalServiceCookie', [],
        replySignature: DBusSignature('u'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusUint32).value;
  }

  /// Invokes org.freedesktop.Avahi.Server2.GetAlternativeHostName()
  Future<String> callGetAlternativeHostName(String name,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server2',
        'GetAlternativeHostName', [DBusString(name)],
        replySignature: DBusSignature('s'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusString).value;
  }

  /// Invokes org.freedesktop.Avahi.Server2.GetAlternativeServiceName()
  Future<String> callGetAlternativeServiceName(String name,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server2',
        'GetAlternativeServiceName', [DBusString(name)],
        replySignature: DBusSignature('s'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusString).value;
  }

  /// Invokes org.freedesktop.Avahi.Server2.GetNetworkInterfaceNameByIndex()
  Future<String> callGetNetworkInterfaceNameByIndex(int index,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server2',
        'GetNetworkInterfaceNameByIndex', [DBusInt32(index)],
        replySignature: DBusSignature('s'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusString).value;
  }

  /// Invokes org.freedesktop.Avahi.Server2.GetNetworkInterfaceIndexByName()
  Future<int> callGetNetworkInterfaceIndexByName(String name,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.Avahi.Server2',
        'GetNetworkInterfaceIndexByName', [DBusString(name)],
        replySignature: DBusSignature('i'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusInt32).value;
  }

  /// Invokes org.freedesktop.Avahi.Server2.ResolveHostName()
  Future<List<DBusValue>> callResolveHostName(
      int interface, int protocol, String name, int aprotocol, int flags,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server2',
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

  /// Invokes org.freedesktop.Avahi.Server2.ResolveAddress()
  Future<List<DBusValue>> callResolveAddress(
      int interface, int protocol, String address, int flags,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server2',
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

  /// Invokes org.freedesktop.Avahi.Server2.ResolveService()
  Future<List<DBusValue>> callResolveService(int interface, int protocol,
      String name, String type, String domain, int aprotocol, int flags,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server2',
        'ResolveService',
        [
          DBusInt32(interface),
          DBusInt32(protocol),
          DBusString(name),
          DBusString(type),
          DBusString(domain),
          DBusInt32(aprotocol),
          DBusUint32(flags)
        ],
        replySignature: DBusSignature('iissssisqaayu'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues;
  }

  /// Invokes org.freedesktop.Avahi.Server2.EntryGroupNew()
  Future<String> callEntryGroupNew(
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server2', 'EntryGroupNew', [],
        replySignature: DBusSignature('o'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusObjectPath).value;
  }

  /// Invokes org.freedesktop.Avahi.Server2.DomainBrowserPrepare()
  Future<String> callDomainBrowserPrepare(
      int interface, int protocol, String domain, int btype, int flags,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server2',
        'DomainBrowserPrepare',
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

  /// Invokes org.freedesktop.Avahi.Server2.ServiceTypeBrowserPrepare()
  Future<String> callServiceTypeBrowserPrepare(
      int interface, int protocol, String domain, int flags,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server2',
        'ServiceTypeBrowserPrepare',
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

  /// Invokes org.freedesktop.Avahi.Server2.ServiceBrowserPrepare()
  Future<String> callServiceBrowserPrepare(
      int interface, int protocol, String type, String domain, int flags,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server2',
        'ServiceBrowserPrepare',
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

  /// Invokes org.freedesktop.Avahi.Server2.ServiceResolverPrepare()
  Future<String> callServiceResolverPrepare(int interface, int protocol,
      String name, String type, String domain, int aprotocol, int flags,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server2',
        'ServiceResolverPrepare',
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

  /// Invokes org.freedesktop.Avahi.Server2.HostNameResolverPrepare()
  Future<String> callHostNameResolverPrepare(
      int interface, int protocol, String name, int aprotocol, int flags,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server2',
        'HostNameResolverPrepare',
        [
          DBusInt32(interface),
          DBusInt32(protocol),
          DBusString(name),
          DBusInt32(aprotocol),
          DBusUint32(flags)
        ],
        replySignature: DBusSignature('o'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return (result.returnValues[0] as DBusObjectPath).value;
  }

  /// Invokes org.freedesktop.Avahi.Server2.AddressResolverPrepare()
  Future<String> callAddressResolverPrepare(
      int interface, int protocol, String address, int flags,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server2',
        'AddressResolverPrepare',
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

  /// Invokes org.freedesktop.Avahi.Server2.RecordBrowserPrepare()
  Future<String> callRecordBrowserPrepare(
      int interface, int protocol, String name, int clazz, int type, int flags,
      {bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
        'org.freedesktop.Avahi.Server2',
        'RecordBrowserPrepare',
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
