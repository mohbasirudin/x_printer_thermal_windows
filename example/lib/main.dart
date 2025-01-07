import 'package:flutter/material.dart';
import 'package:x_printer_thermal_windows_example/printer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PrinterPage(),
    );
  }
}
