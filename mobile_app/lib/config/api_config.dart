import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';

class ApiConfig {
  const ApiConfig._();

  static const _backendPort = '8000';
  static const connectionTimeout = 30;
  static const receiveTimeout = 30;

  static const _backendUrlOverride = String.fromEnvironment('BACKEND_URL');
  static const _backendHostOverride = String.fromEnvironment('BACKEND_HOST');

  /// Base URL selection:
  /// - BACKEND_URL wins when provided, e.g. http://192.168.1.12:8000
  /// - BACKEND_HOST is useful for physical devices, e.g. 192.168.1.12
  /// - Android uses the local ADB reverse tunnel created by the launcher
  /// - iOS simulator and Web default to localhost
  static String get baseUrl {
    if (_backendUrlOverride.isNotEmpty) return _backendUrlOverride;
    if (_backendHostOverride.isNotEmpty) {
      return 'http://$_backendHostOverride:$_backendPort';
    }

    if (kIsWeb) return 'http://localhost:$_backendPort';

    return switch (defaultTargetPlatform) {
      // `flutter.bat run` configures `adb reverse tcp:8000 tcp:8000` for
      // connected Android devices.  Using loopback works for both a USB
      // device and an emulator with that tunnel, whereas 10.0.2.2 works only
      // for an emulator and fails on a physical phone.
      TargetPlatform.android => 'http://127.0.0.1:$_backendPort',
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
      TargetPlatform.android => 'Android via ADB tunnel (127.0.0.1:$_backendPort)',
      TargetPlatform.iOS => 'iOS Simulator (localhost:$_backendPort)',
      _ => 'Desktop (localhost:$_backendPort)',
    };
  }
}
