import 'dart:convert';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';

/// Represents a broadcastable network service.
class BonsoirService {
  /// The service name. Should represent what you want to advertise.
  /// This name is subject to change based on conflicts with other services advertised on the same network.
  final String name;

  /// The service type.
  ///
  /// Syntax :
  /// ```
  /// _ServiceType._TransportProtocolName.
  /// ```
  ///
  /// Note especially :
  /// * Each part must start with an underscore, '_'.
  /// * The second part only allows '_tcp' or _'udp'.
  ///
  /// Commons examples are :
  /// ```
  /// _scanner._tcp
  /// _http._tcp
  /// _webdave._tcp
  /// _tftp._udp
  /// ```
  ///
  /// Source : [Understanding Zeroconf Service Types](http://wiki.ros.org/zeroconf/Tutorials/Understanding%20Zeroconf%20Service%20Types).
  final String type;

  /// The service port.
  /// Your service should be reachable at the given port using the protocol specified in [type].
  final int port;

  /// Creates a new Bonsoir service instance.
  const BonsoirService({
    @required this.name,
    @required this.type,
    @required this.port,
  });

  /// Creates a new Bonsoir service instance from the given JSON map.
  factory BonsoirService.fromJson(Map<String, dynamic> json, {String prefix = 'service.'}) {
    if (json.containsKey('${prefix}ip')) {
      return ResolvedBonsoirService.fromJson(json, prefix: prefix);
    }
    return BonsoirService(
      name: json['${prefix}name'],
      type: json['${prefix}type'],
      port: json['${prefix}port'],
    );
  }

  /// Converts this JSON service to a JSON map.
  Map<String, dynamic> toJson({String prefix = 'service.'}) => {
        '${prefix}name': name,
        '${prefix}type': type,
        '${prefix}port': port,
      };

  @override
  bool operator ==(dynamic other) {
    if (other is! BonsoirService) {
      return false;
    }
    return identical(this, other) ||
        (this.name == name && this.type == type && this.port == port);
  }

  @override
  int get hashCode => name.hashCode + type.hashCode + port;

  @override
  String toString() => jsonEncode(toJson());
}
