import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class AdminUserProfile {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String? dateOfBirth;
  final String? gender;
  final String? bloodGroup;
  final double? heightCm;
  final double? weightKg;
  final String? occupation;
  final String? maritalStatus;
  final String? bio;
  final String? profileImage;
  final String createdAt;
  final String updatedAt;

  const AdminUserProfile({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.heightCm,
    this.weightKg,
    this.occupation,
    this.maritalStatus,
    this.bio,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminUserProfile.fromJson(Map<String, dynamic> j) => AdminUserProfile(
        id: j['id'] as String? ?? '',
        userId: j['user_id'] as String? ?? '',
        userName: j['user_name'] as String? ?? j['full_name'] as String?,
        userEmail: j['user_email'] as String? ?? j['email'] as String?,
        dateOfBirth: j['date_of_birth'] as String?,
        gender: j['gender'] as String?,
        bloodGroup: j['blood_group'] as String?,
        heightCm: (j['height_cm'] as num?)?.toDouble(),
        weightKg: (j['weight_kg'] as num?)?.toDouble(),
        occupation: j['occupation'] as String?,
        maritalStatus: j['marital_status'] as String?,
        bio: j['bio'] as String?,
        profileImage: j['profile_image'] as String?,
        createdAt: j['created_at'] as String? ?? '',
        updatedAt: j['updated_at'] as String? ?? '',
      );
}

class AdminAddress {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String addressType;
  final String? label;
  final String? country;
  final String? state;
  final String? district;
  final String? municipality;
  final String? street;
  final String? postalCode;
  final bool isPrimary;
  final String createdAt;

  const AdminAddress({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.addressType,
    this.label,
    this.country,
    this.state,
    this.district,
    this.municipality,
    this.street,
    this.postalCode,
    this.isPrimary = false,
    required this.createdAt,
  });

  factory AdminAddress.fromJson(Map<String, dynamic> j) => AdminAddress(
        id: j['id'] as String? ?? '',
        userId: j['user_id'] as String? ?? '',
        userName: j['user_name'] as String?,
        userEmail: j['user_email'] as String?,
        addressType: j['address_type'] as String? ?? 'home',
        label: j['label'] as String?,
        country: j['country'] as String?,
        state: j['state'] as String?,
        district: j['district'] as String?,
        municipality: j['municipality'] as String?,
        street: j['street'] as String?,
        postalCode: j['postal_code'] as String?,
        isPrimary: j['is_primary'] as bool? ?? false,
        createdAt: j['created_at'] as String? ?? '',
      );
}

class AdminEmergencyContact {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String contactName;
  final String contactRelationship;
  final String phone;
  final String? email;
  final int priority;
  final String createdAt;

  const AdminEmergencyContact({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.contactName,
    required this.contactRelationship,
    required this.phone,
    this.email,
    this.priority = 1,
    required this.createdAt,
  });

  factory AdminEmergencyContact.fromJson(Map<String, dynamic> j) =>
      AdminEmergencyContact(
        id: j['id'] as String? ?? '',
        userId: j['user_id'] as String? ?? '',
        userName: j['user_name'] as String?,
        userEmail: j['user_email'] as String?,
        contactName: j['contact_name'] as String? ?? '',
        contactRelationship: j['contact_relationship'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        email: j['email'] as String?,
        priority: j['priority'] as int? ?? 1,
        createdAt: j['created_at'] as String? ?? '',
      );
}

class AdminMedicalInfo {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String? bloodGroup;
  final List<dynamic> allergies;
  final List<dynamic> chronicDiseases;
  final List<dynamic> currentMedications;
  final bool smokingStatus;
  final bool alcoholConsumption;
  final String? notes;

  const AdminMedicalInfo({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    this.bloodGroup,
    this.allergies = const [],
    this.chronicDiseases = const [],
    this.currentMedications = const [],
    this.smokingStatus = false,
    this.alcoholConsumption = false,
    this.notes,
  });

  factory AdminMedicalInfo.fromJson(Map<String, dynamic> j) => AdminMedicalInfo(
        id: j['id'] as String? ?? '',
        userId: j['user_id'] as String? ?? '',
        userName: j['user_name'] as String?,
        userEmail: j['user_email'] as String?,
        bloodGroup: j['blood_group'] as String?,
        allergies: (j['allergies'] as List?) ?? [],
        chronicDiseases: (j['chronic_diseases'] as List?) ?? [],
        currentMedications: (j['current_medications'] as List?) ?? [],
        smokingStatus: j['smoking_status'] as bool? ?? false,
        alcoholConsumption: j['alcohol_consumption'] as bool? ?? false,
        notes: j['notes'] as String?,
      );
}

// ── State ─────────────────────────────────────────────────────────────────────

class ProfileState {
  final bool isLoading;
  final String? error;

  final List<AdminUserProfile> profiles;
  final int profilesTotal;
  final int profilesPage;
  final String profileSearch;

  final List<AdminAddress> addresses;
  final int addressesTotal;
  final int addressesPage;
  final String? addressCountryFilter;

  final List<AdminEmergencyContact> emergencyContacts;
  final int emergencyContactsTotal;
  final int emergencyContactsPage;

  final List<AdminMedicalInfo> medicalInfos;
  final int medicalInfosTotal;
  final int medicalInfosPage;

  final int pageSize;

  const ProfileState({
    this.isLoading = false,
    this.error,
    this.profiles = const [],
    this.profilesTotal = 0,
    this.profilesPage = 1,
    this.profileSearch = '',
    this.addresses = const [],
    this.addressesTotal = 0,
    this.addressesPage = 1,
    this.addressCountryFilter,
    this.emergencyContacts = const [],
    this.emergencyContactsTotal = 0,
    this.emergencyContactsPage = 1,
    this.medicalInfos = const [],
    this.medicalInfosTotal = 0,
    this.medicalInfosPage = 1,
    this.pageSize = 20,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<AdminUserProfile>? profiles,
    int? profilesTotal,
    int? profilesPage,
    String? profileSearch,
    List<AdminAddress>? addresses,
    int? addressesTotal,
    int? addressesPage,
    String? addressCountryFilter,
    bool clearCountry = false,
    List<AdminEmergencyContact>? emergencyContacts,
    int? emergencyContactsTotal,
    int? emergencyContactsPage,
    List<AdminMedicalInfo>? medicalInfos,
    int? medicalInfosTotal,
    int? medicalInfosPage,
  }) =>
      ProfileState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        profiles: profiles ?? this.profiles,
        profilesTotal: profilesTotal ?? this.profilesTotal,
        profilesPage: profilesPage ?? this.profilesPage,
        profileSearch: profileSearch ?? this.profileSearch,
        addresses: addresses ?? this.addresses,
        addressesTotal: addressesTotal ?? this.addressesTotal,
        addressesPage: addressesPage ?? this.addressesPage,
        addressCountryFilter: clearCountry ? null : (addressCountryFilter ?? this.addressCountryFilter),
        emergencyContacts: emergencyContacts ?? this.emergencyContacts,
        emergencyContactsTotal: emergencyContactsTotal ?? this.emergencyContactsTotal,
        emergencyContactsPage: emergencyContactsPage ?? this.emergencyContactsPage,
        medicalInfos: medicalInfos ?? this.medicalInfos,
        medicalInfosTotal: medicalInfosTotal ?? this.medicalInfosTotal,
        medicalInfosPage: medicalInfosPage ?? this.medicalInfosPage,
        pageSize: pageSize,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState()) {
    loadProfiles();
    loadAddresses();
    loadEmergencyContacts();
    loadMedicalInfos();
  }

  Future<void> loadProfiles({int? page}) async {
    final p = page ?? state.profilesPage;
    state = state.copyWith(isLoading: true, clearError: true, profilesPage: p);
    try {
      final params = <String, dynamic>{'page': p, 'page_size': state.pageSize};
      if (state.profileSearch.isNotEmpty) params['search'] = state.profileSearch;
      final resp = await ApiClient.instance.get('/admin/profiles/list',
          queryParameters: params);
      final d = resp.data as Map<String, dynamic>;
      state = state.copyWith(
        isLoading: false,
        profiles: (d['profiles'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(AdminUserProfile.fromJson)
            .toList(),
        profilesTotal: d['total'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  Future<void> loadAddresses({int? page}) async {
    final p = page ?? state.addressesPage;
    state = state.copyWith(isLoading: true, clearError: true, addressesPage: p);
    try {
      final params = <String, dynamic>{'page': p, 'page_size': state.pageSize};
      if (state.addressCountryFilter != null) params['country'] = state.addressCountryFilter;
      final resp = await ApiClient.instance.get('/admin/profiles/addresses',
          queryParameters: params);
      final d = resp.data as Map<String, dynamic>;
      state = state.copyWith(
        isLoading: false,
        addresses: (d['addresses'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(AdminAddress.fromJson)
            .toList(),
        addressesTotal: d['total'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  Future<void> loadEmergencyContacts({int? page}) async {
    final p = page ?? state.emergencyContactsPage;
    state = state.copyWith(isLoading: true, clearError: true, emergencyContactsPage: p);
    try {
      final resp = await ApiClient.instance.get('/admin/profiles/emergency-contacts',
          queryParameters: {'page': p, 'page_size': state.pageSize});
      final d = resp.data as Map<String, dynamic>;
      state = state.copyWith(
        isLoading: false,
        emergencyContacts: (d['contacts'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(AdminEmergencyContact.fromJson)
            .toList(),
        emergencyContactsTotal: d['total'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  Future<void> loadMedicalInfos({int? page}) async {
    final p = page ?? state.medicalInfosPage;
    state = state.copyWith(isLoading: true, clearError: true, medicalInfosPage: p);
    try {
      final resp = await ApiClient.instance.get('/admin/profiles/medical-info',
          queryParameters: {'page': p, 'page_size': state.pageSize});
      final d = resp.data as Map<String, dynamic>;
      state = state.copyWith(
        isLoading: false,
        medicalInfos: (d['medical_infos'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(AdminMedicalInfo.fromJson)
            .toList(),
        medicalInfosTotal: d['total'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  void setProfileSearch(String v) {
    state = state.copyWith(profileSearch: v, profilesPage: 1);
    loadProfiles();
  }

  void setAddressCountryFilter(String? v) {
    state = v == null
        ? state.copyWith(clearCountry: true, addressesPage: 1)
        : state.copyWith(addressCountryFilter: v, addressesPage: 1);
    loadAddresses();
  }

  /// Update a user profile via PATCH /admin/profiles/{profileId}.
  Future<bool> updateProfile(
    String profileId, {
    String? gender,
    String? maritalStatus,
    String? occupation,
    String? bio,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (gender != null) body['gender'] = gender;
      if (maritalStatus != null) body['marital_status'] = maritalStatus;
      if (occupation != null) body['occupation'] = occupation;
      if (bio != null) body['bio'] = bio;

      await ApiClient.instance.patch('/admin/profiles/$profileId', data: body);
      await loadProfiles(page: state.profilesPage);
      return true;
    } catch (e) {
      state = state.copyWith(error: errorMessage(e));
      return false;
    }
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>(
        (ref) => ProfileNotifier());
