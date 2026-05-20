/// Represents a Bonsoir error triggered on the Linux platform.
class BonsoirLinuxError implements Exception {
  /// The message.
  final String message;

  /// The (possibly null) error code / message.
  final Object? details;

  /// Creates a new Avahi Bonsoir error instance.
  BonsoirLinuxError(this.message, [this.details]);

  @override
  String toString() {
    String string = 'BonsoirLinuxError';
    if (details != null) {
      string += '($details)';
    }
    string += ' : $message';
    return string;
  }
}
