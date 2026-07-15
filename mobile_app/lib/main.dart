import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/local_db/local_db_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
