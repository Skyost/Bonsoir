import 'dart:async';
import 'dart:convert' as conv;

import 'package:bonsoir_linux/avahi_defs/constants.dart';
import 'package:bonsoir_linux/avahi_defs/service_browser.dart';
import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:dbus/dbus.dart';
import 'package:meta/meta.dart';

extension LinuxAvahi on BonsoirService {
  BonsoirService copyWith({String? name, String? type, int? port, Map<String, dynamic>? attributes}) => BonsoirService(
        name: name ?? this.name,
        type: type ?? this.type,
        port: port ?? this.port,
        attributes: attributes as Map<String, String>? ?? this.attributes,
      );
}

extension BonsoirStaticClasses on BonsoirBroadcastEvent {
  static BonsoirBroadcastEvent get unknownEvent => BonsoirBroadcastEvent(type: BonsoirBroadcastEventType.unknown);
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

abstract class AvahiBonsoirEvents<T extends BonsoirEvent> extends BonsoirAction<T> {
  late final DBusClient busClient;
  final bool printLogs;
  bool _isStopped = false;
  StreamController<T>? controller;

  @override
  Stream<T>? get eventStream => controller?.stream;

  AvahiBonsoirEvents(this.printLogs, {DBusClient? client}) {
    if (client != null) {
      busClient = client;
    } else {
      busClient = DBusClient.system();
    }
  }

  @override
  bool get isReady => controller != null && !isStopped;

  @override
  bool get isStopped => _isStopped;

  static List<List<int>> convertAttributesToTxtRecord(Map<String, String> attributes) {
    return attributes.entries
        .map(
          (e) => "${e.key}=${e.value}",
        )
        .map(
          (str) => conv.utf8.encode(str),
        )
        .toList();
  }

  @override
  @mustCallSuper
  Future<void> stop() async {
    controller?.close();
    _isStopped = true;
  }

  void dbgPrint(Object? toPrint) {
    if (printLogs) {
      print(toPrint);
    }
  }
}
