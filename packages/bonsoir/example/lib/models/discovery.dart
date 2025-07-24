import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:bonsoir_example/utils/sort.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The discovery service list provider.
final discoveryTypeListProvider = NotifierProvider.autoDispose<BonsoirDiscoveryTypeListNotifier, List<String>>(BonsoirDiscoveryTypeListNotifier.new);

/// The discovery service list notifier.
class BonsoirDiscoveryTypeListNotifier extends AutoDisposeNotifier<List<String>> {
  @override
  List<String> build() => [];

  /// Adds a type to the list.
  void add(String type) {
    state = [
      ...state,
      type,
    ];
  }

  /// Removes a type from the list.
  void remove(String type) {
    state = [
      for (String current in state)
        if (current != type) current,
    ];
  }
}

/// The discovery service state provider.
final discoveryTypeStateProvider = AsyncNotifierProvider.autoDispose.family<BonsoirDiscoveryTypeStateNotifier, BonsoirDiscoveryState, String>(BonsoirDiscoveryTypeStateNotifier.new);

/// The discovery service state notifier.
class BonsoirDiscoveryTypeStateNotifier extends AutoDisposeFamilyAsyncNotifier<BonsoirDiscoveryState, String> {
  @override
  FutureOr<BonsoirDiscoveryState> build(String arg) async {
    BonsoirDiscovery discovery = BonsoirDiscovery(type: arg);
    await discovery.ready;
    discovery.eventStream?.listen(_onEventOccurred);
    ref.onDispose(discovery.stop);
    discovery.start();
    return BonsoirDiscoveryReadyState(
      type: arg,
      services: [],
      serviceResolver: discovery.serviceResolver,
    );
  }

  /// Handles the discovery event.
  Future<void> _onEventOccurred(BonsoirDiscoveryEvent event) async {
    BonsoirDiscoveryState state = await future;
    switch (event) {
      case BonsoirDiscoveryStartedEvent():
        this.state = AsyncData(
          BonsoirDiscoveryStartedState(
            type: state.type,
            services: [],
            serviceResolver: state.serviceResolver,
          ),
        );
        break;
      case BonsoirDiscoveryServiceFoundEvent():
        List<BonsoirService> services = List.of(state.services);
        services.add(event.service);
        sortServiceList(services);
        this.state = AsyncData(
          BonsoirDiscoveryStartedState(
            type: state.type,
            services: services,
            serviceResolver: state.serviceResolver,
          ),
        );
        break;
      case BonsoirDiscoveryServiceResolvedEvent():
        List<BonsoirService> services = List.of(state.services);
        services = [
          for (BonsoirService service in services)
            if (service.name == event.service.name) event.service else service,
        ];
        sortServiceList(services);
        this.state = AsyncData(
          BonsoirDiscoveryStartedState(
            type: state.type,
            services: services,
            serviceResolver: state.serviceResolver,
          ),
        );
        break;
      case BonsoirDiscoveryServiceLostEvent():
        List<BonsoirService> services = List.of(state.services);
        services.removeWhere((service) => service.name == event.service.name);
        this.state = AsyncData(
          BonsoirDiscoveryStartedState(
            type: state.type,
            services: services,
            serviceResolver: state.serviceResolver,
          ),
        );
        break;
      case BonsoirDiscoveryStoppedEvent():
        this.state = AsyncData(
          BonsoirDiscoveryStoppedState(
            type: state.type,
            services: state.services,
            serviceResolver: state.serviceResolver,
          ),
        );
        break;
      default:
        break;
    }
  }
}

/// Represents a Bonsoir discovery state.
sealed class BonsoirDiscoveryState {
  /// The service type.
  final String type;

  /// The list of discovered services.
  final List<BonsoirService> services;

  /// The service resolver.
  final ServiceResolver serviceResolver;

  /// Creates a new Bonsoir discovery state instance.
  const BonsoirDiscoveryState({
    required this.type,
    this.services = const [],
    required this.serviceResolver,
  });
}

/// The Bonsoir discovery ready state.
class BonsoirDiscoveryReadyState extends BonsoirDiscoveryState {
  /// Creates a new Bonsoir discovery ready state instance.
  const BonsoirDiscoveryReadyState({
    required super.type,
    required super.services,
    required super.serviceResolver,
  });
}

/// The Bonsoir discovery started state.
class BonsoirDiscoveryStartedState extends BonsoirDiscoveryState {
  /// Creates a new Bonsoir discovery started state instance.
  const BonsoirDiscoveryStartedState({
    required super.type,
    required super.services,
    required super.serviceResolver,
  });
}

/// The Bonsoir discovery stopped state.
class BonsoirDiscoveryStoppedState extends BonsoirDiscoveryState {
  /// Creates a new Bonsoir discovery stopped state instance.
  const BonsoirDiscoveryStoppedState({
    required super.type,
    required super.services,
    required super.serviceResolver,
  });
}
