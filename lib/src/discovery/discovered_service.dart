import 'package:bonsoir/src/service.dart';
import 'package:flutter/material.dart';

/// Represents a discovered Bonsoir service.
class DiscoveredBonsoirService extends BonsoirService {
  /// The service ip (can be found if unresolved).
  final String ip;

  /// Creates a new discovered Bonsoir service.
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

  /// Creates a new discovered Bonsoir service instance from the given JSON map.
  DiscoveredBonsoirService.fromJson(Map<String, dynamic> json)
      : this(
          name: json['name'],
          type: json['type'],
          port: json['port'],
          ip: json['ip'],
        );

  @override
  Map<String, dynamic> toJson() => super.toJson()..['ip'] = ip;

  @override
  bool operator ==(dynamic other) {
    if (other is! DiscoveredBonsoirService) {
      return false;
    }
    return super == other && this.ip == ip;
  }

  @override
  int get hashCode => super.hashCode + (ip?.hashCode ?? -1);
}
