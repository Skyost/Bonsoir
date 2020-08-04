import 'dart:convert';

import 'package:flutter/material.dart';

class BonsoirService {
  final String name;
  final String type;
  final int port;

  const BonsoirService({
    @required this.name,
    @required this.type,
    @required this.port,
  });

  BonsoirService.fromJson(Map<String, dynamic> json)
      : this(
          name: json['name'],
          type: json['type'],
          port: json['port'],
        );

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'port': port,
      };

  @override
  bool operator ==(dynamic other) {
    if (other is! BonsoirService) {
      return false;
    }
    return identical(this, other) || (this.name == name && this.type == type && this.port == port);
  }

  @override
  int get hashCode => toJson().hashCode;

  @override
  String toString() => jsonEncode(toJson());
}
