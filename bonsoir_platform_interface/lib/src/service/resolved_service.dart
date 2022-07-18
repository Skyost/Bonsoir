import 'package:bonsoir_platform_interface/src/service/service.dart';

/// Represents a resolved Bonsoir service.
class ResolvedBonsoirService extends BonsoirService {
  /// The service ip.
  final String? ip;

  /// Creates a new resolved Bonsoir service.
  const ResolvedBonsoirService({
    required super.name,
    required super.type,
    required super.port,
    super.attributes,
    required this.ip,
  });

  /// Creates a new resolved Bonsoir service instance from the given JSON map.
  ResolvedBonsoirService.fromJson(
    Map<String, dynamic> json, {
    String prefix = 'service.',
  }) : this(
          name: json['${prefix}name'],
          type: json['${prefix}type'],
          port: json['${prefix}port'],
          attributes: Map<String, String>.from(json['${prefix}attributes']),
          ip: json['${prefix}ip'],
        );

  @override
  Map<String, dynamic> toJson({String prefix = 'service.'}) =>
      super.toJson(prefix: prefix)..['${prefix}ip'] = ip;

  @override
  bool operator ==(dynamic other) {
    if (other is! ResolvedBonsoirService) {
      return false;
    }
    return super == other && ip == other.ip;
  }

  @override
  int get hashCode => super.hashCode + (ip?.hashCode ?? -1);
}
