import 'dart:convert';

import 'package:bonsoir_platform_interface/src/actions/action.dart';
import 'package:bonsoir_platform_interface/src/service/resolved_service.dart';
import 'package:flutter/foundation.dart';

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
  /// * The second part only allows '_tcp' or '_udp'.
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

  /// The service attributes.
  /// The key must be US-ASCII printable characters, excluding the '=' character.
  /// Values may be UTF-8 strings or null. The total length of key + value must be less than 255 bytes.
  ///
  /// Source : [`setAttribute` on Android Developers](https://developer.android.com/reference/android/net/nsd/NsdServiceInfo#setAttribute(java.lang.String,%20java.lang.String)).
  final Map<String, String>? attributes;

  /// Creates a new Bonsoir service instance.
  const BonsoirService({
    required this.name,
    required this.type,
    required this.port,
    this.attributes,
  });

  /// Creates a new Bonsoir service instance from the given JSON map.
  factory BonsoirService.fromJson(
    Map<String, dynamic> json, {
    String prefix = 'service.',
  }) {
    if (json['${prefix}ip'] != null) {
      return ResolvedBonsoirService.fromJson(json, prefix: prefix);
    }
    return BonsoirService(
      name: json['${prefix}name'],
      type: json['${prefix}type'],
      port: json['${prefix}port'],
      attributes: Map<String, String>.from(json['${prefix}attributes']),
    );
  }

  /// Converts this JSON service to a JSON map.
  Map<String, dynamic> toJson({String prefix = 'service.'}) => {
        '${prefix}name': name,
        '${prefix}type': type,
        '${prefix}port': port,
        '${prefix}attributes': attributes ?? {},
      };

  /// Tries to resolve this service.
  Future<void> resolve(ServiceResolver resolver) => resolver.resolveService(this);

  @override
  bool operator ==(dynamic other) {
    if (other is! BonsoirService) {
      return false;
    }
    return identical(this, other) || (name == other.name && type == other.type && port == other.port && mapEquals<String, String>(attributes, other.attributes));
  }

  @override
  int get hashCode => name.hashCode + type.hashCode + port;

  @override
  String toString() => jsonEncode(toJson());
}
