import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class XPrinterThermalWindows {
  const XPrinterThermalWindows();
  List<UsbDevice> list() {
    print("loading printer list");
    final printers = <UsbDevice>[];
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
            if (port.toLowerCase().contains("usb")) {
              printers.add(UsbDevice(
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
    } catch (e) {
      print("Error: $e");
    }

    return printers;
  }

  void test(String name) async {
    // ESC/POS commands for test print
    final List<int> testData = [
      0x1B, 0x40, // Initialize printer
      0x1B, 0x61, 0x01, // Center alignment
      // Text "TEST PRINT"
      ...('TEST PRINT\n').codeUnits,
      0x1B, 0x64, 0x02, // Feed 2 lines
      // Current Date Time
      ...(DateTime.now().toString() + '\n').codeUnits,
      0x1B, 0x64, 0x02, // Feed 2 lines
      0x1B, 0x69, // Cut paper (if supported)
    ];

    printdata(
      printerName: name,
      data: testData,
    );
  }

  int? connect(
    String name, {
    Function(String message)? onCallback,
  }) {
    try {
      final phPrinter = calloc<HANDLE>();
      final result = OpenPrinter(
        name.toNativeUtf16(),
        phPrinter,
        nullptr,
      );

      if (result == 1) {
        return phPrinter.value;
      }
      return null;
    } catch (e) {
      if (onCallback != null) onCallback(e.toString());
      return null;
    }
  }

  bool disconnect(int handle) {
    try {
      return ClosePrinter(handle) == 1;
    } catch (e) {
      return false;
    }
  }

  void printdata({
    required String printerName,
    required List<int> data,
    Function(bool success)? onCallback,
  }) {
    try {
      var result = connect(printerName);
      print("Printer handle: $result");
      if (result == null) {
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
        final startPage = StartPagePrinter(result);
        if (startPage == 0) {
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

        print("writeSuccess: $writeSuccess");
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

class UsbDevice {
  final String name;
  final String port;
  final String driver;

  UsbDevice({
    required this.name,
    required this.port,
    required this.driver,
  });

  @override
  String toString() {
    return 'Printer: $name (Port: $port, Driver: $driver)';
  }
}
