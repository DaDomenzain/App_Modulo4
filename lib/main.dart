import 'package:app_rafa/screens/bluetooth/bluetooth.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: 'Leer FC',
        home: Bluetooth(),
      );
}
