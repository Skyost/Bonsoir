import 'package:bonsoir_example/models/discovery.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TitleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int count = context.watch<BonsoirDiscoveryModel>().discoveredServices.length;
    return Text(count == 0 ? 'Bonsoir app demo' : 'Found $count service(s)');
  }

}