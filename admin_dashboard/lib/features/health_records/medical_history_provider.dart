import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api.dart';

class MedicalHistoryEntry {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String diseaseName;
  final String category;
  final String status;
  final String? diagnosisDate;
  final String? doctorName;
  final String? hospitalName;
  final String? notes;
  final String createdAt;

  const MedicalHistoryEntry({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.diseaseName,
    required this.category,
    required this.status,
    this.diagnosisDate,
    this.doctorName,
    this.hospitalName,
    this.notes,
    required this.createdAt,
  });

  factory MedicalHistoryEntry.fromJson(Map<String, dynamic> j) =>
      MedicalHistoryEntry(
        id: j['id'] as String? ?? '',
        userId: j['user_id'] as String? ?? '',
        userName: j['user_name'] as String?,
        userEmail: j['user_email'] as String?,
        diseaseName: j['disease_name'] as String? ?? '',
        category: j['category'] as String? ?? 'current',
        status: j['status'] as String? ?? 'active',
        diagnosisDate: j['diagnosis_date'] as String?,
        doctorName: j['doctor_name'] as String?,
        hospitalName: j['hospital_name'] as String?,
        notes: j['notes'] as String?,
        createdAt: j['created_at'] as String? ?? '',
      );
}

class MedicalHistoryStats {
  final int total;
  final int current;
  final int past;
  final int surgery;
  final int chronic;
  final int family;
  final int active;
  final int resolved;
  final int managed;

  const MedicalHistoryStats({
    this.total = 0, this.current = 0, this.past = 0,
    this.surgery = 0, this.chronic = 0, this.family = 0,
    this.active = 0, this.resolved = 0, this.managed = 0,
  });

  factory MedicalHistoryStats.fromJson(Map<String, dynamic> j) =>
      MedicalHistoryStats(
        total: j['total'] as int? ?? 0,
        current: j['current'] as int? ?? 0,
        past: j['past'] as int? ?? 0,
        surgery: j['surgery'] as int? ?? 0,
        chronic: j['chronic'] as int? ?? 0,
        family: j['family'] as int? ?? 0,
        active: j['active'] as int? ?? 0,
        resolved: j['resolved'] as int? ?? 0,
        managed: j['managed'] as int? ?? 0,
      );
}

class MedicalHistoryState {
  final bool isLoading;
  final String? error;
  final List<MedicalHistoryEntry> entries;
  final int total;
  final int page;
  final int pageSize;
  final String search;
  final String? categoryFilter;
  final String? statusFilter;
  final MedicalHistoryStats stats;

  const MedicalHistoryState({
    this.isLoading = false,
    this.error,
    this.entries = const [],
    this.total = 0,
    this.page = 1,
    this.pageSize = 20,
    this.search = '',
    this.categoryFilter,
    this.statusFilter,
    this.stats = const MedicalHistoryStats(),
  });

  MedicalHistoryState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<MedicalHistoryEntry>? entries,
    int? total,
    int? page,
    String? search,
    String? categoryFilter,
    bool clearCategory = false,
    String? statusFilter,
    bool clearStatus = false,
    MedicalHistoryStats? stats,
  }) =>
      MedicalHistoryState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        entries: entries ?? this.entries,
        total: total ?? this.total,
        page: page ?? this.page,
        pageSize: pageSize,
        search: search ?? this.search,
        categoryFilter: clearCategory ? null : (categoryFilter ?? this.categoryFilter),
        statusFilter: clearStatus ? null : (statusFilter ?? this.statusFilter),
        stats: stats ?? this.stats,
      );
}

class MedicalHistoryNotifier extends StateNotifier<MedicalHistoryState> {
  MedicalHistoryNotifier() : super(const MedicalHistoryState()) {
    load();
  }

  Future<void> load({int? page}) async {
    final p = page ?? state.page;
    state = state.copyWith(isLoading: true, clearError: true, page: p);
    try {
      final params = <String, dynamic>{'page': p, 'page_size': state.pageSize};
      if (state.search.isNotEmpty) params['search'] = state.search;
      if (state.categoryFilter != null) params['category'] = state.categoryFilter;
      if (state.statusFilter != null) params['status'] = state.statusFilter;

      final results = await Future.wait([
        ApiClient.instance.get('/admin/health-records/medical-history',
            queryParameters: params),
        ApiClient.instance.get('/admin/health-records/medical-history/stats'),
      ]);

      final d = results[0].data as Map<String, dynamic>;
      MedicalHistoryStats stats;
      try {
        stats = MedicalHistoryStats.fromJson(
            results[1].data as Map<String, dynamic>);
      } catch (_) {
        stats = const MedicalHistoryStats();
      }

      state = state.copyWith(
        isLoading: false,
        entries: (d['entries'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(MedicalHistoryEntry.fromJson)
            .toList(),
        total: d['total'] as int? ?? 0,
        stats: stats,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  void setSearch(String v) {
    state = state.copyWith(search: v, page: 1);
    load();
  }

  void setCategoryFilter(String? v) {
    state = v == null
        ? state.copyWith(clearCategory: true, page: 1)
        : state.copyWith(categoryFilter: v, page: 1);
    load();
  }

  void setStatusFilter(String? v) {
    state = v == null
        ? state.copyWith(clearStatus: true, page: 1)
        : state.copyWith(statusFilter: v, page: 1);
    load();
  }

  void goToPage(int p) => load(page: p);
}

final medicalHistoryProvider =
    StateNotifierProvider<MedicalHistoryNotifier, MedicalHistoryState>(
        (ref) => MedicalHistoryNotifier());
