import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../config/api_config.dart';
import '../../../authentication/presentation/providers/authentication_provider.dart';

// ── Data models ───────────────────────────────────────────────────────────────

class UserFullProfile {
  final String userId;
  final String fullName;
  final String email;
  final String? phone;
  final String? role;
  final String? preferredLanguage;

  // Profile sub-record
  final String? dateOfBirth;
  final String? gender;
  final String? bloodGroup;
  final double? heightCm;
  final double? weightKg;
  final String? occupation;
  final String? maritalStatus;
  final String? bio;

  // Medical info
  final List<String> allergies;
  final List<String> chronicDiseases;
  final List<String> currentMedications;
  final bool smokingStatus;
  final bool alcoholConsumption;
  final String? medicalNotes;

  const UserFullProfile({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phone,
    this.role,
    this.preferredLanguage,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.heightCm,
    this.weightKg,
    this.occupation,
    this.maritalStatus,
    this.bio,
    this.allergies = const [],
    this.chronicDiseases = const [],
    this.currentMedications = const [],
    this.smokingStatus = false,
    this.alcoholConsumption = false,
    this.medicalNotes,
  });

  UserFullProfile copyWith({
    String? fullName,
    String? phone,
    String? preferredLanguage,
    String? dateOfBirth,
    String? gender,
    String? bloodGroup,
    double? heightCm,
    double? weightKg,
    String? occupation,
    String? maritalStatus,
    String? bio,
    List<String>? allergies,
    List<String>? chronicDiseases,
    List<String>? currentMedications,
    bool? smokingStatus,
    bool? alcoholConsumption,
    String? medicalNotes,
  }) {
    return UserFullProfile(
      userId: userId,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone ?? this.phone,
      role: role,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      occupation: occupation ?? this.occupation,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      bio: bio ?? this.bio,
      allergies: allergies ?? this.allergies,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      currentMedications: currentMedications ?? this.currentMedications,
      smokingStatus: smokingStatus ?? this.smokingStatus,
      alcoholConsumption: alcoholConsumption ?? this.alcoholConsumption,
      medicalNotes: medicalNotes ?? this.medicalNotes,
    );
  }
}

// ── Provider state ────────────────────────────────────────────────────────────

class UserProfileState {
  final bool isLoading;
  final bool isSaving;
  final UserFullProfile? profile;
  final String? error;
  final String? saveSuccess;

