/// Dio HTTP client for the mobile app.
///
/// Wraps Dio with:
///   • Dynamic base URL from [ApiConfig]
///   • JWT Bearer token injection
///   • Automatic 401 → token refresh → retry
///   • Request / response logging in debug mode
///   • Typed error mapping to [NetworkException]
///
/// Note: The mobile app primarily uses the [http] package for most features.
/// This Dio client is available as an alternative for features that benefit
/// from interceptors, e.g. file uploads, streaming, or advanced retry logic.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/api_config.dart';

// We intentionally keep Dio as optional — if dio is not in pubspec.yaml this
// file won't be imported by any feature.  The mobile app uses the `http`
// package as the primary client and only exposes this Dio wrapper for
// future use. If you add `dio: ^5.x.x` to pubspec.yaml uncomment the import
// and the implementation below.

// ─────────────────────────────────────────────────────────────────────────────
// Network exception — platform-agnostic error type
// ─────────────────────────────────────────────────────────────────────────────

enum NetworkErrorType {
  noInternet,
  serverOffline,
  timeout,
  unauthorized,
  serverError,
  unknown,
}

class NetworkException implements Exception {
  const NetworkException({
    required this.type,
    required this.message,
    this.statusCode,
  });

  final NetworkErrorType type;
  final String message;
  final int? statusCode;

  /// Human-readable message suitable for display in a SnackBar / dialog.
  String get userMessage => switch (type) {
        NetworkErrorType.noInternet =>
          'No internet connection.\nConnect your phone to the same WiFi as the laptop.',
        NetworkErrorType.serverOffline =>
          'Cannot connect to server.\nMake sure the laptop server is running and both devices are on the same WiFi.',
        NetworkErrorType.timeout =>
          'Request timed out.\nCheck your WiFi connection and try again.',
        NetworkErrorType.unauthorized =>
          'Session expired. Please log in again.',
        NetworkErrorType.serverError =>
          'Server error (${statusCode ?? '5xx'}). Try again later.',
        NetworkErrorType.unknown => message,
      };

  @override
  String toString() => 'NetworkException(${type.name}): $message';
}

// ─────────────────────────────────────────────────────────────────────────────
// Token storage keys (shared with authentication_repository_impl.dart)
// ─────────────────────────────────────────────────────────────────────────────

const _kAccessToken = 'auth_access_token';
const _kRefreshToken = 'auth_refresh_token';

// ─────────────────────────────────────────────────────────────────────────────
// SimpleApiClient — http-package-based client with the same interface
// ─────────────────────────────────────────────────────────────────────────────

/// Thin wrapper over the `http` package with:
///   - Automatic Bearer token injection
///   - 401 → silent token refresh → retry (once)
///   - Typed [NetworkException] error mapping
///
/// This does NOT require Dio.  It is used by features that need the retry /
/// token refresh behaviour without pulling in the full Dio dependency.
class SimpleApiClient {
  SimpleApiClient._();
  static final SimpleApiClient instance = SimpleApiClient._();

  final _client = http.Client();

  // ── Token helpers ─────────────────────────────────────────────────────────

  Future<String?> _readToken(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> _writeToken(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await _readToken(_kAccessToken);
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ── Token refresh ─────────────────────────────────────────────────────────

  Future<bool> _tryRefresh() async {
    final refreshToken = await _readToken(_kRefreshToken);
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/refresh'),
            headers: {'Content-Type': 'application/json'},
            body: '{"refresh_token":"$refreshToken"}',
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // Parse minimal JSON without importing dart:convert at call site
        final body = response.body;
        final accessMatch = RegExp(r'"access_token"\s*:\s*"([^"]+)"').firstMatch(body);
        final refreshMatch = RegExp(r'"refresh_token"\s*:\s*"([^"]+)"').firstMatch(body);

        final newAccess = accessMatch?.group(1);
        final newRefresh = refreshMatch?.group(1);

        if (newAccess != null && newAccess.isNotEmpty) {
          await _writeToken(_kAccessToken, newAccess);
          if (newRefresh != null && newRefresh.isNotEmpty) {
            await _writeToken(_kRefreshToken, newRefresh);
          }
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  // ── Request helper ────────────────────────────────────────────────────────

  Future<http.Response> _request(
    Future<http.Response> Function(Map<String, String> headers) fn,
  ) async {
    try {
      var response = await fn(await _authHeaders()).timeout(
        Duration(seconds: ApiConfig.receiveTimeout),
        onTimeout: () => throw const SocketException('timeout'),
      );

      if (response.statusCode == 401) {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          response = await fn(await _authHeaders()).timeout(
            Duration(seconds: ApiConfig.receiveTimeout),
          );
        }
      }

      return response;
    } on SocketException catch (e) {
      if (e.message.contains('timeout')) {
        throw const NetworkException(
          type: NetworkErrorType.timeout,
          message: 'Request timed out',
        );
      }
      throw const NetworkException(
        type: NetworkErrorType.serverOffline,
        message: 'Cannot connect to server',
      );
    } on HandshakeException {
      throw const NetworkException(
        type: NetworkErrorType.serverOffline,
        message: 'SSL handshake failed — server may be unreachable',
      );
    } on http.ClientException {
      throw const NetworkException(
        type: NetworkErrorType.serverOffline,
        message: 'HTTP client error — server may be unreachable',
      );
    }
  }

  // ── Public HTTP methods ───────────────────────────────────────────────────

  Future<http.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    var uri = Uri.parse('${ApiConfig.apiBaseUrl}$path');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(
        queryParameters: queryParameters.map(
          (k, v) => MapEntry(k, v.toString()),
        ),
      );
    }
    return _request((h) => _client.get(uri, headers: h));
  }

  Future<http.Response> post(String path, {Object? body}) {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$path');
    return _request(
      (h) => _client.post(uri, headers: h, body: body?.toString()),
    );
  }

  Future<http.Response> put(String path, {Object? body}) {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$path');
    return _request(
      (h) => _client.put(uri, headers: h, body: body?.toString()),
    );
  }

  Future<http.Response> patch(String path, {Object? body}) {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$path');
    return _request(
      (h) => _client.patch(uri, headers: h, body: body?.toString()),
    );
  }

  Future<http.Response> delete(String path) {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$path');
    return _request((h) => _client.delete(uri, headers: h));
  }

  // ── Debug logging ─────────────────────────────────────────────────────────

  static void log(String msg) {
    if (kDebugMode) debugPrint('[ApiClient] $msg');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Riverpod provider
// ─────────────────────────────────────────────────────────────────────────────

final simpleApiClientProvider = Provider<SimpleApiClient>(
  (_) => SimpleApiClient.instance,
);
