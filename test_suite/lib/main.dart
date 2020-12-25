import 'package:flutter/material.dart';

void main() => runApp(TestApp());

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bonsoir Tests'),
        ),
        body: Center(
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const Text('Running tests')
            ],
          ),
        )
      ),
  );
}
