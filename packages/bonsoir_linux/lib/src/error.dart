/// Represents a Bonsoir error triggered on the Linux platform.
class BonsoirLinuxError implements Exception {
  /// The message.
  final String message;

  /// The (possibly null) error code / message.
  final Object? error;

  /// Creates a new Avahi Bonsoir error instance.
  BonsoirLinuxError(this.message, [this.error]);

  @override
  String toString() {
    String string = 'BonsoirLinuxError';
    if (error != null) {
      string += '(${error})';
    }
    string += ' : $message';
    return string;
  }
}