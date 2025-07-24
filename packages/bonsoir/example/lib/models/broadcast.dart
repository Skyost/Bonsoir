import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:bonsoir_example/models/app_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The broadcast service list provider.
final broadcastServiceListProvider = NotifierProvider.autoDispose<BonsoirBroadcastServiceListNotifier, List<BonsoirService>>(BonsoirBroadcastServiceListNotifier.new);

/// A model that allows to control the services to broadcast.
class BonsoirBroadcastServiceListNotifier extends AutoDisposeNotifier<List<BonsoirService>> {
  @override
  List<BonsoirService> build() {
    DefaultAppService.initialize().then((defaultAppService) => state = [DefaultAppService.service]);
    return [];
  }

  /// Adds a service to the list.
  void add(BonsoirService service) {
    state = [
      ...state,
      service,
    ];
  }

  /// Removes a service from the list.
  void remove(BonsoirService service) {
    state = [
      for (BonsoirService current in state)
        if (current.name != service.name) current,
    ];
  }
}

/// The broadcast service state provider.
final broadcastServiceStateProvider = AsyncNotifierProvider.autoDispose.family<BonsoirBroadcastServiceStateNotifier, BonsoirBroadcastState, BonsoirService>(BonsoirBroadcastServiceStateNotifier.new);

/// A model that allows report the broadcast state of a service.
class BonsoirBroadcastServiceStateNotifier extends AutoDisposeFamilyAsyncNotifier<BonsoirBroadcastState, BonsoirService> {
  @override
  FutureOr<BonsoirBroadcastState> build(BonsoirService arg) async {
    BonsoirBroadcast broadcast = BonsoirBroadcast(service: arg);
    await broadcast.ready;
    broadcast.eventStream?.listen(_onEventOccurred);
    ref.onDispose(broadcast.stop);
    broadcast.start();
    return BonsoirBroadcastReadyState(service: arg);
  }

  /// Handles the broadcast event.
  void _onEventOccurred(BonsoirBroadcastEvent event) {
    switch (event) {
      case BonsoirBroadcastStartedEvent():
        state = AsyncData(
          BonsoirBroadcastStartedState(
            service: event.service,
          ),
        );
        break;
      case BonsoirBroadcastStoppedEvent():
        state = AsyncData(
          BonsoirBroadcastStoppedState(
            service: event.service,
          ),
        );
        break;
      default:
        break;
    }
  }
}

/// Represents a Bonsoir action state.
sealed class BonsoirBroadcastState {
  /// The Bonsoir service.
  final BonsoirService service;

  /// Creates a new Bonsoir broadcast state instance.
  const BonsoirBroadcastState({
    required this.service,
  });
}

/// The Bonsoir broadcast ready state.
class BonsoirBroadcastReadyState extends BonsoirBroadcastState {
  /// Creates a new Bonsoir broadcast ready state instance.
  const BonsoirBroadcastReadyState({
    required super.service,
  });
}

/// The Bonsoir broadcast started state.
class BonsoirBroadcastStartedState extends BonsoirBroadcastState {
  /// Creates a new Bonsoir broadcast started state instance.
  const BonsoirBroadcastStartedState({
    required super.service,
  });
}

/// The Bonsoir broadcast stopped state.
class BonsoirBroadcastStoppedState extends BonsoirBroadcastState {
  /// Creates a new Bonsoir broadcast stopped state instance.
  const BonsoirBroadcastStoppedState({
    required super.service,
  });
}
