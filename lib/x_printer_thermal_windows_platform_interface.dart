import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'x_printer_thermal_windows_method_channel.dart';

abstract class XPrinterThermalWindowsPlatform extends PlatformInterface {
  /// Constructs a XPrinterThermalWindowsPlatform.
  XPrinterThermalWindowsPlatform() : super(token: _token);

  static final Object _token = Object();

  static XPrinterThermalWindowsPlatform _instance = MethodChannelXPrinterThermalWindows();

  /// The default instance of [XPrinterThermalWindowsPlatform] to use.
  ///
  /// Defaults to [MethodChannelXPrinterThermalWindows].
  static XPrinterThermalWindowsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [XPrinterThermalWindowsPlatform] when
  /// they register themselves.
  static set instance(XPrinterThermalWindowsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
