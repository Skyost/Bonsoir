import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:bonsoir_example/models/app_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The model provider.
final discoveryModelProvider = ChangeNotifierProvider<BonsoirDiscoveryModel>((ref) {
  BonsoirDiscoveryModel model = BonsoirDiscoveryModel();
  model.start();
  return model;
});

/// Provider model that allows to handle Bonsoir discoveries.
class BonsoirDiscoveryModel extends ChangeNotifier {
  /// The current Bonsoir discovery object instance.
  BonsoirDiscovery? _bonsoirDiscovery;

  /// Contains all discovered services.
  final Map<String, BonsoirService> _services = {};

  /// Contains all functions that allows to resolve services.
  final Map<String, VoidCallback> _servicesResolver = {};

  /// The subscription object.
  StreamSubscription<BonsoirDiscoveryEvent>? _subscription;

  /// Returns all discovered (and resolved) services.
  Iterable<BonsoirService> get services => _services.values;

  /// Starts the Bonsoir discovery.
  Future<void> start() async {
    if (_bonsoirDiscovery == null || _bonsoirDiscovery!.isStopped) {
      _bonsoirDiscovery = BonsoirDiscovery(type: (await AppService.getService()).type);
      await _bonsoirDiscovery!.ready;
    }

    _subscription = _bonsoirDiscovery!.eventStream!.listen(_onEventOccurred);
    await _bonsoirDiscovery!.start();
  }

  /// Stops the Bonsoir discovery.
  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _bonsoirDiscovery?.stop();
  }

  /// Returns the service resolver function of the given service.
  VoidCallback? getServiceResolverFunction(BonsoirService service) => _servicesResolver[service.name];

  /// Triggered when a Bonsoir discovery event occurred.
  void _onEventOccurred(BonsoirDiscoveryEvent event) {
    if (event.service == null) {
      return;
    }

    BonsoirService service = event.service!;
    if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
      _services[service.name] = service;
      _servicesResolver[service.name] = () => _resolveService(service);
    } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
      _services[service.name] = service;
      _servicesResolver.remove(service.name);
    } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolveFailed) {
      _servicesResolver[service.name] = () => _resolveService(service);
    } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
      _services.remove(service.name);
    }
    notifyListeners();
  }

  /// Resolves the given service.
  void _resolveService(BonsoirService service) {
    if (_bonsoirDiscovery != null) {
      service.resolve(_bonsoirDiscovery!.serviceResolver);
    }
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
