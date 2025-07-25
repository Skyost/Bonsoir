import 'dart:async';

import 'package:bonsoir_linux/bonsoir_linux.dart';
import 'package:bonsoir_linux/src/actions/action.dart';
import 'package:bonsoir_linux/src/avahi/constants.dart';
import 'package:bonsoir_linux/src/avahi/entry_group.dart';
import 'package:bonsoir_linux/src/avahi/server.dart';
import 'package:bonsoir_linux/src/service.dart';
import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:dbus/dbus.dart';

/// Broadcasts a given [service] on the network.
class AvahiBonsoirBroadcast extends AvahiBonsoirAction<BonsoirBroadcastEvent> {
  /// The service to broadcast.
  BonsoirService service;

  /// The Avahi server instance.
  AvahiServer? _server;

  /// The Avahi entry group.
  AvahiEntryGroup? _entryGroup;

  /// Creates a new Avahi Bonsoir broadcast instance.
  AvahiBonsoirBroadcast({
    required this.service,
    required super.printLogs,
  }) : super(
         action: 'broadcast',
         logMessages: BonsoirPlatformInterfaceLogMessages.broadcastMessages,
       );

  @override
  Future<void> initialize() async {
    if (_entryGroup == null) {
      _server = AvahiServer(busClient, BonsoirLinux.avahi, DBusObjectPath('/'));
      _entryGroup = AvahiEntryGroup(busClient, BonsoirLinux.avahi, DBusObjectPath(await _server!.callEntryGroupNew()));
      await _sendServiceToAvahi();
    }
  }

  @override
  Future<void> start() async {
    await super.start();
    registerSubscription(_entryGroup!.stateChanged.listen(_onEntryGroupEvent));
    await _entryGroup!.callCommit();
  }

  /// Triggered when an entry group event occurs.
  Future<void> _onEntryGroupEvent(AvahiEntryGroupStateChanged event) async {
    switch (event.state.toAvahiEntryGroupState()) {
      case AvahiEntryGroupState.AVAHI_ENTRY_GROUP_UNCOMMITED:
      case AvahiEntryGroupState.AVAHI_ENTRY_GROUP_REGISTERING:
        break;
      case AvahiEntryGroupState.AVAHI_ENTRY_GROUP_ESTABLISHED:
        onEvent(
          BonsoirBroadcastStartedEvent(service: service),
          parameters: [service.description],
        );
        break;
      case AvahiEntryGroupState.AVAHI_ENTRY_GROUP_COLLISION:
        String newName = await _server!.callGetAlternativeServiceName(service.name);
        await _entryGroup!.callReset();
        String name = service.name;
        service = service.copyWith(name: newName);
        onEvent(
          BonsoirBroadcastNameAlreadyExistsEvent(service: service),
          parameters: [service.description, name],
        );
        _sendServiceToAvahi();
        break;
      case AvahiEntryGroupState.AVAHI_ENTRY_GROUP_FAILURE:
        onError(details: event.error);
        break;
      default:
        onEvent(
          const BonsoirBroadcastUnknownEvent(),
          message: 'Bonsoir broadcast has received a unknown state with value ${event.state}.',
        );
    }
  }

  /// Sends the current service to Avahi.
  Future<void> _sendServiceToAvahi() async {
    await _entryGroup!.callAddService(
      interface: AvahiIfIndexUnspecified,
      protocol: AvahiProtocolUnspecified,
      flags: 0,
      name: service.name,
      type: service.type,
      domain: '',
      host: service.host ?? '',
      port: service.port,
      txt: service.txtRecord,
    );
  }

  @override
  Future<void> stop() async {
    cancelSubscriptions();
    await _entryGroup!.callFree();
    onEvent(
      BonsoirBroadcastStoppedEvent(service: service),
      parameters: [service.description],
    );
    super.stop();
  }
}
