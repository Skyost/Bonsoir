import 'dart:convert';
import 'dart:typed_data';

import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';

/// Various useful functions for services.
extension BonsoirServiceUtils on BonsoirService {
  /// Returns a string describing the current service.
  String get description => jsonEncode(toJson(prefix: ''));

  /// Returns the TXT record of the current service.
  List<Uint8List> get txtRecord => attributes.entries.map((attribute) => utf8.encode('${attribute.key}=${attribute.value}')).toList();

  /// Returns the fully qualified domain name of the current service.
  String get fqdn => '$name.$type.local';
}
