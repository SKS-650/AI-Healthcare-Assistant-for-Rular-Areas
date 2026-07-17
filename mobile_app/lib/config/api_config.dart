import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';

class ApiConfig {
  const ApiConfig._();

  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;

  // ─────────────────────────────────────────────────────────────────────────
  // WIFI BACKEND URL — update this one constant if your laptop IP changes.
  //
  // How to find your IP:  run `ipconfig` on Windows → look for "IPv4 Address"
  //                       on the WiFi adapter.
  //
  // Format MUST be:  http://<IP>:<PORT>   ← colon between IP and port, no slash at end
  // ─────────────────────────────────────────────────────────────────────────
  static const String _wifiBackendUrl = 'http://192.168.18.26:8000';

  // ─────────────────────────────────────────────────────────────────────────
  // Override via dart-define (optional — for CI / team members with different IPs):
  //   flutter run --dart-define=BACKEND_URL=http://192.168.x.x:8000
  // ─────────────────────────────────────────────────────────────────────────
  static const _backendUrlOverride = String.fromEnvironment('BACKEND_URL');

  /// Resolved base URL.
  ///
  /// Priority:
  ///   1. BACKEND_URL dart-define (if provided)
  ///   2. Android emulator       → http://10.0.2.2:8000
  ///   3. Physical Android/iOS   → [_wifiBackendUrl]  (WiFi LAN)
  ///   4. Web / Desktop          → http://localhost:8000
  static String get baseUrl {
    // 1. Explicit override wins
    if (_backendUrlOverride.isNotEmpty) return _backendUrlOverride;

    if (kIsWeb) return 'http://localhost:8000';

    return switch (defaultTargetPlatform) {
      // Android emulator uses a special alias to reach the host machine
      TargetPlatform.android =>
        bool.fromEnvironment('IS_EMULATOR', defaultValue: false)
            ? 'http://10.0.2.2:8000'
            : _wifiBackendUrl,
      // iOS / Desktop
      TargetPlatform.iOS => 'http://localhost:8000',
      _ => 'http://localhost:8000',
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
    if (kIsWeb) return 'Web (localhost:8000)';

    return switch (defaultTargetPlatform) {
      TargetPlatform.android =>
        bool.fromEnvironment('IS_EMULATOR', defaultValue: false)
            ? 'Android emulator (10.0.2.2:8000)'
            : 'Android physical device (WiFi: $_wifiBackendUrl)',
      TargetPlatform.iOS => 'iOS Simulator (localhost:8000)',
      _ => 'Desktop (localhost:8000)',
    };
  }
}
