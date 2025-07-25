import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';

/// Allows to handle a Bonsoir action.
class BonsoirActionHandler<T extends BonsoirEvent> {
  /// The event source abstraction.
  final BonsoirAction<T> _action;

  /// Creates a new Bonsoir discovery instance.
  const BonsoirActionHandler({
    required BonsoirAction<T> action,
  }) : _action = action;

  /// The initialize method, that should be called before starting the action.
  /// Await this method to know when the plugin will be ready.
  Future<void> initialize() => _action.initialize();

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
