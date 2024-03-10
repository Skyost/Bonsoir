import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';

/// Allows to handle a Bonsoir action.
class BonsoirActionHandler<T extends BonsoirEvent> {
  /// The event source abstraction.
  final BonsoirAction<T> _action;

  /// Creates a new Bonsoir discovery instance.
  const BonsoirActionHandler({
    required BonsoirAction<T> action,
  }) : _action = action;

  /// The ready getter, that returns when the platform is ready for the action.
  Future<void> get ready async => _action.ready;

  /// This returns whether the platform is ready for the action.
  bool get isReady => _action.isReady;

  /// Returns whether the action has been stopped.
  bool get isStopped => _action.isStopped;

  /// Starts the action.
  Future<void> start() => _action.start();

  /// Stops the action.
  Future<void> stop() => _action.stop();

  /// Regular event stream.
  Stream<T>? get eventStream => _action.eventStream;
}
