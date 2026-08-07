import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class AdminSession {
  final String id;
  final String userId;
  final String? userEmail;
  final String? userName;
  final String? deviceInfo;
  final String? ipAddress;
  final bool isActive;
  final String? expiresAt;
  final String createdAt;
  final String? lastActiveAt;

  const AdminSession({
    required this.id,
    required this.userId,
    this.userEmail,
    this.userName,
    this.deviceInfo,
    this.ipAddress,
    this.isActive = true,
    this.expiresAt,
    required this.createdAt,
    this.lastActiveAt,
  });

  factory AdminSession.fromJson(Map<String, dynamic> j) => AdminSession(
        id: j['id'] as String? ?? '',
        userId: j['user_id'] as String? ?? '',
        userEmail: j['user_email'] as String?,
        userName: j['user_name'] as String?,
        deviceInfo: j['device_info'] as String?,
        ipAddress: j['ip_address'] as String?,
        isActive: j['is_active'] as bool? ?? true,
        expiresAt: j['expires_at'] as String?,
        createdAt: j['created_at'] as String? ?? '',
        lastActiveAt: j['last_active_at'] as String?,
      );
}

class AdminRefreshToken {
  final String id;
  final String userId;
  final String? userEmail;
  final String? userName;
  final String? deviceInfo;
  final String? ipAddress;
  final bool isRevoked;
  final String expiresAt;
  final String createdAt;
  final String? lastUsedAt;

  const AdminRefreshToken({
    required this.id,
    required this.userId,
    this.userEmail,
    this.userName,
    this.deviceInfo,
    this.ipAddress,
    this.isRevoked = false,
    required this.expiresAt,
    required this.createdAt,
    this.lastUsedAt,
  });

  factory AdminRefreshToken.fromJson(Map<String, dynamic> j) => AdminRefreshToken(
        id: j['id'] as String? ?? '',
        userId: j['user_id'] as String? ?? '',
        userEmail: j['user_email'] as String?,
        userName: j['user_name'] as String?,
        deviceInfo: j['device_info'] as String?,
        ipAddress: j['ip_address'] as String?,
        isRevoked: j['is_revoked'] as bool? ?? false,
        expiresAt: j['expires_at'] as String? ?? '',
        createdAt: j['created_at'] as String? ?? '',
        lastUsedAt: j['last_used_at'] as String?,
      );
}

class OtpLog {
  final String id;
  final String userId;
  final String? userEmail;
  final String? userName;
  final String purpose;
  final int attempts;
  final bool isUsed;
  final String expiresAt;
  final String createdAt;

  const OtpLog({
    required this.id,
    required this.userId,
    this.userEmail,
    this.userName,
    required this.purpose,
    this.attempts = 0,
    this.isUsed = false,
    required this.expiresAt,
    required this.createdAt,
  });

  factory OtpLog.fromJson(Map<String, dynamic> j) => OtpLog(
        id: j['id'] as String? ?? '',
        userId: j['user_id'] as String? ?? '',
        userEmail: j['user_email'] as String?,
        userName: j['user_name'] as String?,
        purpose: j['purpose'] as String? ?? '',
        attempts: j['attempts'] as int? ?? 0,
        isUsed: j['is_used'] as bool? ?? false,
        expiresAt: j['expires_at'] as String? ?? '',
        createdAt: j['created_at'] as String? ?? '',
      );
}

class AuthStats {
  final int activeSessions;
  final int activeTokens;
  final int pendingOtps;
  final int usedOtps;
  final int unverifiedEmails;
  final int unverifiedPhones;

  const AuthStats({
    this.activeSessions = 0,
    this.activeTokens = 0,
    this.pendingOtps = 0,
    this.usedOtps = 0,
    this.unverifiedEmails = 0,
    this.unverifiedPhones = 0,
  });

