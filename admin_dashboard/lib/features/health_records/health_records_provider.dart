import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class HealthRecordsStats {
  final int totalMedicalProfiles;
  final int totalMedicalHistoryEntries;
  final int totalPrescriptions;
  final int totalMedicalImages;
  final int totalTimelineEvents;

  const HealthRecordsStats({
    this.totalMedicalProfiles = 0,
    this.totalMedicalHistoryEntries = 0,
    this.totalPrescriptions = 0,
    this.totalMedicalImages = 0,
    this.totalTimelineEvents = 0,
  });

  factory HealthRecordsStats.fromJson(Map<String, dynamic> j) =>
      HealthRecordsStats(
        totalMedicalProfiles: j['total_medical_profiles'] as int? ?? 0,
        totalMedicalHistoryEntries:
            j['total_medical_history_entries'] as int? ?? 0,
        totalPrescriptions: j['total_prescriptions'] as int? ?? 0,
        totalMedicalImages: j['total_medical_images'] as int? ?? 0,
        totalTimelineEvents: j['total_timeline_events'] as int? ?? 0,
      );
}

class AdminMedicalProfile {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String? bloodGroup;
  final double? heightCm;
  final double? weightKg;
  final double? bmi;
  final String? smokingStatus;
  final String? alcoholStatus;
  final String? activityLevel;
  final List<dynamic> allergies;
  final List<dynamic> chronicDiseases;
  final List<dynamic> currentMedications;
  final List<dynamic> familyHistory;
  final String createdAt;
  final String updatedAt;

