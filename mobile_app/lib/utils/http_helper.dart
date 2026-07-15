import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Helper class for making HTTP requests with proper timeout and error handling
class HttpHelper {
  const HttpHelper._();

  /// Makes a GET request with timeout
  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    int? timeoutSeconds,
  }) async {
    try {
      return await http
          .get(url, headers: headers)
          .timeout(
            Duration(seconds: timeoutSeconds ?? ApiConfig.connectionTimeout),
            onTimeout: () => throw TimeoutException(
              'Connection timed out. Please check your internet connection.',
            ),
          );
    } on SocketException {
      throw _buildNetworkException();
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Makes a POST request with timeout
  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    int? timeoutSeconds,
  }) async {
    try {
      return await http
          .post(url, headers: headers, body: body)
          .timeout(
            Duration(seconds: timeoutSeconds ?? ApiConfig.connectionTimeout),
            onTimeout: () => throw TimeoutException(
              'Connection timed out. Please check your internet connection.',
            ),
          );
    } on SocketException {
      throw _buildNetworkException();
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Makes a PUT request with timeout
  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    int? timeoutSeconds,
  }) async {
    try {
      return await http
          .put(url, headers: headers, body: body)
          .timeout(
            Duration(seconds: timeoutSeconds ?? ApiConfig.connectionTimeout),
            onTimeout: () => throw TimeoutException(
              'Connection timed out. Please check your internet connection.',
            ),
          );
    } on SocketException {
      throw _buildNetworkException();
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Makes a DELETE request with timeout
  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    int? timeoutSeconds,
  }) async {
    try {
      return await http
          .delete(url, headers: headers)
          .timeout(
            Duration(seconds: timeoutSeconds ?? ApiConfig.connectionTimeout),
            onTimeout: () => throw TimeoutException(
              'Connection timed out. Please check your internet connection.',
            ),
          );
    } on SocketException {
      throw _buildNetworkException();
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Builds a detailed network exception message
  static Exception _buildNetworkException() {
    return const SocketException(
      'Cannot connect to server. Please ensure:\n'
      '1. Backend server is running\n'
      '2. Your device is on the same WiFi network\n'
      '3. Firewall allows connections on port 8000\n'
      '\nSee MOBILE_TROUBLESHOOTING.md for detailed help.',
    );
  }
}
