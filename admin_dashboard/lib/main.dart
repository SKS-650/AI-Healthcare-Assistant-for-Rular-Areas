import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: ".env");
    if (kDebugMode) {
      print('✓ Environment variables loaded from .env');
      print('  Backend URL: ${dotenv.env['BACKEND_URL']}');
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠ Warning: Could not load .env file: $e');
      print('  Using default localhost configuration');
    }
  }
  
  runApp(
    const ProviderScope(
      child: AdminApp(),
    ),
  );
}
