/// API request / response interceptor utilities.
///
/// Provides:
///   • [ApiErrorMapper]  — maps HTTP status codes + exceptions to
///     [NetworkException] with user-friendly messages.
///   • [RequestLogger]   — debug-only console logging of requests/responses.
///
/// These are used by [SimpleApiClient] (dio_client.dart) and can also be
/// plugged into Dio interceptors if Dio is added to the project later.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'dio_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ApiErrorMapper
// ─────────────────────────────────────────────────────────────────────────────

class ApiErrorMapper {
  const ApiErrorMapper._();

  /// Convert a completed [http.Response] to a [NetworkException] if the
  /// status code indicates an error.  Returns `null` for 2xx responses.
  static NetworkException? fromResponse(http.Response response) {
    final code = response.statusCode;

    if (code >= 200 && code < 300) return null; // success

    if (code == 401) {
      return const NetworkException(
        type: NetworkErrorType.unauthorized,
        message: 'Unauthorized — token expired or invalid.',
        statusCode: 401,
      );
    }
    if (code == 403) {
      return NetworkException(
        type: NetworkErrorType.unauthorized,
        message: 'Access denied (403).',
        statusCode: code,
      );
    }
    if (code == 404) {
      return NetworkException(
        type: NetworkErrorType.unknown,
        message: 'Resource not found (404).',
        statusCode: code,
      );
    }
    if (code == 408 || code == 504) {
      return NetworkException(
        type: NetworkErrorType.timeout,
        message: 'Request timed out ($code).',
        statusCode: code,
      );
    }
    if (code == 422) {
      final detail = _extractDetail(response.body);
      return NetworkException(
        type: NetworkErrorType.unknown,
        message: detail ?? 'Validation error (422).',
        statusCode: code,
      );
    }
    if (code >= 500) {
      return NetworkException(
        type: NetworkErrorType.serverError,
        message: 'Server error ($code).',
        statusCode: code,
      );
    }

    return NetworkException(
      type: NetworkErrorType.unknown,
      message: 'Request failed with status $code.',
      statusCode: code,
    );
  }

  /// Convert a caught exception (before or after the request) to a
  /// [NetworkException].
  static NetworkException fromException(Object e) {
    if (e is NetworkException) return e;

    if (e is SocketException) {
      if (e.message.toLowerCase().contains('timeout')) {
        return const NetworkException(
          type: NetworkErrorType.timeout,
          message: 'Connection timed out.',
        );
      }
      return const NetworkException(
        type: NetworkErrorType.serverOffline,
        message: 'Cannot connect to the server.\n'
            'Make sure the backend is running and both devices '
            'are on the same WiFi network.',
      );
    }

    if (e is HandshakeException) {
      return const NetworkException(
        type: NetworkErrorType.serverOffline,
        message: 'SSL handshake failed.',
      );
    }

    if (e is http.ClientException) {
      return const NetworkException(
        type: NetworkErrorType.serverOffline,
        message: 'HTTP client error — server may be unreachable.',
      );
    }

    return NetworkException(
      type: NetworkErrorType.unknown,
      message: e.toString(),
    );
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Pull `detail` field out of a FastAPI error body without full JSON parsing.
  static String? _extractDetail(String body) {
    final match = RegExp(r'"detail"\s*:\s*"([^"]+)"').firstMatch(body);
    return match?.group(1);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RequestLogger (debug only)
// ─────────────────────────────────────────────────────────────────────────────

class RequestLogger {
  const RequestLogger._();

  static void request(String method, Uri url, {String? body}) {
    if (!kDebugMode) return;
    final bodySnippet =
        body != null && body.length > 200 ? '${body.substring(0, 200)}…' : body;
    debugPrint(
      '[HTTP] ▶  $method ${url.path}'
      '${url.hasQuery ? "?${url.query}" : ""}'
      '${bodySnippet != null ? "\n        body: $bodySnippet" : ""}',
    );
  }

  static void response(http.Response response) {
    if (!kDebugMode) return;
    final bodySnippet = response.body.length > 300
        ? '${response.body.substring(0, 300)}…'
        : response.body;
    debugPrint(
      '[HTTP] ◀  ${response.statusCode} ${response.request?.url.path}\n'
      '        body: $bodySnippet',
    );
  }

  static void error(Object e) {
    if (!kDebugMode) return;
    debugPrint('[HTTP] ✖  $e');
  }
}
