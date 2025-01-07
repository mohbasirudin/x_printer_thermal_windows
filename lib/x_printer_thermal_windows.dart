import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class XPrinterThermalWindows {
  XPrinterThermalWindows._();
  List<PrinterInfo> list() {
    final printers = <PrinterInfo>[];
    const flags = PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS;

    try {
      // Get required buffer size
      final needed = calloc<DWORD>();
      final returned = calloc<DWORD>();

      // First call to get buffer size
      EnumPrinters(
        flags,
        nullptr,
        2,
        nullptr,
        0,
        needed,
        returned,
      );

      if (needed.value > 0) {
        final buffer = calloc<Uint8>(needed.value);

        // Second call to get actual data
        if (EnumPrinters(
              flags,
              nullptr,
              2,
              buffer,
              needed.value,
              needed,
              returned,
            ) !=
            0) {
          final count = returned.value;

          for (var i = 0; i < count; i++) {
            final printer = Pointer<PRINTER_INFO_2>.fromAddress(
                    buffer.address + (i * sizeOf<PRINTER_INFO_2>()))
                .ref;

            final name = printer.pPrinterName.toDartString();
            final port = printer.pPortName.toDartString();
            final driver = printer.pDriverName.toDartString();

            if (port.contains("usb")) {
              printers.add(PrinterInfo(
                name: name,
                port: port,
                driver: driver,
              ));
            }
          }
        }
        free(buffer);
      }
      free(needed);
      free(returned);
    } catch (e) {}

    return printers;
  }

  int connect(String name) {
    try {
      final phPrinter = calloc<HANDLE>();
      final result = OpenPrinter(
        name.toNativeUtf16(),
        phPrinter,
        nullptr,
      );
      if (result == 1) {}

      return result;
    } catch (e) {
      return 0;
    }
  }

  bool disconnect(int handle) {
    try {
      return ClosePrinter(handle) == 1;
    } catch (e) {
      return false;
    }
  }

  void print({
    required String printerName,
    required List<int> data,
    Function(bool success)? onCallback,
  }) {
    try {
      var result = connect(printerName);
      if (result == 0) {
        _callback(onCallback)?.call(false);
        return;
      }

      final docName = 'Raw Print Job'.toNativeUtf16();
      final dataType = 'RAW'.toNativeUtf16();
      final docInfo = calloc<DOC_INFO_1>()
        ..ref.pDocName = docName
        ..ref.pOutputFile = nullptr
        ..ref.pDatatype = dataType;

      try {
        // Start document
        final docResult = StartDocPrinter(result, 1, docInfo);
        if (docResult == 0) {
          _callback(onCallback)?.call(false);
          return;
        }
        // Start page
        if (StartPagePrinter(result) == 0) {
          EndDocPrinter(result);
          return;
        }
        // Write data
        final dataPtr = calloc<Uint8>(data.length);
        final buffer = dataPtr.asTypedList(data.length);
        buffer.setAll(0, data);

        final bytesWritten = calloc<DWORD>();
        final writeSuccess = WritePrinter(
          result,
          dataPtr,
          data.length,
          bytesWritten,
        );
        // Clean up data buffer
        free(dataPtr);
        free(bytesWritten);

        // End page and document
        EndPagePrinter(result);
        EndDocPrinter(result);

        if (writeSuccess == 1) {
          _callback(onCallback)?.call(true);
        } else {
          _callback(onCallback)?.call(false);
        }
      } catch (e) {
        _callback(onCallback)?.call(false);
      }
    } catch (e) {
      _callback(onCallback)?.call(false);
    }
  }

  Function? _callback(Function(bool success)? onCallback) {
    if (onCallback != null) {
      return onCallback;
    }
    return null;
  }
}

class PrinterInfo {
  final String name;
  final String port;
  final String driver;

  PrinterInfo({
    required this.name,
    required this.port,
    required this.driver,
  });

  @override
  String toString() {
    return 'Printer: $name (Port: $port, Driver: $driver)';
  }
}
