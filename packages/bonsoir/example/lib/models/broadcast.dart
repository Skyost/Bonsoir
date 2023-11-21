import 'package:bonsoir/bonsoir.dart';
import 'package:bonsoir_example/models/app_service.dart';
import 'package:bonsoir_example/models/model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The model provider.
final broadcastModelProvider = ChangeNotifierProvider((ref) {
  BonsoirBroadcastModel model = BonsoirBroadcastModel();
  model.start(DefaultAppService.service);
  return model;
});

/// Provider model that allows to handle Bonsoir broadcasts.
class BonsoirBroadcastModel extends BonsoirActionModel<BonsoirService, BonsoirBroadcast, BonsoirEvent> {
  /// Returns the broadcasted services.
  Iterable<BonsoirService> get broadcastedServices => actions.map((broadcast) => broadcast.service);

  @override
  BonsoirBroadcast createAction(BonsoirService argument) => BonsoirBroadcast(service: argument);
}
