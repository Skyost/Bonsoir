import 'package:bonsoir_example/widgets/broadcast_checkbox.dart';
import 'package:bonsoir_example/widgets/service_list.dart';
import 'package:bonsoir_example/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Plugin's main method.
void main() => runApp(ProviderScope(child: BonsoirExampleMainWidget()));

/// The main widget.
class BonsoirExampleMainWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: TitleWidget(),
            actions: [BroadcastSwitch()],
            centerTitle: false,
          ),
          body: ServiceList(),
        ),
      );
}
