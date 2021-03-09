import 'package:bonsoir_platform_interface/src/events/event.dart';

/// This class serves as the stream source for the implementations to override.
abstract class BonsoirAction<T extends BonsoirEvent> {
  /// Regular event stream.
  Stream<T>? get eventStream;

  /// The ready getter, that returns when the platform is ready for the operation requested.
  Future<void> get ready;

  /// This starts the required action (eg. Discovery, or Broadcast).
  Future<void> start();

  /// This stops the action (eg. stops discovery or broadcast).
  Future<void> stop();

  /// This returns whether the platform is ready for this event.
  bool get isReady;

  /// This returns whether the platform has discarded this event.
  bool get isStopped;

  /// This returns a JSON representation of the event.
  Map<String, dynamic> toJson();
}
