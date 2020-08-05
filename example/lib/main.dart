import 'package:bonsoir_example/models/broadcast.dart';
import 'package:bonsoir_example/models/discovery.dart';
import 'package:bonsoir_example/widgets/broadcast_checkbox.dart';
import 'package:bonsoir_example/widgets/service_list.dart';
import 'package:bonsoir_example/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Plugin's main method.
void main() => runApp(BonsoirExampleMainWidget());

/// The main widget.
class BonsoirExampleMainWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<BonsoirBroadcastModel>(create: (context) => BonsoirBroadcastModel()),
          ChangeNotifierProvider<BonsoirDiscoveryModel>(create: (context) => BonsoirDiscoveryModel()),
        ],
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: TitleWidget(),
              actions: [BroadcastSwitch()],
              centerTitle: false,
            ),
            body: ServiceList(),
          ),
        ),
      );
}
