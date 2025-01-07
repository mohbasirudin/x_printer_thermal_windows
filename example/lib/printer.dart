import 'package:flutter/material.dart';
import 'package:x_printer_thermal_windows/x_printer_thermal_windows.dart';

class PrinterPage extends StatefulWidget {
  const PrinterPage({super.key});

  @override
  State<PrinterPage> createState() => _PrinterPageState();
}

class _PrinterPageState extends State<PrinterPage> {
  final _printer = const XPrinterThermalWindows();
  var _devices = <UsbDevice>[];
  var _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDevices();
  }

  void _getDevices() async {
    _devices = [];

    _isLoading = true;
    setState(() {});
    try {
      _devices = _printer.list();
    } catch (e) {
      print(e.toString());
      _devices = [];
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'XPrinter Thermal Windows Example',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getDevices,
          )
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_devices.isEmpty) {
      return const Center(child: Text('No devices found'));
    }
    return ListView.builder(
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final device = _devices[index];
        return ListTile(
          title: Text(device.name),
          subtitle: Text(device.name),
          trailing: IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printer.test(device.name),
          ),
        );
      },
    );
  }
}
