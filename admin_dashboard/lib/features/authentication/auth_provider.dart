import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api.dart';
import '../../core/constants.dart';

// ── Auth state ────────────────────────────────────────────────────────────────
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? user;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    bool clearError = false,
    Map<String, dynamic>? user,
  }) =>
      AuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        user: user ?? this.user,
      );

  // Works with both:
  //   login response  → { user_id, full_name, email, role, ... }
  //   /auth/me        → { user_id, full_name, email, role, ... }
  String get userName {
    final v = user?['full_name'] as String?;
    if (v != null && v.trim().isNotEmpty) return v.trim();
    final e = user?['email'] as String? ?? '';
    return e.split('@').first;
  }

  String get userEmail => user?['email'] as String? ?? '';
  String get userRole  => user?['role']  as String? ?? 'admin';

  String get userInitials {
    final n = userName;
    final parts = n.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 &&
        parts[0].isNotEmpty &&
        parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return n.isNotEmpty ? n[0].toUpperCase() : 'A';
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  static const _storage = FlutterSecureStorage();

  AuthNotifier() : super(const AuthState(isLoading: true)) {
    _restoreSession();
  }

  // ── Restore session on app start ──────────────────────────────────────────
  Future<void> _restoreSession() async {
    try {
      final token    = await _storage.read(key: AppConstants.kAccessToken);
      final userData = await _storage.read(key: AppConstants.kAdminUser);

      if (token == null || userData == null) {
        state = const AuthState();
        return;
      }

      // Validate token with the server
      try {
        final resp = await ApiClient.instance.get('/auth/me');
        final me   = resp.data as Map<String, dynamic>;
        await _storage.write(
            key: AppConstants.kAdminUser, value: jsonEncode(me));
        state = AuthState(isAuthenticated: true, user: me);
      } catch (_) {
        // Try a silent token refresh
        final ok = await ApiClient.instance.tryRefresh();
        if (ok) {
          try {
            final resp = await ApiClient.instance.get('/auth/me');
            final me   = resp.data as Map<String, dynamic>;
            await _storage.write(
                key: AppConstants.kAdminUser, value: jsonEncode(me));
            state = AuthState(isAuthenticated: true, user: me);
            return;
          } catch (_) {}
        }
        await _wipe();
      }
    } catch (_) {
      state = const AuthState();
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<String?> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final resp = await ApiClient.instance.post('/auth/login', data: {
        'email':    email,
        'password': password,
      });
      final d = resp.data as Map<String, dynamic>;

      // Backend LoginResponse shape:
      // { user_id, email, role, full_name?,
      //   tokens: { access_token, refresh_token, token_type, expires_in } }
      final role = d['role'] as String?
          ?? (d['user'] as Map<String, dynamic>?)?['role'] as String?
          ?? '';

      if (!['admin', 'super_admin'].contains(role)) {
        state = const AuthState(
            error: 'Access denied. Admin credentials required.');
        return 'Access denied. Admin credentials required.';
      }

      // Extract tokens
      final tokens      = d['tokens'] as Map<String, dynamic>?;
      final accessToken = tokens?['access_token'] as String?
          ?? d['access_token'] as String?;
      final refreshToken = tokens?['refresh_token'] as String?
          ?? d['refresh_token'] as String?;

      if (accessToken == null) {
        const msg = 'Server did not return an access token.';
        state = const AuthState(error: msg);
        return msg;
      }

      await ApiClient.instance.saveTokens(
        access:  accessToken,
        refresh: refreshToken ?? '',
      );

      // Fetch full profile from /auth/me so we always have fresh data
      Map<String, dynamic> user;
      try {
        final meResp = await ApiClient.instance.get('/auth/me');
        user = meResp.data as Map<String, dynamic>;
      } catch (_) {
        user = {
          'user_id':   d['user_id'],
          'full_name': d['full_name']
              ?? email.split('@').first.replaceAll('.', ' '),
          'email':     d['email'] ?? email,
          'role':      role,
          'is_active': true,
        };
      }

      await _storage.write(
          key: AppConstants.kAdminUser, value: jsonEncode(user));
      state = AuthState(isAuthenticated: true, user: user);
      return null;
    } catch (e) {
      final msg = errorMessage(e);
      state = AuthState(error: msg);
      return msg;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      final refresh = await _storage.read(key: AppConstants.kRefreshToken);
      if (refresh != null && refresh.isNotEmpty) {
        await ApiClient.instance.post(
            '/auth/logout', data: {'refresh_token': refresh});
      }
    } catch (_) {}
    await _wipe();
  }

  Future<void> _wipe() async {
    await ApiClient.instance.clearTokens();
    state = const AuthState();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────
final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>(
        (ref) => AuthNotifier());
