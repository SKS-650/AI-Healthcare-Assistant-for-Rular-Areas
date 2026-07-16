import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';

class ApiConfig {
  const ApiConfig._();

  static const _backendPort = '8000';
  static const connectionTimeout = 30;
  static const receiveTimeout = 30;

  // ── Dev LAN IP ─────────────────────────────────────────────────────────────
  // Set this to your development machine's local IP address so the app works
  // on a physical Android device over WiFi without any dart-define flags.
  // Run `ipconfig` on Windows to find your IPv4 address.
  static const _devLanIp = '192.168.18.26';

  /// Set via `flutter run --dart-define=BACKEND_URL=http://192.168.x.x:8000`
  /// This wins over every other setting when set.
  static const _backendUrlOverride = String.fromEnvironment('BACKEND_URL');

  /// Set via `flutter run --dart-define=BACKEND_HOST=192.168.x.x`
  static const _backendHostOverride = String.fromEnvironment('BACKEND_HOST');

  /// Base URL resolution priority:
  ///
  ///  1. BACKEND_URL dart-define  → use as-is
  ///  2. BACKEND_HOST dart-define → http://<host>:8000
  ///  3. Web                      → http://localhost:8000
  ///  4. Android (emulator)       → http://10.0.2.2:8000
  ///     Android (physical device)→ http://<_devLanIp>:8000
  ///     Detection: emulators report Build.FINGERPRINT containing "generic"
  ///     but that's not accessible from Dart. We use the dart-define
  ///     IS_EMULATOR flag set by flutter.bat when an AVD is detected,
  ///     otherwise default to the LAN IP for physical devices.
  ///  5. iOS Simulator / Desktop  → http://localhost:8000
  static const _isEmulatorOverride =
      bool.fromEnvironment('IS_EMULATOR', defaultValue: false);

  static String get baseUrl {
    if (_backendUrlOverride.isNotEmpty) return _backendUrlOverride;
    if (_backendHostOverride.isNotEmpty) {
      return 'http://$_backendHostOverride:$_backendPort';
    }

    if (kIsWeb) return 'http://localhost:$_backendPort';

    return switch (defaultTargetPlatform) {
      // If flutter.bat detected an emulator → 10.0.2.2 (host loopback alias)
      // Otherwise assume a physical device on the same WiFi → LAN IP
      TargetPlatform.android => _isEmulatorOverride
          ? 'http://10.0.2.2:$_backendPort'
          : 'http://$_devLanIp:$_backendPort',
      TargetPlatform.iOS => 'http://localhost:$_backendPort',
      _ => 'http://localhost:$_backendPort',
    };
  }

  /// Full URL for symptoms endpoint
  static String get symptomsUrl => '$baseUrl${ApiConstants.symptomsPath}';

  /// Full URL for prediction endpoint
  static String get predictionUrl => '$baseUrl${ApiConstants.predictionPath}';

  /// API version prefix
  static String get apiPrefix => ApiConstants.apiPrefix;

  /// Full API base URL with version prefix
  static String get apiBaseUrl => '$baseUrl$apiPrefix';

  /// Check if backend URL is configured correctly
  static bool get isConfigured => baseUrl.isNotEmpty;

  /// Get human-readable configuration status
  static String get configStatus {
    if (_backendUrlOverride.isNotEmpty) {
      return 'Override ($_backendUrlOverride)';
    }
    if (_backendHostOverride.isNotEmpty) {
      return 'Custom host ($_backendHostOverride:$_backendPort)';
    }
    if (kIsWeb) return 'Web (localhost:$_backendPort)';

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _isEmulatorOverride
          ? 'Android emulator (10.0.2.2:$_backendPort)'
          : 'Android physical device (LAN: $_devLanIp:$_backendPort)',
      TargetPlatform.iOS => 'iOS Simulator (localhost:$_backendPort)',
      _ => 'Desktop (localhost:$_backendPort)',
    };
  }
}
