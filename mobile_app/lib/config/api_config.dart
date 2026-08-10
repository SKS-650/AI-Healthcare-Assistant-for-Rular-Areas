import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants/api_constants.dart';

class ApiConfig {
  const ApiConfig._();

  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;

  // ─────────────────────────────────────────────────────────────────────────
  // BACKEND URL — Now loaded from .env file!
  //
  // To change IP address: Just edit mobile_app/.env file
  // No need to modify this code anymore!
  // ─────────────────────────────────────────────────────────────────────────

  /// Get backend URL from .env file (fallback to localhost if not set)
  static String get _envBackendUrl => 
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:8000';

  // ─────────────────────────────────────────────────────────────────────────
  // Override via dart-define (optional — for CI / team members):
  //   flutter run --dart-define=BACKEND_URL=http://192.168.x.x:8000
  // ─────────────────────────────────────────────────────────────────────────
  static const _backendUrlOverride = String.fromEnvironment('BACKEND_URL');

  /// Resolved base URL.
  ///
  /// Priority:
  ///   1. BACKEND_URL dart-define (if provided)
  ///   2. .env file BACKEND_URL
  ///   3. Android emulator       → http://10.0.2.2:8000
  ///   4. Web                    → http://localhost:8000
  static String get baseUrl {
    // 1. Explicit override wins
    if (_backendUrlOverride.isNotEmpty) return _backendUrlOverride;

    // 2. For physical devices, use .env configuration
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      // Check if running on emulator
      const isEmulator = bool.fromEnvironment('IS_EMULATOR', defaultValue: false);
      if (isEmulator) {
        return 'http://10.0.2.2:8000'; // Android emulator
      }
      return _envBackendUrl; // Physical device - use .env
    }

    // 3. For iOS physical devices, use .env
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return _envBackendUrl;
    }

    // 4. Web and other platforms use localhost
    if (kIsWeb) return 'http://localhost:8000';
    
    return _envBackendUrl; // Fallback to .env
  }

  /// Full URL for symptoms endpoint (GET /api/v1/symptom-checker/symptoms)
  static String get symptomsUrl => '$baseUrl${ApiConstants.symptomsPath}';

  /// Full URL for prediction endpoint (POST /api/v1/symptom-checker/predict)
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
        const bool.fromEnvironment('IS_EMULATOR', defaultValue: false)
            ? 'Android emulator (10.0.2.2:8000)'
            : 'Android physical device (.env: $_envBackendUrl)',
      TargetPlatform.iOS => 'iOS Device (.env: $_envBackendUrl)',
      _ => 'From .env ($_envBackendUrl)',
    };
  }
}
