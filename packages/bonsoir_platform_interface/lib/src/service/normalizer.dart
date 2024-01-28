import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Contains various methods that helps conforming to RFC 6335 and RFC 6763.
class BonsoirServiceNormalizer {
  /// The default service name.
  static const String defaultServiceName = 'My service';

  /// The default service type.
  static const String defaultServiceType = '_my-service._tcp';

  /// Normalizes a given service [name].
  ///
  /// Reference : [RFC G7G3](https://datatracker.ietf.org/doc/html/rfc6763#section-4.1.1).
  static String normalizeName(String name) {
    String result = name;

    // Service names MUST NOT contain ASCII control characters (byte values 0x00-0x1F and 0x7F).
    result.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

    // On some platforms (eg. Windows), services name are not correctly handled if they're ending with a dot.
    if (name.endsWith('.')) {
      if (kDebugMode) {
        print("It seems that you've provided a service name ending with a dot : $name.");
        print("Note that it's not correctly handled on all platforms (eg. Windows).");
        print('Please consider removing the trailing dot of your service name.');
      }
    }

    return result.isEmpty ? defaultServiceName : result;
  }

  /// Normalizes a given service [type].
  ///
  /// References :
  /// * [RFC 6335](https://datatracker.ietf.org/doc/html/rfc6335#section-5.1);
  /// * [RFC 6763](https://datatracker.ietf.org/doc/html/rfc6763#section-7).
  static String normalizeType(String type) {
    List<String> parts = type.split('.');
    if (parts.length != 2) {
      return defaultServiceType;
    }

    // Extracts the second part.
    String secondPart = parts.last;

    // For applications using any transport protocol other than TCP, the second label is "_udp".
    if (secondPart != '_tcp') {
      secondPart = '_udp';
    }

    // Extracts the first part.
    String firstPart = parts.first;
    if (firstPart.startsWith('_')) {
      firstPart = firstPart.substring(1, firstPart.length);
    }

    // Service types MUST NOT begin with a hyphen.
    while (firstPart.startsWith('-')) {
      firstPart = firstPart.substring(1, firstPart.length);
    }

    // Service types MUST NOT end with a hyphen.
    while (firstPart.endsWith('-')) {
      firstPart = firstPart.substring(0, firstPart.length - 1);
    }

    // Hyphens must not be adjacent to other hyphens.
    firstPart = firstPart.replaceAll(RegExp(r'-+'), '-');

    // Service types MUST contain only US-ASCII [ANSI.X3.4-1986] letters 'A' - 'Z' and 'a' - 'z', digits '0' - '9', and hyphens ('-', ASCII 0x2D or decimal 45).
    firstPart = firstPart.replaceAll(RegExp(r'[^a-zA-Z0-9-]'), '');

    // Service types MUST be no more than 15 characters long.
    if (firstPart.length > 15) {
      firstPart = firstPart.substring(0, 15);
    }

    // Service types MUST be at least 1 character and MUST contain at least one letter ('A' - 'Z' or 'a' - 'z').
    if (firstPart.isEmpty || !firstPart.contains(RegExp(r'[A-Za-z]'))) {
      return defaultServiceType;
    }

    return '_$firstPart.$secondPart';
  }

  /// Normalizes a given service [attributes].
  ///
  /// Reference : [RFC 6763](https://datatracker.ietf.org/doc/html/rfc6763#section-6).
  static Map<String, String> normalizeAttributes(Map<String, String> attributes, { bool limitKeyLength = false }) {
    Map<String, String> result = <String, String>{};

    for (MapEntry<String, String> entry in attributes.entries) {
      String key = entry.key;
      // The characters of a key MUST be printable US-ASCII values (0x20-0x7E) excluding '=' (0x3D).
      key = key.replaceAll(RegExp(r'[^\x21-\x7E]'), '');
      key = key.replaceAll('=', '');

      // The key SHOULD be no more than nine characters long.
      if (limitKeyLength && key.length >= 9) {
        key = key.substring(0, 9);
      }

      // Each constituent string of a DNS TXT record is limited to 255 bytes.
      String value = entry.value;
      while (utf8.encode('$key=$value').length > 255) {
        value = value.substring(0, value.length - 1);
      }

      // The key MUST be at least one character.
      if (key.isNotEmpty) {
        result[key] = value;
      }
    }

    return result;
  }
}
