import 'package:bonsoir_example/models/broadcast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Allows to switch the app broadcast state.
class BroadcastSwitch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BonsoirBroadcastModel model = context.watch<BonsoirBroadcastModel>();
    return InkWell(
      onTap: () => _onTap(model),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Broadcast'.toUpperCase()),
          Switch(
            value: model.isBroadcasting,
            onChanged: (value) => _onTap(model),
            activeColor: Colors.white,
            activeTrackColor: Colors.white54,
          ),
        ],
      ),
    );
  }

  /// Triggered when the widget has been tapped on.
  void _onTap(BonsoirBroadcastModel model) {
    if (model.isBroadcasting) {
      model.stop();
    } else {
      model.start();
    }
  }
}