  const AdminMedicalProfile({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    this.bloodGroup,
    this.heightCm,
    this.weightKg,
    this.bmi,
    this.smokingStatus,
    this.alcoholStatus,
    this.activityLevel,
    this.allergies = const [],
    this.chronicDiseases = const [],
    this.currentMedications = const [],
    this.familyHistory = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminMedicalProfile.fromJson(Map<String, dynamic> j) =>
      AdminMedicalProfile(
        id: j['id'] as String? ?? '',
        userId: j['user_id'] as String? ?? '',
        userName: j['user_name'] as String?,
        userEmail: j['user_email'] as String?,
        bloodGroup: j['blood_group'] as String?,
        heightCm: (j['height_cm'] as num?)?.toDouble(),
        weightKg: (j['weight_kg'] as num?)?.toDouble(),
        bmi: (j['bmi'] as num?)?.toDouble(),
        smokingStatus: j['smoking_status'] as String?,
        alcoholStatus: j['alcohol_status'] as String?,
        activityLevel: j['activity_level'] as String?,
        allergies: (j['allergies'] as List?) ?? [],
        chronicDiseases: (j['chronic_diseases'] as List?) ?? [],
        currentMedications: (j['current_medications'] as List?) ?? [],
        familyHistory: (j['family_history'] as List?) ?? [],
        createdAt: j['created_at'] as String? ?? '',
        updatedAt: j['updated_at'] as String? ?? '',
      );
}

class AdminPrescription {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String? doctorName;
  final String? hospitalName;
  final String? diagnosis;
  final String? prescriptionDate;
  final String? validUntil;
  final List<dynamic> medicines;
  final String? instructions;
  final String? notes;
  final String createdAt;

  const AdminPrescription({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    this.doctorName,
    this.hospitalName,
    this.diagnosis,
    this.prescriptionDate,
    this.validUntil,
    this.medicines = const [],
    this.instructions,
    this.notes,
    required this.createdAt,
  });

  factory AdminPrescription.fromJson(Map<String, dynamic> j) =>
      AdminPrescription(
        id: j['id'] as String? ?? '',
        userId: j['user_id'] as String? ?? '',
        userName: j['user_name'] as String?,
        userEmail: j['user_email'] as String?,
        doctorName: j['doctor_name'] as String?,
        hospitalName: j['hospital_name'] as String?,
        diagnosis: j['diagnosis'] as String?,
        prescriptionDate: j['prescription_date'] as String?,
        validUntil: j['valid_until'] as String?,
        medicines: (j['medicines'] as List?) ?? [],
        instructions: j['instructions'] as String?,
        notes: j['notes'] as String?,
        createdAt: j['created_at'] as String? ?? '',
      );
}

class AdminMedicalImage {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String title;
  final String imageType;
  final String? description;
  final String? bodyPart;
  final String? doctorName;
  final String? hospitalName;
  final String? scanDate;
  final String createdAt;

  const AdminMedicalImage({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.title,
    required this.imageType,
    this.description,
    this.bodyPart,
    this.doctorName,
    this.hospitalName,
    this.scanDate,
    required this.createdAt,
  });

  factory AdminMedicalImage.fromJson(Map<String, dynamic> j) =>
      AdminMedicalImage(
        id: j['id'] as String? ?? '',
        userId: j['user_id'] as String? ?? '',
        userName: j['user_name'] as String?,
        userEmail: j['user_email'] as String?,
        title: j['title'] as String? ?? '',
        imageType: j['image_type'] as String? ?? 'other',
        description: j['description'] as String?,
        bodyPart: j['body_part'] as String?,
        doctorName: j['doctor_name'] as String?,
        hospitalName: j['hospital_name'] as String?,
        scanDate: j['scan_date'] as String?,
        createdAt: j['created_at'] as String? ?? '',
      );
}

class AdminTimelineEvent {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String eventType;
  final String title;
  final String? description;
  final String? iconEmoji;
  final String eventDate;
  final String createdAt;

  const AdminTimelineEvent({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.eventType,
    required this.title,
    this.description,
    this.iconEmoji,
    required this.eventDate,
    required this.createdAt,
  });

  factory AdminTimelineEvent.fromJson(Map<String, dynamic> j) =>
      AdminTimelineEvent(
        id: j['id'] as String? ?? '',
        userId: j['user_id'] as String? ?? '',
        userName: j['user_name'] as String?,
        userEmail: j['user_email'] as String?,
        eventType: j['event_type'] as String? ?? '',
        title: j['title'] as String? ?? '',
        description: j['description'] as String?,
        iconEmoji: j['icon_emoji'] as String?,
        eventDate: j['event_date'] as String? ?? '',
        createdAt: j['created_at'] as String? ?? '',
      );
}

// ── State ─────────────────────────────────────────────────────────────────────

class HealthRecordsState {
  final bool isLoading;
  final String? error;
  final HealthRecordsStats stats;

  final List<AdminMedicalProfile> profiles;
  final int profilesTotal;
  final int profilesPage;
  final String profileSearch;

  final List<AdminPrescription> prescriptions;
  final int prescriptionsTotal;
  final int prescriptionsPage;
  final String prescriptionSearch;

  final List<AdminMedicalImage> images;
  final int imagesTotal;
  final int imagesPage;
  final String? imageTypeFilter;

  final List<AdminTimelineEvent> timeline;
  final int timelineTotal;
  final int timelinePage;

  final int pageSize;

  const HealthRecordsState({
    this.isLoading = false,
    this.error,
    this.stats = const HealthRecordsStats(),
    this.profiles = const [],
    this.profilesTotal = 0,
    this.profilesPage = 1,
    this.profileSearch = '',
    this.prescriptions = const [],
    this.prescriptionsTotal = 0,
    this.prescriptionsPage = 1,
    this.prescriptionSearch = '',
    this.images = const [],
    this.imagesTotal = 0,
    this.imagesPage = 1,
    this.imageTypeFilter,
    this.timeline = const [],
    this.timelineTotal = 0,
    this.timelinePage = 1,
    this.pageSize = 20,
  });

  HealthRecordsState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    HealthRecordsStats? stats,
    List<AdminMedicalProfile>? profiles,
    int? profilesTotal,
    int? profilesPage,
    String? profileSearch,
    List<AdminPrescription>? prescriptions,
    int? prescriptionsTotal,
    int? prescriptionsPage,
    String? prescriptionSearch,
    List<AdminMedicalImage>? images,
    int? imagesTotal,
    int? imagesPage,
    String? imageTypeFilter,
    bool clearImageType = false,
    List<AdminTimelineEvent>? timeline,
    int? timelineTotal,
    int? timelinePage,
  }) =>
      HealthRecordsState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        stats: stats ?? this.stats,
        profiles: profiles ?? this.profiles,
        profilesTotal: profilesTotal ?? this.profilesTotal,
        profilesPage: profilesPage ?? this.profilesPage,
        profileSearch: profileSearch ?? this.profileSearch,
        prescriptions: prescriptions ?? this.prescriptions,
        prescriptionsTotal: prescriptionsTotal ?? this.prescriptionsTotal,
        prescriptionsPage: prescriptionsPage ?? this.prescriptionsPage,
        prescriptionSearch: prescriptionSearch ?? this.prescriptionSearch,
        images: images ?? this.images,
        imagesTotal: imagesTotal ?? this.imagesTotal,
        imagesPage: imagesPage ?? this.imagesPage,
        imageTypeFilter: clearImageType ? null : (imageTypeFilter ?? this.imageTypeFilter),
        timeline: timeline ?? this.timeline,
        timelineTotal: timelineTotal ?? this.timelineTotal,
        timelinePage: timelinePage ?? this.timelinePage,
        pageSize: pageSize,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class HealthRecordsNotifier extends StateNotifier<HealthRecordsState> {
  HealthRecordsNotifier() : super(const HealthRecordsState()) {
    loadStats();
    loadProfiles();
    loadPrescriptions();
    loadImages();
    loadTimeline();
  }

  Future<void> loadStats() async {
    try {
      final resp = await ApiClient.instance.get('/admin/health-records/stats');
      state = state.copyWith(
        stats: HealthRecordsStats.fromJson(resp.data as Map<String, dynamic>),
      );
    } catch (_) {}
  }

  Future<void> loadProfiles({int? page}) async {
    final p = page ?? state.profilesPage;
    state = state.copyWith(isLoading: true, clearError: true, profilesPage: p);
    try {
      final params = <String, dynamic>{'page': p, 'page_size': state.pageSize};
      if (state.profileSearch.isNotEmpty) params['search'] = state.profileSearch;
      final resp = await ApiClient.instance
          .get('/admin/health-records/profiles', queryParameters: params);
      final d = resp.data as Map<String, dynamic>;
      state = state.copyWith(
        isLoading: false,
        profiles: (d['profiles'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(AdminMedicalProfile.fromJson)
            .toList(),
        profilesTotal: d['total'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  Future<void> loadPrescriptions({int? page}) async {
    final p = page ?? state.prescriptionsPage;
    state = state.copyWith(isLoading: true, clearError: true, prescriptionsPage: p);
    try {
      final params = <String, dynamic>{'page': p, 'page_size': state.pageSize};
      if (state.prescriptionSearch.isNotEmpty) params['search'] = state.prescriptionSearch;
      final resp = await ApiClient.instance
          .get('/admin/health-records/prescriptions', queryParameters: params);
      final d = resp.data as Map<String, dynamic>;
      state = state.copyWith(
        isLoading: false,
        prescriptions: (d['prescriptions'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(AdminPrescription.fromJson)
            .toList(),
        prescriptionsTotal: d['total'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  Future<void> loadImages({int? page}) async {
    final p = page ?? state.imagesPage;
    state = state.copyWith(isLoading: true, clearError: true, imagesPage: p);
    try {
      final params = <String, dynamic>{'page': p, 'page_size': state.pageSize};
      if (state.imageTypeFilter != null) params['image_type'] = state.imageTypeFilter;
      final resp = await ApiClient.instance
          .get('/admin/health-records/images', queryParameters: params);
      final d = resp.data as Map<String, dynamic>;
      state = state.copyWith(
        isLoading: false,
        images: (d['images'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(AdminMedicalImage.fromJson)
            .toList(),
        imagesTotal: d['total'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  Future<void> loadTimeline({int? page}) async {
    final p = page ?? state.timelinePage;
    state = state.copyWith(isLoading: true, clearError: true, timelinePage: p);
    try {
      final params = <String, dynamic>{'page': p, 'page_size': state.pageSize};
      final resp = await ApiClient.instance
          .get('/admin/health-records/timeline', queryParameters: params);
      final d = resp.data as Map<String, dynamic>;
      state = state.copyWith(
        isLoading: false,
        timeline: (d['events'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(AdminTimelineEvent.fromJson)
            .toList(),
        timelineTotal: d['total'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  void setProfileSearch(String v) {
    state = state.copyWith(profileSearch: v, profilesPage: 1);
    loadProfiles();
  }

  void setPrescriptionSearch(String v) {
    state = state.copyWith(prescriptionSearch: v, prescriptionsPage: 1);
    loadPrescriptions();
  }

  void setImageTypeFilter(String? v) {
    state = v == null
        ? state.copyWith(clearImageType: true, imagesPage: 1)
        : state.copyWith(imageTypeFilter: v, imagesPage: 1);
    loadImages();
  }
}

final healthRecordsProvider =
    StateNotifierProvider<HealthRecordsNotifier, HealthRecordsState>(
        (ref) => HealthRecordsNotifier());
