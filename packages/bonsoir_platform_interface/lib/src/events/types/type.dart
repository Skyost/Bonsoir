/// A Bonsoir event type (broadcast or discovery).
mixin BonsoirEventType {
  /// Returns the type name.
  String get id => toString().split('.').last;
}