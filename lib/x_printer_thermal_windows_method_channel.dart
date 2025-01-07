import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'x_printer_thermal_windows_platform_interface.dart';

/// An implementation of [XPrinterThermalWindowsPlatform] that uses method channels.
class MethodChannelXPrinterThermalWindows extends XPrinterThermalWindowsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('x_printer_thermal_windows');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
