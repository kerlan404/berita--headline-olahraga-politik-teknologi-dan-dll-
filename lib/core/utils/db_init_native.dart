import 'dart:io' show Platform;

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Initialize SQLite via FFI for desktop platforms (Windows / Linux / macOS).
/// On Android / iOS the native sqflite plugin handles this automatically.
void initializeDesktopDatabase() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
