import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/app.dart';
import 'core/local_db/local_db_service.dart';

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

  // Initialise local storage — wrapped in try/catch so a failure
  // (e.g. first run on web before IndexedDB is ready) never blocks startup.
  try {
    await LocalDbService.instance.initialize();
  } catch (_) {
    // Continue without persistence — non-fatal.
  }

  // Status bar styling (no-op on web)
  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFF8F6FF),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  runApp(const ProviderScope(child: MyApp()));
}
