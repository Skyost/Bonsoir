import 'package:bonsoir_example/models/broadcast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BroadcastCheckbox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BonsoirBroadcastModel model = context.watch<BonsoirBroadcastModel>();
    return InkWell(
      onTap: () {
        if (model.isBroadcasting) {
          model.stop();
        } else {
          model.start();
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Is broadcasting'.toUpperCase()),
          Checkbox(
            value: model.isBroadcasting,
            onChanged: null,
            visualDensity: VisualDensity(horizontal: VisualDensity.minimumDensity),
          ),
        ],
      ),
    );
  }
}
