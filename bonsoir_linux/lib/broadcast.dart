import 'dart:async';

import 'package:bonsoir_linux/avahi_defs/constants.dart';
import 'package:bonsoir_linux/avahi_defs/entry_group.dart';
import 'package:bonsoir_linux/avahi_defs/server.dart';
import 'package:bonsoir_linux/events.dart';
import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:dbus/dbus.dart';

class AvahiBonsoirBroadcast extends AvahiBonsoirEvents<BonsoirBroadcastEvent> {
  // Service received from Bonsoir
  final BonsoirService service;
  late AvahiServer server;

  // Receives service from Bonsoir, and sends printLogs to superclass.
  AvahiBonsoirBroadcast(this.service, printLogs) : super(printLogs);

  late AvahiEntryGroup _entryGroup;

  Map<String, StreamSubscription> _subscriptions = {};

  @override
  Future<void> get ready async {
    server = AvahiServer(
      busClient,
      'org.freedesktop.Avahi',
      DBusObjectPath('/'),
    );
    _entryGroup = AvahiEntryGroup(
      busClient,
      'org.freedesktop.Avahi',
      DBusObjectPath(
        await server.callEntryGroupNew(),
      ),
    );
    await sendServiceToAvahi(this.service);
    controller = StreamController();
  }

  @override
  Future<void> start() async {
    _subscriptions['StateChanged'] = _entryGroup.stateChanged.listen((event) {
      switch (event.state.toAvahiEntryGroupState()) {
        case AvahiEntryGroupState.AVAHI_ENTRY_GROUP_UNCOMMITED:
        case AvahiEntryGroupState.AVAHI_ENTRY_GROUP_REGISTERING:
          break;
        case AvahiEntryGroupState.AVAHI_ENTRY_GROUP_ESTABLISHED:
          controller!.add(BonsoirBroadcastEvent(
              type: BonsoirBroadcastEventType.broadcastStarted,
              service: service));
          break;
        case AvahiEntryGroupState.AVAHI_ENTRY_GROUP_COLLISION:
          dbgPrint("Service name collision!");
          controller!.add(BonsoirStaticClasses.unknownEvent);
          server.callGetAlternativeServiceName(service.name).then(
                (newName) => _entryGroup.callReset().then(
                      (_) => sendServiceToAvahi(
                        service.copyWith(name: newName),
                      ),
                    ),
              );
          break;
        case AvahiEntryGroupState.AVAHI_ENTRY_GROUP_FAILURE:
          dbgPrint("Received failure: ${event.error}");
          controller!.add(BonsoirStaticClasses.unknownEvent);
          break;
        default:
          dbgPrint("Received Unknown state with value ${event.state}");
          controller!.add(BonsoirStaticClasses.unknownEvent);
      }
    });
    await _entryGroup.callCommit();
  }

  Future<void> sendServiceToAvahi(BonsoirService svc) {
    return _entryGroup.callAddService(
        interface: AvahiIfIndexUnspecified,
        protocol: AvahiProtocolUnspecified,
        flags: 0,
        name: svc.name,
        type: svc.type,
        domain: '',
        host: '',
        port: svc.port,
        txt: service.attributes != null
            ? AvahiBonsoirEvents.convertAttributesToTxtRecord(
                service.attributes!)
            : []);
  }

  @override
  Future<void> stop() async {
    for (var entries in _subscriptions.entries) {
      entries.value.cancel();
    }
    await _entryGroup.callFree();
    controller!.add(BonsoirBroadcastEvent(
        type: BonsoirBroadcastEventType.broadcastStopped));
    super.stop();
  }

  @override
  Map<String, dynamic> toJson() {
    return {'id': _entryGroup.path.toString(), 'printLogs': printLogs};
  }
}
