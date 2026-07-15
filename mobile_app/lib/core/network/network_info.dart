/// Network connectivity service.
///
/// Wraps [connectivity_plus] to provide a reactive stream of [ConnectivityStatus]
/// and a simple boolean helper. All consumers should use the Riverpod provider
/// [networkInfoProvider] defined at the bottom of this file.
library;

import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  /// Perform an actual DNS lookup to confirm internet access — not just
  /// adapter connectivity (WiFi without internet, etc.).
  Future<bool> get isConnected async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.every((r) => r == ConnectivityResult.none)) return false;

      // Validate with a real DNS lookup (no network if this throws)
      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
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
    // Do not do the full DNS lookup inside the stream callback to avoid
    // blocking. Return offline optimistically and let the UI reconcile.
    try {
      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      if (lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty) {
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
final connectivityStatusProvider =
    StreamProvider<ConnectivityStatus>((ref) async* {
  final info = ref.read(networkInfoProvider);

  // Emit initial status immediately
  yield ConnectivityStatus.checking;
  yield await info.currentStatus;

  // Then stream live changes
  yield* info.onStatusChange;
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