  const UserProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.profile,
    this.error,
    this.saveSuccess,
  });

  UserProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    UserFullProfile? profile,
    String? error,
    String? saveSuccess,
  }) {
    return UserProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      profile: profile ?? this.profile,
      error: error,
      saveSuccess: saveSuccess,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final Ref _ref;

  UserProfileNotifier(this._ref) : super(const UserProfileState());

  /// Gets the stored access token from the auth repository singleton.
  String? get _token {
    final repo = _ref.read(authRepositoryProvider);
    return repo.accessToken;
  }

  Map<String, String> get _headers {
    final token = _token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Load the full profile from the backend. Call this when the profile page opens.
  Future<void> loadProfile() async {
    // ── Guest user: show meaningful static profile without API calls ──────────
    final repo = _ref.read(authRepositoryProvider);
    final currentUser = await repo.getCurrentUser();
    if (currentUser.isGuest) {
      state = state.copyWith(
        isLoading: false,
        profile: const UserFullProfile(
          userId: 'guest',
          fullName: 'Guest User',
          email: 'guest@health.ai',
          phone: null,
          role: 'guest',
          preferredLanguage: 'English',
          gender: 'prefer not to say',
          bloodGroup: null,
          heightCm: null,
          weightKg: null,
          occupation: 'Not specified',
          maritalStatus: null,
          bio: 'Browsing as a guest. Sign up to save your health data and access full features.',
          allergies: [],
          chronicDiseases: [],
          currentMedications: [],
          smokingStatus: false,
          alcoholConsumption: false,
          medicalNotes: 'Create an account to track your medical history.',
        ),
      );
      return;
    }

    // ── Authenticated user: fetch from backend ─────────────────────────────────
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Parallel: fetch account summary + profile details + medical info
      final results = await Future.wait([
        http.get(
          Uri.parse('${ApiConfig.baseUrl}/api/v1/users/me'),
          headers: _headers,
        ),
        http.get(
          Uri.parse('${ApiConfig.baseUrl}/api/v1/users/profile'),
          headers: _headers,
        ),
        http.get(
          Uri.parse('${ApiConfig.baseUrl}/api/v1/users/medical-info'),
          headers: _headers,
        ),
      ]);

      final meResp      = results[0];
      final profResp    = results[1];
      final medResp     = results[2];

      if (meResp.statusCode != 200) {
        throw Exception('Failed to load account data (${meResp.statusCode})');
      }

      final me   = jsonDecode(meResp.body) as Map<String, dynamic>;
      final prof = profResp.statusCode == 200
          ? jsonDecode(profResp.body) as Map<String, dynamic>
          : null;
      final med  = medResp.statusCode == 200
          ? jsonDecode(medResp.body) as Map<String, dynamic>
          : null;

      state = state.copyWith(
        isLoading: false,
        profile: UserFullProfile(
          userId: me['user_id']?.toString() ?? '',
          fullName: me['full_name']?.toString() ?? '',
          email: me['email']?.toString() ?? '',
          phone: me['phone']?.toString(),
          role: me['role']?.toString(),
          preferredLanguage: me['preferred_language']?.toString(),
          // Profile sub-record
          dateOfBirth: prof?['date_of_birth']?.toString(),
          gender: prof?['gender']?.toString(),
          bloodGroup: prof?['blood_group']?.toString(),
          heightCm: (prof?['height_cm'] as num?)?.toDouble(),
          weightKg: (prof?['weight_kg'] as num?)?.toDouble(),
          occupation: prof?['occupation']?.toString(),
          maritalStatus: prof?['marital_status']?.toString(),
          bio: prof?['bio']?.toString(),
          // Medical info
          allergies: _toStringList(med?['allergies']),
          chronicDiseases: _toStringList(med?['chronic_diseases']),
          currentMedications: _toStringList(med?['current_medications']),
          smokingStatus: med?['smoking_status'] as bool? ?? false,
          alcoholConsumption: med?['alcohol_consumption'] as bool? ?? false,
          medicalNotes: med?['notes']?.toString(),
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load profile. Check your connection.',
      );
    }
  }

  /// Save all editable fields back to the backend.
  Future<bool> saveProfile({
    required String fullName,
    String? phone,
    String? gender,
    String? bloodGroup,
    double? heightCm,
    double? weightKg,
    String? occupation,
    String? maritalStatus,
    String? bio,
    String? preferredLanguage,
    List<String>? allergies,
    List<String>? chronicDiseases,
    List<String>? currentMedications,
    bool? smokingStatus,
    bool? alcoholConsumption,
    String? medicalNotes,
  }) async {
    state = state.copyWith(isSaving: true, error: null, saveSuccess: null);
    try {
      // 1. Update account (name, phone, language)
      final accountPayload = <String, dynamic>{
        'full_name': fullName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (preferredLanguage != null && preferredLanguage.isNotEmpty)
          'preferred_language': _languageToCode(preferredLanguage),
      };
      final accountResp = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/users/me'),
        headers: _headers,
        body: jsonEncode(accountPayload),
      );
      if (accountResp.statusCode != 200) {
        final err = _extractError(accountResp);
        throw Exception(err ?? 'Failed to update account');
      }

      // 2. Create or update profile sub-record
      final profilePayload = <String, dynamic>{
        if (gender != null) 'gender': gender.toLowerCase(),
        if (bloodGroup != null) 'blood_group': bloodGroup,
        if (heightCm != null) 'height_cm': heightCm,
        if (weightKg != null) 'weight_kg': weightKg,
        if (occupation != null) 'occupation': occupation,
        if (maritalStatus != null) 'marital_status': maritalStatus.toLowerCase(),
        if (bio != null) 'bio': bio,
      };
      if (profilePayload.isNotEmpty) {
        // Try POST first, fall back to PUT if already exists (409)
        final createResp = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/v1/users/profile'),
          headers: _headers,
          body: jsonEncode(profilePayload),
        );
        if (createResp.statusCode != 201) {
          final updateResp = await http.put(
            Uri.parse('${ApiConfig.baseUrl}/api/v1/users/profile'),
            headers: _headers,
            body: jsonEncode(profilePayload),
          );
          if (updateResp.statusCode != 200) {
            final err = _extractError(updateResp);
            throw Exception(err ?? 'Failed to update profile');
          }
        }
      }

      // 3. Create or update medical info
      final medPayload = <String, dynamic>{
        if (bloodGroup != null) 'blood_group': bloodGroup,
        'allergies': allergies ?? [],
        'chronic_diseases': chronicDiseases ?? [],
        'current_medications': currentMedications ?? [],
        'smoking_status': smokingStatus ?? false,
        'alcohol_consumption': alcoholConsumption ?? false,
        if (medicalNotes != null && medicalNotes.isNotEmpty) 'notes': medicalNotes,
      };
      final medCreate = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/users/medical-info'),
        headers: _headers,
        body: jsonEncode(medPayload),
      );
      if (medCreate.statusCode != 201) {
        final medUpdate = await http.put(
          Uri.parse('${ApiConfig.baseUrl}/api/v1/users/medical-info'),
          headers: _headers,
          body: jsonEncode(medPayload),
        );
        if (medUpdate.statusCode != 200) {
          final err = _extractError(medUpdate);
          throw Exception(err ?? 'Failed to update medical info');
        }
      }

      // Reload with fresh data
      await loadProfile();
      state = state.copyWith(isSaving: false, saveSuccess: 'Profile updated successfully!');
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  String? _extractError(http.Response resp) {
    try {
      final body = jsonDecode(resp.body);
      if (body is Map) {
        final detail = body['detail'];
        if (detail is String) return detail;
        if (detail is List && detail.isNotEmpty) {
          return detail.first['msg']?.toString();
        }
      }
    } catch (_) {}
    return null;
  }

  static List<String> _toStringList(dynamic val) {
    if (val == null) return [];
    if (val is List) return val.map((e) => e.toString()).toList();
    return [];
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

/// Maps a display language name to the locale code the backend expects.
String _languageToCode(String display) {
  const map = {
    'English': 'en', 'Hindi': 'hi', 'Bengali': 'bn', 'Telugu': 'te',
    'Marathi': 'mr', 'Tamil': 'ta', 'Gujarati': 'gu', 'Kannada': 'kn',
    'Punjabi': 'pa', 'Nepali': 'ne', 'Bhojpuri': 'bho', 'Other': 'other',
  };
  return map[display] ?? display.toLowerCase();
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  return UserProfileNotifier(ref);
});
