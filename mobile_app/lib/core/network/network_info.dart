/// Network connectivity service.
///
/// Wraps [connectivity_plus] to provide a reactive stream of [ConnectivityStatus]
/// and a simple boolean helper. All consumers should use the Riverpod provider
/// [networkInfoProvider] defined at the bottom of this file.
///
/// Connectivity is determined by pinging the backend /health endpoint rather
/// than doing a DNS lookup for google.com — this correctly handles LAN-only
/// setups (physical device + WiFi hotspot) where google.com may be blocked.
library;

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

enum ConnectivityStatus {
  online,
  offline,
  checking;

  bool get isOnline  => this == ConnectivityStatus.online;
  bool get isOffline => this == ConnectivityStatus.offline;
}

// ─────────────────────────────────────────────────────────────────────────────
// NetworkInfo service
// ─────────────────────────────────────────────────────────────────────────────

class NetworkInfo {
  NetworkInfo._();
  static final NetworkInfo instance = NetworkInfo._();

  final Connectivity _connectivity = Connectivity();

  StreamController<ConnectivityStatus>? _controller;

  Stream<ConnectivityStatus> get onStatusChange {
    _controller ??= StreamController<ConnectivityStatus>.broadcast(
      onListen: _startListening,
      onCancel: _stopListening,
    );
    return _controller!.stream;
  }

  StreamSubscription<List<ConnectivityResult>>? _sub;

  void _startListening() {
    _sub = _connectivity.onConnectivityChanged.listen((results) async {
      final status = await _resultsToStatus(results);
      _controller?.add(status);
    });
  }

  void _stopListening() {
    _sub?.cancel();
    _sub = null;
  }

  /// Confirms connectivity by pinging the backend /health endpoint.
  ///
  /// Using a backend ping instead of a google.com DNS lookup ensures this
  /// works correctly on LAN-only setups where external DNS may be blocked.
  Future<bool> get isConnected async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.every((r) => r == ConnectivityResult.none)) return false;

      // Hit our own backend health endpoint — no external DNS needed
      final uri = Uri.parse('${ApiConfig.baseUrl}/health');
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 6));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<ConnectivityStatus> get currentStatus async {
    final connected = await isConnected;
    return connected ? ConnectivityStatus.online : ConnectivityStatus.offline;
  }

  Future<ConnectivityStatus> _resultsToStatus(
      List<ConnectivityResult> results) async {
    if (results.every((r) => r == ConnectivityResult.none)) {
      return ConnectivityStatus.offline;
    }
    // Ping the backend health endpoint to confirm real reachability.
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/health');
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        return ConnectivityStatus.online;
      }
    } catch (_) {}
    return ConnectivityStatus.offline;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Riverpod providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provides the singleton [NetworkInfo] service.
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo.instance;
});

/// A [StreamProvider] that emits the live [ConnectivityStatus].
/// Starts as [ConnectivityStatus.checking] until the first event.
///
/// Also polls every 15 seconds so the banner clears automatically once the
/// backend comes back up — without requiring the user to restart the app.
final connectivityStatusProvider =
    StreamProvider<ConnectivityStatus>((ref) {
  final info = ref.read(networkInfoProvider);

  late StreamController<ConnectivityStatus> controller;
  Timer? pollTimer;

  Future<void> emitCurrent() async {
    if (controller.isClosed) return;
    final status = await info.currentStatus;
    if (!controller.isClosed) controller.add(status);
  }

  controller = StreamController<ConnectivityStatus>(
    onListen: () async {
      // 1. Immediate checking → real status
      controller.add(ConnectivityStatus.checking);
      await emitCurrent();

      // 2. Re-check whenever the network adapter changes
      info.onStatusChange.listen(
        (s) { if (!controller.isClosed) controller.add(s); },
        onError: (_) {},
        cancelOnError: false,
      );

      // 3. Poll every 15 s so the banner auto-recovers when backend starts
      pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
        emitCurrent();
      });
    },
    onCancel: () {
      pollTimer?.cancel();
    },
  );

  return controller.stream;
});

/// Simple boolean convenience provider — true when internet is confirmed.
final isOnlineProvider = Provider<bool>((ref) {
  return ref
      .watch(connectivityStatusProvider)
      .maybeWhen(
        data: (status) => status.isOnline,
        orElse: () => false,
      );
});
