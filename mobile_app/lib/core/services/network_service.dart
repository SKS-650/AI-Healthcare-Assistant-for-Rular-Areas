/// Backend connectivity service.
///
/// Provides WiFi-awareness plus a dedicated server-reachability check so the
/// app can give users clear, actionable feedback:
///
///   🟢  Server Connected   — WiFi up AND FastAPI responding on /health
///   🔴  Server Offline     — WiFi up but FastAPI not reachable
///   🟠  No Internet        — No WiFi / mobile data
///
/// Usage (Riverpod):
///   final status = ref.watch(serverStatusProvider);
library;

import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

enum ServerStatus {
  checking,
  connected,
  serverOffline,
  noInternet;

  bool get isConnected => this == ServerStatus.connected;

  /// User-facing label for each status.
  String get label => switch (this) {
        ServerStatus.connected => 'Server Connected',
        ServerStatus.serverOffline => 'Server Offline',
        ServerStatus.noInternet => 'No Internet',
        ServerStatus.checking => 'Checking…',
      };

  /// Emoji prefix shown in the UI widget.
  String get emoji => switch (this) {
        ServerStatus.connected => '🟢',
        ServerStatus.serverOffline => '🔴',
        ServerStatus.noInternet => '🟠',
        ServerStatus.checking => '🔵',
      };

  /// Detailed hint shown below the label.
  String get hint => switch (this) {
        ServerStatus.connected => 'Backend is reachable over WiFi.',
        ServerStatus.serverOffline =>
          'Cannot reach the server.\n'
          'Ensure the laptop server is running:\n'
          '  start_server.bat  OR  uvicorn app.main:app --host 0.0.0.0 --port 8000\n'
          'Also make sure both devices are on the same WiFi.',
        ServerStatus.noInternet =>
          'No network connection detected.\n'
          'Connect your phone to the same WiFi as the laptop.',
        ServerStatus.checking => 'Checking server availability…',
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// NetworkService
// ─────────────────────────────────────────────────────────────────────────────

class NetworkService {
  NetworkService._();
  static final NetworkService instance = NetworkService._();

  final Connectivity _connectivity = Connectivity();

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns `true` when the device has any network adapter connected
  /// AND a real DNS lookup succeeds (filters WiFi-without-internet).
  Future<bool> isConnected() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.every((r) => r == ConnectivityResult.none)) return false;

      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Pings `GET /health` on the FastAPI server.
  /// Returns `true` only when the server responds with HTTP 200.
  Future<bool> isServerAvailable() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/health');
      final response = await http.get(uri).timeout(
            const Duration(seconds: 8),
            onTimeout: () => http.Response('timeout', 408),
          );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Combined check: returns the current [ServerStatus].
  Future<ServerStatus> checkStatus() async {
    final connected = await isConnected();
    if (!connected) return ServerStatus.noInternet;

    final serverUp = await isServerAvailable();
    return serverUp ? ServerStatus.connected : ServerStatus.serverOffline;
  }

  /// Stream that emits a new [ServerStatus] whenever network connectivity
  /// changes, and then re-checks the backend.
  Stream<ServerStatus> get onStatusChange async* {
    yield ServerStatus.checking;
    yield await checkStatus();

    await for (final _ in _connectivity.onConnectivityChanged) {
      yield ServerStatus.checking;
      yield await checkStatus();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Riverpod providers
// ─────────────────────────────────────────────────────────────────────────────

/// Singleton [NetworkService] provider.
final networkServiceProvider = Provider<NetworkService>(
  (_) => NetworkService.instance,
);

/// Reactive [ServerStatus] stream provider.
/// Automatically re-evaluates when connectivity changes.
final serverStatusProvider = StreamProvider<ServerStatus>((ref) {
  return ref.read(networkServiceProvider).onStatusChange;
});

/// Convenience bool — true only when the backend is reachable.
final isServerOnlineProvider = Provider<bool>((ref) {
  return ref
      .watch(serverStatusProvider)
      .maybeWhen(
        data: (s) => s.isConnected,
        orElse: () => false,
      );
});
