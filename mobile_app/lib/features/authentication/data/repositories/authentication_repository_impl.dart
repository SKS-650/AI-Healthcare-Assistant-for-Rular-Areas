import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../config/api_config.dart';
import '../../domain/entities/user.dart';
import '../../domain/exceptions/auth_exception.dart';
import '../../domain/repositories/authentication_repository.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  UserEntity? _cachedUser;
  String? _accessToken;
  String? _refreshToken;
  bool _seenOnboarding = false;

  /// Exposes the current access token so other providers can make authenticated requests.
  String? get accessToken => _accessToken;

  @override
  Future<UserEntity> getCurrentUser() async {
    return _cachedUser ?? UserEntity.empty;
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'device_info': 'flutter_app',
      }),
    );

    if (response.statusCode != 200) {
      throw _mapError(response);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _accessToken = data['tokens']?['access_token']?.toString();
    _refreshToken = data['tokens']?['refresh_token']?.toString();

    final meResponse = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/users/me'),
      headers: _authHeaders(),
    );

    if (meResponse.statusCode == 200) {
      final meData = jsonDecode(meResponse.body) as Map<String, dynamic>;
      _cachedUser = _mapUserFromSummary(meData);
      return _cachedUser!;
    }

    _cachedUser = UserEntity(
      id: data['user_id']?.toString() ?? '',
      email: data['email']?.toString() ?? email,
      name: data['full_name']?.toString() ?? '',
      isProfileComplete: false,
    );
    return _cachedUser!;
  }

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

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _cachedUser = UserEntity(
      id: data['user_id']?.toString() ?? '',
      email: data['email']?.toString() ?? email,
      name: name,
      isProfileComplete: false,
    );
    return _cachedUser!;
  }

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
    return guestUser;
  }

  @override
  Future<String?> forgotPassword({required String email}) async {
    // Use the OTP-based flow (mobile-friendly) instead of the link-based flow.
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/forgot-password-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw _mapError(response);
    }

    // In development mode the backend returns the OTP directly in the response
    // so the user can test without a real email inbox.
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['dev_otp']?.toString(); // null in production
  }

  @override
  Future<String> verifyOtp({
    required String email,
    required String otp,
  }) async {
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

  @override
  Future<UserEntity> completeProfile({
    required String userId,
    required String name,
    String? phone,
    String? gender,
    int? age,
    String? language,
  }) async {
    final payload = <String, dynamic>{
      'full_name': name,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (language != null && language.isNotEmpty) 'preferred_language': language,
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
          '${dateOfBirth.year.toString().padLeft(4, '0')}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}';
    }

    if (profilePayload.isNotEmpty) {
      final profileResponse = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/users/profile'),
        headers: _authHeaders(),
        body: jsonEncode(profilePayload),
      );
      if (profileResponse.statusCode != 201 && profileResponse.statusCode != 200) {
        final updateResponse = await http.put(
          Uri.parse('${ApiConfig.baseUrl}/api/v1/users/profile'),
          headers: _authHeaders(),
          body: jsonEncode(profilePayload),
        );
        if (updateResponse.statusCode != 200) {
          throw _mapError(updateResponse);
        }
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
    return updatedUser;
  }

  @override
  Future<void> logout() async {
    if (_refreshToken != null && _refreshToken!.isNotEmpty) {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/logout'),
        headers: _authHeaders(),
        body: jsonEncode({'refresh_token': _refreshToken}),
      );
    }
    _cachedUser = null;
    _accessToken = null;
    _refreshToken = null;
  }

  @override
  Future<bool> hasSeenOnboarding() async => _seenOnboarding;

  @override
  Future<void> markOnboardingSeen() async {
    _seenOnboarding = true;
  }

  Map<String, String> _authHeaders() {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  UserEntity _mapUserFromSummary(Map<String, dynamic> data) {
    return UserEntity(
      id: data['user_id']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      name: data['full_name']?.toString(),
      phone: data['phone']?.toString(),
      language: data['preferred_language']?.toString(),
      isProfileComplete: true,
    );
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
        // Pydantic validation error format: detail is a list
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
