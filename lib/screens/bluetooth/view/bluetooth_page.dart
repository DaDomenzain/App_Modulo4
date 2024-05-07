import 'package:app_rafa/logic/search_device.dart';
import 'package:flutter/material.dart';

class BluetoothPage extends StatelessWidget {
  const BluetoothPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: const Text('Bluetooth Demo'),
        ),
        body: SearchDevice());
  }
}
