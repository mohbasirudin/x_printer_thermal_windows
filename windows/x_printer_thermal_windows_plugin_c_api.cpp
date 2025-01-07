#include "include/x_printer_thermal_windows/x_printer_thermal_windows_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "x_printer_thermal_windows_plugin.h"

void XPrinterThermalWindowsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  x_printer_thermal_windows::XPrinterThermalWindowsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
