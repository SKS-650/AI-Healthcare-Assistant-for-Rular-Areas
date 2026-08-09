import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api.dart';
import '../../core/models.dart';

// ── Sub-models ────────────────────────────────────────────────────────────────

class UserConversation {
  final int id;
  final String title;
  final String language;
  final int messageCount;
  final int emergencyCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserConversation({
    required this.id,
    required this.title,
    required this.language,
    required this.messageCount,
    required this.emergencyCount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserConversation.fromJson(Map<String, dynamic> j) => UserConversation(
        id: j['id'] as int,
        title: j['title'] as String? ?? 'Chat',
        language: j['language'] as String? ?? 'en',
        messageCount: j['message_count'] as int? ?? 0,
        emergencyCount: j['emergency_count'] as int? ?? 0,
        isActive: j['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(j['created_at'] as String),
        updatedAt: DateTime.parse(j['updated_at'] as String),
      );
}

class UserEmergency {
  final String id;
  final int? age;
  final String? gender;
  final List<String> symptoms;
  final String riskLevel;
  final double? riskScore;
  final bool isEmergency;
  final String? emergencyType;
  final String? possibleEmergency;
  final bool sosRequired;
  final int sosCount;
  final DateTime createdAt;

  const UserEmergency({
    required this.id,
    this.age,
    this.gender,
    required this.symptoms,
    required this.riskLevel,
    this.riskScore,
    required this.isEmergency,
    this.emergencyType,
    this.possibleEmergency,
    required this.sosRequired,
    required this.sosCount,
    required this.createdAt,
  });

  factory UserEmergency.fromJson(Map<String, dynamic> j) => UserEmergency(
        id: j['id'].toString(),
        age: j['age'] as int?,
        gender: j['gender'] as String?,
        symptoms: (j['symptoms'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        riskLevel: j['risk_level'] as String? ?? 'LOW',
        riskScore: (j['risk_score'] as num?)?.toDouble(),
        isEmergency: j['is_emergency'] as bool? ?? false,
        emergencyType: j['emergency_type'] as String?,
        possibleEmergency: j['possible_emergency'] as String?,
        sosRequired: j['sos_required'] as bool? ?? false,
        sosCount: j['sos_count'] as int? ?? 0,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

class UserSession {
  final String id;
  final String? deviceInfo;
  final String? ipAddress;
  final bool isActive;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final DateTime expiresAt;

  const UserSession({
    required this.id,
    this.deviceInfo,
    this.ipAddress,
    required this.isActive,
    required this.createdAt,
    required this.lastActiveAt,
    required this.expiresAt,
  });

  factory UserSession.fromJson(Map<String, dynamic> j) => UserSession(
        id: j['id'] as String,
        deviceInfo: j['device_info'] as String?,
        ipAddress: j['ip_address'] as String?,
        isActive: j['is_active'] as bool? ?? false,
        createdAt: DateTime.parse(j['created_at'] as String),
        lastActiveAt: DateTime.parse(j['last_active_at'] as String),
        expiresAt: DateTime.parse(j['expires_at'] as String),
      );
}

class UserSymptomCheck {
  final String id;
  final List<String> symptoms;
  final int? age;
  final String? gender;
  final String? predictedDisease;
  final double? confidence;
  final String riskLevel;
  final double? riskScore;
  final bool isEmergency;
  final DateTime createdAt;

  const UserSymptomCheck({
    required this.id,
    required this.symptoms,
    this.age,
    this.gender,
    this.predictedDisease,
    this.confidence,
    required this.riskLevel,
    this.riskScore,
    required this.isEmergency,
    required this.createdAt,
  });

  factory UserSymptomCheck.fromJson(Map<String, dynamic> j) => UserSymptomCheck(
        id: j['id'].toString(),
        symptoms: (j['symptoms'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        age: j['age'] as int?,
        gender: j['gender'] as String?,
        predictedDisease: j['predicted_disease'] as String?,
        confidence: (j['confidence'] as num?)?.toDouble(),
        riskLevel: j['risk_level'] as String? ?? 'LOW',
        riskScore: (j['risk_score'] as num?)?.toDouble(),
        isEmergency: j['is_emergency'] as bool? ?? false,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

// ── State ─────────────────────────────────────────────────────────────────────

class UserDetailState {
  final bool isLoading;
  final String? error;

  // Profile
  final AdminUser? user;

  // Conversations tab
  final bool conversationsLoading;
  final List<UserConversation> conversations;
  final int conversationsTotal;
  final int conversationsPage;

  // Emergencies tab
  final bool emergenciesLoading;
  final List<UserEmergency> emergencies;
  final int emergenciesTotal;
  final int emergenciesPage;

  // Sessions tab
  final bool sessionsLoading;
  final List<UserSession> sessions;
  final int activeSessionCount;

  // Symptom checks tab
  final bool symptomChecksLoading;
  final List<UserSymptomCheck> symptomChecks;
  final int symptomChecksTotal;
  final int symptomChecksPage;

  const UserDetailState({
    this.isLoading = false,
    this.error,
    this.user,
    this.conversationsLoading = false,
    this.conversations = const [],
    this.conversationsTotal = 0,
    this.conversationsPage = 1,
    this.emergenciesLoading = false,
    this.emergencies = const [],
    this.emergenciesTotal = 0,
    this.emergenciesPage = 1,
    this.sessionsLoading = false,
    this.sessions = const [],
    this.activeSessionCount = 0,
    this.symptomChecksLoading = false,
    this.symptomChecks = const [],
    this.symptomChecksTotal = 0,
    this.symptomChecksPage = 1,
  });

  UserDetailState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    AdminUser? user,
    bool? conversationsLoading,
    List<UserConversation>? conversations,
    int? conversationsTotal,
    int? conversationsPage,
    bool? emergenciesLoading,
    List<UserEmergency>? emergencies,
    int? emergenciesTotal,
    int? emergenciesPage,
    bool? sessionsLoading,
    List<UserSession>? sessions,
    int? activeSessionCount,
    bool? symptomChecksLoading,
    List<UserSymptomCheck>? symptomChecks,
    int? symptomChecksTotal,
    int? symptomChecksPage,
  }) =>
      UserDetailState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        user: user ?? this.user,
        conversationsLoading: conversationsLoading ?? this.conversationsLoading,
        conversations: conversations ?? this.conversations,
        conversationsTotal: conversationsTotal ?? this.conversationsTotal,
        conversationsPage: conversationsPage ?? this.conversationsPage,
        emergenciesLoading: emergenciesLoading ?? this.emergenciesLoading,
        emergencies: emergencies ?? this.emergencies,
        emergenciesTotal: emergenciesTotal ?? this.emergenciesTotal,
        emergenciesPage: emergenciesPage ?? this.emergenciesPage,
        sessionsLoading: sessionsLoading ?? this.sessionsLoading,
        sessions: sessions ?? this.sessions,
        activeSessionCount: activeSessionCount ?? this.activeSessionCount,
        symptomChecksLoading: symptomChecksLoading ?? this.symptomChecksLoading,
        symptomChecks: symptomChecks ?? this.symptomChecks,
        symptomChecksTotal: symptomChecksTotal ?? this.symptomChecksTotal,
        symptomChecksPage: symptomChecksPage ?? this.symptomChecksPage,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class UserDetailNotifier extends StateNotifier<UserDetailState> {
  final String userId;
  UserDetailNotifier(this.userId) : super(const UserDetailState()) {
    loadProfile();
  }

  // ── Profile ────────────────────────────────────────────────────────────────

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final resp = await ApiClient.instance.get('/admin/users/$userId');
      final data = resp.data as Map<String, dynamic>;
      state = state.copyWith(
        isLoading: false,
        user: AdminUser.fromJson(data),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  // ── Conversations ──────────────────────────────────────────────────────────

  Future<void> loadConversations({int page = 1}) async {
    state = state.copyWith(conversationsLoading: true, conversationsPage: page);
    try {
      final resp = await ApiClient.instance.get(
        '/admin/users/$userId/conversations',
        queryParameters: {'page': page, 'page_size': 15},
      );
      final data = resp.data as Map<String, dynamic>;
      state = state.copyWith(
        conversationsLoading: false,
        conversations: (data['conversations'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(UserConversation.fromJson)
            .toList(),
        conversationsTotal: data['total'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(
          conversationsLoading: false, error: errorMessage(e));
    }
  }

  // ── Emergencies ────────────────────────────────────────────────────────────

  Future<void> loadEmergencies({int page = 1}) async {
    state = state.copyWith(emergenciesLoading: true, emergenciesPage: page);
    try {
      final resp = await ApiClient.instance.get(
        '/admin/users/$userId/emergencies',
        queryParameters: {'page': page, 'page_size': 15},
      );
      final data = resp.data as Map<String, dynamic>;
      state = state.copyWith(
        emergenciesLoading: false,
        emergencies: (data['emergencies'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(UserEmergency.fromJson)
            .toList(),
        emergenciesTotal: data['total'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(emergenciesLoading: false, error: errorMessage(e));
    }
  }

  // ── Sessions ───────────────────────────────────────────────────────────────

  Future<void> loadSessions() async {
    state = state.copyWith(sessionsLoading: true);
    try {
      final resp =
          await ApiClient.instance.get('/admin/users/$userId/sessions');
      final data = resp.data as Map<String, dynamic>;
      state = state.copyWith(
        sessionsLoading: false,
        sessions: (data['sessions'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(UserSession.fromJson)
            .toList(),
        activeSessionCount: data['total_active'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(sessionsLoading: false, error: errorMessage(e));
    }
  }

  Future<String?> revokeSessions() async {
    try {
      final resp = await ApiClient.instance
          .post('/admin/users/$userId/revoke-sessions');
      final msg =
          (resp.data as Map<String, dynamic>)['message'] as String? ??
              'Sessions revoked';
      await loadSessions();
      return msg;
    } catch (e) {
      return null;
    }
  }

  // ── Symptom Checks ─────────────────────────────────────────────────────────

  Future<void> loadSymptomChecks({int page = 1}) async {
    state = state.copyWith(symptomChecksLoading: true, symptomChecksPage: page);
    try {
      final resp = await ApiClient.instance.get(
        '/admin/users/$userId/symptom-checks',
        queryParameters: {'page': page, 'page_size': 15},
      );
      final data = resp.data as Map<String, dynamic>;
      state = state.copyWith(
        symptomChecksLoading: false,
        symptomChecks: (data['symptom_checks'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(UserSymptomCheck.fromJson)
            .toList(),
        symptomChecksTotal: data['total'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(
          symptomChecksLoading: false, error: errorMessage(e));
    }
  }

  // ── Mutations ──────────────────────────────────────────────────────────────

  /// Returns null on success, error string on failure.
  Future<String?> updateStatus(bool isActive) async {
    try {
      await ApiClient.instance.patch(
        '/admin/users/$userId/status',
        data: {'is_active': isActive},
      );
      await loadProfile();
      return null;
    } catch (e) {
      return errorMessage(e);
    }
  }

  Future<String?> updateRole(String role) async {
    try {
      await ApiClient.instance.patch(
        '/admin/users/$userId/role',
        data: {'role': role},
      );
      await loadProfile();
      return null;
    } catch (e) {
      return errorMessage(e);
    }
  }

  Future<String?> resetPassword(String newPassword) async {
    try {
      await ApiClient.instance.post(
        '/admin/users/$userId/reset-password',
        data: {'new_password': newPassword},
      );
      return null;
    } catch (e) {
      return errorMessage(e);
    }
  }

  Future<String?> updateProfile({
    String? fullName,
    String? phone,
    String? language,
    bool? emailVerified,
    bool? phoneVerified,
  }) async {
    try {
      await ApiClient.instance.patch(
        '/admin/users/$userId/profile',
        data: {
          if (fullName != null) 'full_name': fullName,
          if (phone != null) 'phone': phone,
          if (language != null) 'language': language,
          if (emailVerified != null) 'email_verified': emailVerified,
          if (phoneVerified != null) 'phone_verified': phoneVerified,
        },
      );
      await loadProfile();
      return null;
    } catch (e) {
      return errorMessage(e);
    }
  }
}

// ── Provider family ────────────────────────────────────────────────────────────

final userDetailProvider = StateNotifierProvider.family<UserDetailNotifier,
    UserDetailState, String>(
  (ref, userId) => UserDetailNotifier(userId),
);
