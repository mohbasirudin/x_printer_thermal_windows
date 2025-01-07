import 'package:flutter_test/flutter_test.dart';
import 'package:x_printer_thermal_windows/x_printer_thermal_windows_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockXPrinterThermalWindowsPlatform
    with MockPlatformInterfaceMixin
    implements XPrinterThermalWindowsPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {}
