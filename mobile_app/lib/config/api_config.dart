import 'dart:io';

import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';

class ApiConfig {
  const ApiConfig._();

  // ── IMPORTANT ─────────────────────────────────────────────────────────────
  // When running on a PHYSICAL Android/iOS device, set this to your machine's
  // LAN IP address (find it with `ipconfig` on Windows / `ifconfig` on Mac).
  // When running on an Android emulator, use 'http://10.0.2.2:8000'.
  // You can also override at build time: flutter run --dart-define=BACKEND_URL=http://...
  static const _devLanIp = '192.168.18.26';

  static String get baseUrl {
    const override = String.fromEnvironment('BACKEND_URL');
    if (override.isNotEmpty) return override;
    if (kIsWeb) return 'http://localhost:8000';
    if (Platform.isAndroid) {
      // 10.0.2.2 works only on the official Android emulator.
      // On a physical device the dev machine's LAN IP must be used.
      // Emulator check: the host is 10.0.2.2 which is only reachable inside the emulator's virtual network.
      return 'http://$_devLanIp:8000';
    }
    if (Platform.isIOS) return 'http://$_devLanIp:8000';
    return 'http://127.0.0.1:8000';
  }

  static String get symptomsUrl => '$baseUrl${ApiConstants.symptomsPath}';
  static String get predictionUrl => '$baseUrl${ApiConstants.predictionPath}';
}
