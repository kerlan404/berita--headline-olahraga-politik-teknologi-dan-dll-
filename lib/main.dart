import 'package:flutter/foundation.dart'
    show debugPrint, defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/utils/db_init.dart'
    if (dart.library.io) 'core/utils/db_init_native.dart';
import 'app.dart';
import 'data/services/local_database_service.dart';

void main() async {
  // Ensure Flutter widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env configuration
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: Could not load .env file: $e");
  }

  // Initialize database for offline caching
  // sqflite only works natively on Android/iOS.
  // For Desktop (Windows/macOS/Linux), use sqflite_common_ffi.
  // For Web, caching is disabled gracefully.
  final dbService = LocalDatabaseService();
  if (kIsWeb) {
    dbService.markUnavailable();
  } else {
    try {
      if (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        initializeDesktopDatabase();
      }

      await dbService.database; // Trigger eager initialization
      await dbService.clearExpiredCache(); // Clean up old cache
    } catch (e) {
      dbService.markUnavailable();
      debugPrint("Info: Offline caching disabled — $e");
    }
  }

  runApp(const MyApp());
}
