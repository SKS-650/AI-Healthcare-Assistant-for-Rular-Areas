import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

// ── API Client singleton ──────────────────────────────────────────────────────
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const _storage = FlutterSecureStorage();
  late final Dio _dio = _buildDio();

  Dio _buildDio() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBase,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: AppConstants.kAccessToken);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await tryRefresh();
          if (refreshed) {
            final token = await _storage.read(key: AppConstants.kAccessToken);
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $token';
            try {
              final resp = await _dio.fetch(opts);
              handler.resolve(resp);
              return;
            } catch (_) {}
          }
          await clearTokens();
        }
        handler.next(error);
      },
    ));

    return dio;
  }

  // ── Token refresh (public so auth_provider can call it directly) ──────────
  Future<bool> tryRefresh() async {
    try {
      final refreshToken =
          await _storage.read(key: AppConstants.kRefreshToken);
      if (refreshToken == null || refreshToken.isEmpty) return false;

      // Use a fresh Dio without interceptors to avoid recursion
      final plainDio = Dio(BaseOptions(
        baseUrl: AppConstants.apiBase,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ));
      final resp = await plainDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      // Backend refresh response: { tokens: { access_token, refresh_token } }
      // OR flat: { access_token, refresh_token }
      final d = resp.data as Map<String, dynamic>;
      final tokens = d['tokens'] as Map<String, dynamic>?;
      final newAccess =
          tokens?['access_token'] as String? ?? d['access_token'] as String?;
      final newRefresh =
          tokens?['refresh_token'] as String? ?? d['refresh_token'] as String?;

      if (newAccess != null) {
        await _storage.write(key: AppConstants.kAccessToken, value: newAccess);
        if (newRefresh != null && newRefresh.isNotEmpty) {
          await _storage.write(
              key: AppConstants.kRefreshToken, value: newRefresh);
        }
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> saveTokens(
      {required String access, required String refresh}) async {
    await _storage.write(key: AppConstants.kAccessToken, value: access);
    await _storage.write(key: AppConstants.kRefreshToken, value: refresh);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.kAccessToken);
    await _storage.delete(key: AppConstants.kRefreshToken);
    await _storage.delete(key: AppConstants.kAdminUser);
  }

  Future<void> logout() => clearTokens();

  Future<String?> getAccessToken() =>
      _storage.read(key: AppConstants.kAccessToken);

  Future<Response> get(String path,
          {Map<String, dynamic>? queryParameters}) =>
      _dio.get(path, queryParameters: queryParameters);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> patch(String path, {dynamic data}) =>
      _dio.patch(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);
}

// ── Error helper ──────────────────────────────────────────────────────────────
String errorMessage(Object e) {
  if (e is DioException) {
    if (e.response?.data is Map) {
      return (e.response!.data as Map)['detail']?.toString() ??
          e.response!.data.toString();
    }
    if (e.response?.data is String && (e.response!.data as String).isNotEmpty) {
      return e.response!.data as String;
    }
    return e.message ?? 'Request failed';
  }
  return e.toString();
}

// ── API result ────────────────────────────────────────────────────────────────
class ApiResult {
  final dynamic data;
  final String? error;
  bool get isSuccess => error == null;

  const ApiResult.success(this.data) : error = null;
  const ApiResult.failure(this.error) : data = null;

  static ApiResult fromError(Object e) =>
      ApiResult.failure(errorMessage(e));
}
