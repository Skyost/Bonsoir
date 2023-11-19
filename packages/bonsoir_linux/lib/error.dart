/// Represents a Bonsoir error triggered on the Linux platform.
class AvahiBonsoirError implements Exception {
  /// The message.
  final String message;

  /// The (possibly null) error code / message.
  final Object? error;

  /// Creates a new Avahi Bonsoir error instance.
  AvahiBonsoirError(this.message, [this.error]);

  @override
  String toString() {
    String string = 'AvahiBonsoirError';
    if (error != null) {
      string += '(${error})';
    }
    string += ' : $message';
    return string;
  }
}