  factory AuthStats.fromJson(Map<String, dynamic> j) => AuthStats(
        activeSessions: j['active_sessions'] as int? ?? 0,
        activeTokens: j['active_tokens'] as int? ?? 0,
        pendingOtps: j['pending_otps'] as int? ?? 0,
        usedOtps: j['used_otps'] as int? ?? 0,
        unverifiedEmails: j['unverified_emails'] as int? ?? 0,
        unverifiedPhones: j['unverified_phones'] as int? ?? 0,
      );
}

// ── State ─────────────────────────────────────────────────────────────────────

class AuthManagementState {
  final bool isLoading;
  final String? error;
  final AuthStats stats;

  // Sessions
  final List<AdminSession> sessions;
  final int sessionsTotal;
  final int sessionsPage;

  // Tokens
  final List<AdminRefreshToken> tokens;
  final int tokensTotal;
  final int tokensPage;

  // OTP logs
  final List<OtpLog> otpLogs;
  final int otpLogsTotal;
  final int otpLogsPage;

  final int pageSize;

  const AuthManagementState({
    this.isLoading = false,
    this.error,
    this.stats = const AuthStats(),
    this.sessions = const [],
    this.sessionsTotal = 0,
    this.sessionsPage = 1,
    this.tokens = const [],
    this.tokensTotal = 0,
    this.tokensPage = 1,
    this.otpLogs = const [],
    this.otpLogsTotal = 0,
    this.otpLogsPage = 1,
    this.pageSize = 20,
  });

