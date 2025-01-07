import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_printer_thermal_windows/x_printer_thermal_windows_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelXPrinterThermalWindows platform = MethodChannelXPrinterThermalWindows();
  const MethodChannel channel = MethodChannel('x_printer_thermal_windows');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
