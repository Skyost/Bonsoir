import 'package:bonsoir/src/service.dart';
import 'package:flutter/material.dart';

class DiscoveredBonsoirService extends BonsoirService {
  final String ip;

  const DiscoveredBonsoirService({
    @required String name,
    @required String type,
    @required int port,
    @required this.ip,
  }) : super(
          name: name,
          type: type,
          port: port,
        );

  DiscoveredBonsoirService.fromJson(Map<String, dynamic> json)
      : this(
          name: json['name'],
          type: json['type'],
          port: json['port'],
          ip: json['ip'],
        );

  Map<String, dynamic> toJson() => super.toJson()..['ip'] = ip;

  @override
  bool operator ==(dynamic other) {
    if (other is! DiscoveredBonsoirService) {
      return false;
    }
    return super == other && this.ip == ip;
  }
}