  AuthManagementState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    AuthStats? stats,
    List<AdminSession>? sessions,
    int? sessionsTotal,
    int? sessionsPage,
    List<AdminRefreshToken>? tokens,
    int? tokensTotal,
    int? tokensPage,
    List<OtpLog>? otpLogs,
    int? otpLogsTotal,
    int? otpLogsPage,
  }) =>
      AuthManagementState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        stats: stats ?? this.stats,
        sessions: sessions ?? this.sessions,
        sessionsTotal: sessionsTotal ?? this.sessionsTotal,
        sessionsPage: sessionsPage ?? this.sessionsPage,
        tokens: tokens ?? this.tokens,
        tokensTotal: tokensTotal ?? this.tokensTotal,
        tokensPage: tokensPage ?? this.tokensPage,
        otpLogs: otpLogs ?? this.otpLogs,
        otpLogsTotal: otpLogsTotal ?? this.otpLogsTotal,
        otpLogsPage: otpLogsPage ?? this.otpLogsPage,
        pageSize: pageSize,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class AuthManagementNotifier extends StateNotifier<AuthManagementState> {
  AuthManagementNotifier() : super(const AuthManagementState()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        ApiClient.instance.get('/admin/auth/sessions',
            queryParameters: {'page': 1, 'page_size': state.pageSize}),
        ApiClient.instance.get('/admin/auth/tokens',
            queryParameters: {'page': 1, 'page_size': state.pageSize}),
        ApiClient.instance.get('/admin/auth/otp-logs',
            queryParameters: {'page': 1, 'page_size': state.pageSize}),
        // Fetch unverified email count via users list with email_verified=false
        ApiClient.instance.get('/admin/users',
            queryParameters: {'is_active': true, 'page': 1, 'page_size': 1}),
      ]);

      final sd = results[0].data as Map<String, dynamic>;
      final td = results[1].data as Map<String, dynamic>;
      final od = results[2].data as Map<String, dynamic>;

      // Count unverified: use users endpoint total where email_verified=false
      int unverifiedEmails = 0;
      try {
        final uvResp = await ApiClient.instance.get('/admin/users',
            queryParameters: {'email_verified': false, 'page': 1, 'page_size': 1});
        unverifiedEmails = (uvResp.data as Map<String, dynamic>)['total'] as int? ?? 0;
      } catch (_) {}

      state = state.copyWith(
        isLoading: false,
        clearError: true,
        sessions: (sd['sessions'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(AdminSession.fromJson)
            .toList(),
        sessionsTotal: sd['total'] as int? ?? 0,
        sessionsPage: 1,
        tokens: (td['tokens'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(AdminRefreshToken.fromJson)
            .toList(),
        tokensTotal: td['total'] as int? ?? 0,
        tokensPage: 1,
        otpLogs: (od['otp_logs'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(OtpLog.fromJson)
            .toList(),
        otpLogsTotal: od['total'] as int? ?? 0,
        otpLogsPage: 1,
        stats: AuthStats(
          activeSessions: sd['active_count'] as int? ?? 0,
          activeTokens: td['active_count'] as int? ?? 0,
          pendingOtps: od['pending_count'] as int? ?? 0,
          usedOtps: od['used_count'] as int? ?? 0,
          unverifiedEmails: unverifiedEmails,
        ),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  Future<void> loadSessions({int? page}) async {
    final p = page ?? state.sessionsPage;
    state = state.copyWith(sessionsPage: p, isLoading: true);
    try {
      final resp = await ApiClient.instance.get('/admin/auth/sessions',
          queryParameters: {'page': p, 'page_size': state.pageSize});
      final d = resp.data as Map<String, dynamic>;
      state = state.copyWith(
        isLoading: false,
        sessions: (d['sessions'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(AdminSession.fromJson)
            .toList(),
        sessionsTotal: d['total'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  Future<void> loadTokens({int? page}) async {
    final p = page ?? state.tokensPage;
    state = state.copyWith(tokensPage: p, isLoading: true);
    try {
      final resp = await ApiClient.instance.get('/admin/auth/tokens',
          queryParameters: {'page': p, 'page_size': state.pageSize});
      final d = resp.data as Map<String, dynamic>;
      state = state.copyWith(
        isLoading: false,
        tokens: (d['tokens'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(AdminRefreshToken.fromJson)
            .toList(),
        tokensTotal: d['total'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  Future<void> loadOtpLogs({int? page}) async {
    final p = page ?? state.otpLogsPage;
    state = state.copyWith(otpLogsPage: p, isLoading: true);
    try {
      final resp = await ApiClient.instance.get('/admin/auth/otp-logs',
          queryParameters: {'page': p, 'page_size': state.pageSize});
      final d = resp.data as Map<String, dynamic>;
      state = state.copyWith(
        isLoading: false,
        otpLogs: (d['otp_logs'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(OtpLog.fromJson)
            .toList(),
        otpLogsTotal: d['total'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  Future<bool> revokeSession(String sessionId) async {
    try {
      await ApiClient.instance.delete('/admin/auth/sessions/$sessionId');
      loadSessions();
      return true;
    } catch (e) {
      state = state.copyWith(error: errorMessage(e));
      return false;
    }
  }

  Future<bool> revokeAllUserSessions(String userId) async {
    try {
      await ApiClient.instance.delete('/admin/auth/sessions/user/$userId');
      loadSessions();
      return true;
    } catch (e) {
      state = state.copyWith(error: errorMessage(e));
      return false;
    }
  }

  Future<bool> revokeToken(String tokenId) async {
    try {
      await ApiClient.instance.delete('/admin/auth/tokens/$tokenId');
      loadTokens();
      return true;
    } catch (e) {
      state = state.copyWith(error: errorMessage(e));
      return false;
    }
  }

  Future<bool> verifyEmail(String userId) async {
    try {
      await ApiClient.instance.patch('/admin/auth/verify-email/$userId');
      return true;
    } catch (e) {
      state = state.copyWith(error: errorMessage(e));
      return false;
    }
  }

  Future<bool> verifyPhone(String userId) async {
    try {
      await ApiClient.instance.patch('/admin/auth/verify-phone/$userId');
      return true;
    } catch (e) {
      state = state.copyWith(error: errorMessage(e));
      return false;
    }
  }
}

final authManagementProvider =
    StateNotifierProvider<AuthManagementNotifier, AuthManagementState>(
        (ref) => AuthManagementNotifier());
