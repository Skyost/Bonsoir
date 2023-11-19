enum AvahiClientState {
  AVAHI_CLIENT_S_REGISTERING,
  AVAHI_CLIENT_S_RUNNING,
  AVAHI_CLIENT_S_COLLISION,
  AVAHI_CLIENT_FAILURE,
  AVAHI_CLIENT_CONNECTING
}

enum AvahiEntryGroupState {
  AVAHI_ENTRY_GROUP_UNCOMMITED,
  AVAHI_ENTRY_GROUP_REGISTERING,
  AVAHI_ENTRY_GROUP_ESTABLISHED,
  AVAHI_ENTRY_GROUP_COLLISION,
  AVAHI_ENTRY_GROUP_FAILURE
}

enum AvahiProtocol { AVAHI_PROTO_INET, AVAHI_PROTO_INET6, AVAHI_PROTO_UNSPEC }

extension AvahiProtocolHelpers on AvahiProtocol {
  static Map<AvahiProtocol, int> avahiProtocolToInt = AvahiIntHelpers
      .intToAvahiProtocol
      .map((key, value) => MapEntry(value, key));

  int? toInt() => AvahiProtocolHelpers.avahiProtocolToInt[this];
}

extension AvahiClientStateHelpers on AvahiClientState {
  static Map<AvahiClientState, int> acsToInt = {
    AvahiClientState.AVAHI_CLIENT_S_REGISTERING: 1,
    AvahiClientState.AVAHI_CLIENT_S_RUNNING: 2,
    AvahiClientState.AVAHI_CLIENT_S_COLLISION: 3,
    AvahiClientState.AVAHI_CLIENT_FAILURE: 100,
    AvahiClientState.AVAHI_CLIENT_CONNECTING: 101
  };
  static Map<int, AvahiClientState> intToAcs =
      Map.fromEntries(acsToInt.entries.map((e) => MapEntry(e.value, e.key)));

  int? toInt() => acsToInt[this];
}

extension AvahiEntryGroupStateHelpers on AvahiEntryGroupState {
  static Map<AvahiEntryGroupState, int> aegsToInt = AvahiEntryGroupState.values
      .asMap()
      .map((key, value) => MapEntry(value, key));

  int? toInt() => aegsToInt[this];
}

extension AvahiIntHelpers on int {
  AvahiClientState? toAvahiClientState() =>
      AvahiClientStateHelpers.intToAcs[this];

  AvahiEntryGroupState? toAvahiEntryGroupState() =>
      AvahiEntryGroupState.values.asMap()[this];

  static Map<int, AvahiProtocol> intToAvahiProtocol =
      Map.from(AvahiProtocol.values.asMap())
        ..remove(2)
        ..[-1] = AvahiProtocol.AVAHI_PROTO_UNSPEC;

  AvahiProtocol? toAvahiProtocol() => AvahiIntHelpers.intToAvahiProtocol[this];
}

const AvahiIfIndexUnspecified = -1;

const AvahiProtocolUnspecified = -1;
