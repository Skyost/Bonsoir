import 'package:bonsoir_example/widgets/broadcast_checkbox.dart';
import 'package:bonsoir_example/widgets/service_list.dart';
import 'package:bonsoir_example/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Plugin's main method.
void main() => runApp(const ProviderScope(child: BonsoirExampleMainWidget()));

/// The main widget.
class BonsoirExampleMainWidget extends StatelessWidget {
  /// Creates a new main widget instance.
  const BonsoirExampleMainWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const TitleWidget(),
            actions: const [BroadcastSwitch()],
            centerTitle: false,
          ),
          body: const ServiceList(),
        ),
      );
}
