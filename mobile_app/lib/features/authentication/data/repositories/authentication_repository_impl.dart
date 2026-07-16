import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/api_config.dart';
import '../../domain/entities/user.dart';
import '../../domain/exceptions/auth_exception.dart';
import '../../domain/repositories/authentication_repository.dart';

// SharedPreferences keys
const _kAccessToken = 'auth_access_token';
const _kRefreshToken = 'auth_refresh_token';
const _kCachedUser = 'auth_cached_user';
const _kSeenOnboarding = 'seen_onboarding';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  UserEntity? _cachedUser;
  String? _accessToken;
  String? _refreshToken;
  bool _seenOnboarding = false;
  bool _initialized = false;

  /// Ensure tokens and user are loaded from persistent storage.
  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString(_kAccessToken);
      _refreshToken = prefs.getString(_kRefreshToken);
      _seenOnboarding = prefs.getBool(_kSeenOnboarding) ?? false;
      final userJson = prefs.getString(_kCachedUser);
      if (userJson != null) {
        final map = jsonDecode(userJson) as Map<String, dynamic>;
        _cachedUser = _userFromMap(map);
      }
    } catch (_) {
      // If prefs are unavailable just fall back to in-memory state.
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_accessToken != null) {
        await prefs.setString(_kAccessToken, _accessToken!);
      } else {
        await prefs.remove(_kAccessToken);
      }
      if (_refreshToken != null) {
        await prefs.setString(_kRefreshToken, _refreshToken!);
      } else {
        await prefs.remove(_kRefreshToken);
      }
      if (_cachedUser != null) {
        await prefs.setString(
          _kCachedUser,
          jsonEncode(_userToMap(_cachedUser!)),
        );
      } else {
        await prefs.remove(_kCachedUser);
      }
    } catch (_) {}
  }

  Future<void> _persistOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kSeenOnboarding, _seenOnboarding);
    } catch (_) {}
  }

  // ── Token getter (used by other features) ────────────────────────────────

  /// The current access token, or null if not authenticated.
  @override
  String? get accessToken => _accessToken;

  // ── getCurrentUser ────────────────────────────────────────────────────────

  @override
  Future<UserEntity> getCurrentUser() async {
    await _ensureInitialized();
    return _cachedUser ?? UserEntity.empty;
  }

  // ── login ─────────────────────────────────────────────────────────────────

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    await _ensureInitialized();
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'device_info': 'flutter_app',
            }),
          )
          .timeout(
            const Duration(seconds: ApiConfig.connectionTimeout),
            onTimeout: () {
              throw const SocketException(
                'Connection timed out. Please check your internet connection.',
              );
            },
          );

      if (response.statusCode != 200) {
        throw _mapError(response);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _accessToken = data['tokens']?['access_token']?.toString();
      _refreshToken = data['tokens']?['refresh_token']?.toString();

      // Fetch full profile from /users/me
      final meResponse = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/api/v1/users/me'),
            headers: _authHeaders(),
          )
          .timeout(const Duration(seconds: ApiConfig.connectionTimeout));

      if (meResponse.statusCode == 200) {
        final meData = jsonDecode(meResponse.body) as Map<String, dynamic>;
        _cachedUser = _mapUserFromProfile(meData);
      } else {
        // Fallback: build a minimal user from the login response
        _cachedUser = UserEntity(
          id: data['user_id']?.toString() ?? '',
          email: data['email']?.toString() ?? email,
          name: data['full_name']?.toString() ?? '',
          isProfileComplete: false,
        );
      }

      await _persist();
      return _cachedUser!;
    } on SocketException {
      throw AuthException(
        'Cannot connect to server at ${ApiConfig.baseUrl}. Please start the backend and try again.',
      );
    } on http.ClientException {
      throw AuthException(
        'Cannot connect to server at ${ApiConfig.baseUrl}. Please start the backend and try again.',
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Login failed: $e');
    }
  }

  // ── register ──────────────────────────────────────────────────────────────

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': name,
        'email': email,
        'password': password,
        'confirm_password': password,
        'role': 'patient',
        'language': 'en',
      }),
    );

    if (response.statusCode != 201) {
      throw _mapError(response);
    }

    // Auto-login after registration so we have a token immediately.
    try {
      return await login(email: email, password: password);
    } catch (_) {
      // Auto-login failed (e.g. email verification required).
      // Return a minimal user so the UI can still proceed.
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _cachedUser = UserEntity(
        id: data['user_id']?.toString() ?? '',
        email: data['email']?.toString() ?? email,
        name: name,
        isProfileComplete: false,
      );
      await _persist();
      return _cachedUser!;
    }
  }

  // ── loginAsGuest ──────────────────────────────────────────────────────────

  @override
  Future<UserEntity> loginAsGuest() async {
    const guestUser = UserEntity(
      id: 'guest',
      email: 'guest@health.ai',
      name: 'Guest',
      isGuest: true,
      isProfileComplete: true,
    );
    _cachedUser = guestUser;
    _accessToken = null;
    _refreshToken = null;
    // Deliberately do NOT persist the guest token so cold-restart lands on
    // the login screen rather than in a broken guest state.
    return guestUser;
  }

  // ── forgotPassword ────────────────────────────────────────────────────────

  @override
  Future<String?> forgotPassword({required String email}) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/forgot-password-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw _mapError(response);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['dev_otp']?.toString(); // null in production
  }

  // ── verifyOtp ─────────────────────────────────────────────────────────────

  @override
  Future<String> verifyOtp({required String email, required String otp}) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/verify-reset-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    if (response.statusCode != 200) {
      throw _mapError(response);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final token = data['reset_token']?.toString();
    if (token == null || token.isEmpty) {
      throw Exception('Invalid response from server.');
    }
    return token;
  }

  // ── resetPassword ─────────────────────────────────────────────────────────

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': resetToken,
        'new_password': newPassword,
        'confirm_password': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw _mapError(response);
    }
  }

  // ── completeProfile ───────────────────────────────────────────────────────

  @override
  Future<UserEntity> completeProfile({
    required String userId,
    required String name,
    String? phone,
    String? gender,
    int? age,
    String? language,
  }) async {
    await _ensureInitialized();

    final payload = <String, dynamic>{
      'full_name': name,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (language != null && language.isNotEmpty)
        'preferred_language': _languageToCode(language),
    };

    final meResponse = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/users/me'),
      headers: _authHeaders(),
      body: jsonEncode(payload),
    );

    if (meResponse.statusCode != 200) {
      throw _mapError(meResponse);
    }

    final profilePayload = <String, dynamic>{};
    if (gender != null && gender.isNotEmpty) {
      profilePayload['gender'] = gender.toLowerCase();
    }
    if (age != null) {
      final dateOfBirth = DateTime.now().subtract(Duration(days: age * 365));
      profilePayload['date_of_birth'] =
          '${dateOfBirth.year.toString().padLeft(4, '0')}-'
          '${dateOfBirth.month.toString().padLeft(2, '0')}-'
          '${dateOfBirth.day.toString().padLeft(2, '0')}';
    }

    if (profilePayload.isNotEmpty) {
      final profileResponse = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/users/profile'),
        headers: _authHeaders(),
        body: jsonEncode(profilePayload),
      );
      if (profileResponse.statusCode == 201 ||
          profileResponse.statusCode == 200) {
        // Success — profile created or already up-to-date.
      } else if (profileResponse.statusCode == 404) {
        // Profile record doesn't exist yet in an edge case — retry with PUT.
        final updateResponse = await http.put(
          Uri.parse('${ApiConfig.baseUrl}/api/v1/users/profile'),
          headers: _authHeaders(),
          body: jsonEncode(profilePayload),
        );
        if (updateResponse.statusCode != 200) {
          throw _mapError(updateResponse);
        }
      } else {
        // 422 validation error or any other failure — throw immediately
        // without silently issuing a PUT that would swallow the real error.
        throw _mapError(profileResponse);
      }
    }

    final updatedUser = UserEntity(
      id: userId,
      email: _cachedUser?.email ?? '',
      name: name,
      phone: phone,
      gender: gender,
      age: age,
      language: language,
      isProfileComplete: true,
    );
    _cachedUser = updatedUser;
    await _persist();
    return updatedUser;
  }

  // ── logout ────────────────────────────────────────────────────────────────

  @override
  Future<void> logout() async {
    await _ensureInitialized();
    if (_refreshToken != null && _refreshToken!.isNotEmpty) {
      try {
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/logout'),
          headers: _authHeaders(),
          body: jsonEncode({'refresh_token': _refreshToken}),
        );
      } catch (_) {
        // Best-effort — clear local state regardless.
      }
    }
    _cachedUser = null;
    _accessToken = null;
    _refreshToken = null;
    await _persist();
  }

  // ── onboarding ────────────────────────────────────────────────────────────

  @override
  Future<bool> hasSeenOnboarding() async {
    await _ensureInitialized();
    return _seenOnboarding;
  }

  @override
  Future<void> markOnboardingSeen() async {
    _seenOnboarding = true;
    await _persistOnboarding();
  }

  // ── Token refresh ─────────────────────────────────────────────────────────

  /// Attempt to silently refresh the access token using the stored refresh token.
  /// Returns the new access token on success, null on failure.
  Future<String?> refreshAccessToken() async {
    await _ensureInitialized();
    final rt = _refreshToken;
    if (rt == null || rt.isEmpty) return null;

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/refresh'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh_token': rt}),
          )
          .timeout(const Duration(seconds: ApiConfig.connectionTimeout));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccess =
            data['access_token']?.toString() ??
            data['tokens']?['access_token']?.toString();
        if (newAccess != null && newAccess.isNotEmpty) {
          _accessToken = newAccess;
          // Some backends also rotate the refresh token on each refresh.
          final newRefresh =
              data['refresh_token']?.toString() ??
              data['tokens']?['refresh_token']?.toString();
          if (newRefresh != null && newRefresh.isNotEmpty) {
            _refreshToken = newRefresh;
          }
          await _persist();
          return _accessToken;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Make an authenticated GET/POST/PUT with automatic token refresh on 401.
  Future<http.Response> authenticatedRequest(
    Future<http.Response> Function(Map<String, String> headers) request,
  ) async {
    await _ensureInitialized();
    var response = await request(_authHeaders());
    if (response.statusCode == 401) {
      final newToken = await refreshAccessToken();
      if (newToken != null) {
        response = await request(_authHeaders());
      }
    }
    return response;
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Maps a display language name to the locale code the backend expects.
  static String _languageToCode(String display) {
    const map = {
      'English': 'en',
      'Hindi': 'hi',
      'Bengali': 'bn',
      'Telugu': 'te',
      'Marathi': 'mr',
      'Tamil': 'ta',
      'Gujarati': 'gu',
      'Kannada': 'kn',
      'Punjabi': 'pa',
      'Nepali': 'ne',
      'Bhojpuri': 'bho',
      'Other': 'other',
    };
    return map[display] ?? display.toLowerCase();
  }

  Map<String, String> _authHeaders() {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  /// Map the /users/me response to a UserEntity.
  /// The backend returns `preferred_language` in the users/me payload.
  UserEntity _mapUserFromProfile(Map<String, dynamic> data) {
    return UserEntity(
      id: data['user_id']?.toString() ?? data['id']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      name: data['full_name']?.toString(),
      phone: data['phone']?.toString(),
      // Backend field is 'preferred_language' (not 'language')
      language: data['preferred_language']?.toString(),
      isProfileComplete: true,
    );
  }

  UserEntity _userFromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString(),
      phone: map['phone']?.toString(),
      gender: map['gender']?.toString(),
      age: map['age'] as int?,
      language: map['language']?.toString(),
      isGuest: map['isGuest'] as bool? ?? false,
      isProfileComplete: map['isProfileComplete'] as bool? ?? false,
    );
  }

  Map<String, dynamic> _userToMap(UserEntity user) {
    return {
      'id': user.id,
      'email': user.email,
      'name': user.name,
      'phone': user.phone,
      'gender': user.gender,
      'age': user.age,
      'language': user.language,
      'isGuest': user.isGuest,
      'isProfileComplete': user.isProfileComplete,
    };
  }

  Exception _mapError(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final detail = body['detail'];
        if (detail is String && detail.isNotEmpty) {
          return AuthException(detail);
        }
        if (detail is Map<String, dynamic>) {
          final msg = detail['message']?.toString();
          if (msg != null && msg.isNotEmpty) return AuthException(msg);
        }
        // Pydantic validation error: detail is a list
        if (detail is List && detail.isNotEmpty) {
          final firstError = detail.first;
          if (firstError is Map<String, dynamic>) {
            final msg = firstError['msg']?.toString();
            if (msg != null && msg.isNotEmpty) return AuthException(msg);
          }
        }
      }
    } catch (_) {}
    return AuthException('Request failed with status ${response.statusCode}.');
  }
}
