import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'data/services/local_database_service.dart';

void main() async {
  // Ensure Flutter widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env configuration
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Warning: Could not load .env file: $e");
  }

  // Initialize local database for offline caching
  try {
    final dbService = LocalDatabaseService();
    await dbService.database; // Trigger eager initialization
    await dbService.clearExpiredCache(); // Clean up old cache
  } catch (e) {
    print("Warning: Could not initialize local database: $e");
  }

  runApp(const MyApp());
}
