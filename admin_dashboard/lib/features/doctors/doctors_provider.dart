import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class DoctorItem {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final bool isActive;
  final bool emailVerified;
  final bool phoneVerified;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const DoctorItem({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.isActive,
    required this.emailVerified,
    required this.phoneVerified,
    this.profileImage,
    required this.createdAt,
    this.lastLogin,
  });

  factory DoctorItem.fromJson(Map<String, dynamic> j) => DoctorItem(
        id: j['id'] as String,
        fullName: j['full_name'] as String,
        email: j['email'] as String,
        phone: j['phone'] as String?,
        isActive: j['is_active'] as bool? ?? true,
        emailVerified: j['email_verified'] as bool? ?? false,
        phoneVerified: j['phone_verified'] as bool? ?? false,
        profileImage: j['profile_image'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
        lastLogin: j['last_login'] != null
            ? DateTime.parse(j['last_login'] as String)
            : null,
      );
}

// ── State ─────────────────────────────────────────────────────────────────────

class DoctorsState {
  final bool isLoading;
  final String? error;
  final List<DoctorItem> doctors;
  final int total;
  final int page;
  final int pageSize;
  final String search;
  final bool? activeFilter;

  const DoctorsState({
    this.isLoading = false,
    this.error,
    this.doctors = const [],
    this.total = 0,
    this.page = 1,
    this.pageSize = 20,
    this.search = '',
    this.activeFilter,
  });

  int get totalPages => (total / pageSize).ceil().clamp(1, 9999);

  DoctorsState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<DoctorItem>? doctors,
    int? total,
    int? page,
    String? search,
    bool? activeFilter,
    bool clearActive = false,
  }) =>
      DoctorsState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        doctors: doctors ?? this.doctors,
        total: total ?? this.total,
        page: page ?? this.page,
        pageSize: pageSize,
        search: search ?? this.search,
        activeFilter: clearActive ? null : (activeFilter ?? this.activeFilter),
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class DoctorsNotifier extends StateNotifier<DoctorsState> {
  DoctorsNotifier() : super(const DoctorsState()) {
    load();
  }

  Future<void> load({int? page}) async {
    state = state.copyWith(
        isLoading: true, clearError: true, page: page ?? state.page);
    try {
      final params = <String, dynamic>{
        'page': state.page,
        'page_size': state.pageSize,
      };
      if (state.search.isNotEmpty) params['search'] = state.search;
      if (state.activeFilter != null) params['is_active'] = state.activeFilter;

      final resp = await ApiClient.instance
          .get('/admin/doctors', queryParameters: params);
      final data = resp.data as Map<String, dynamic>;

      state = state.copyWith(
        isLoading: false,
        clearError: true,
        doctors: (data['doctors'] as List)
            .cast<Map<String, dynamic>>()
            .map(DoctorItem.fromJson)
            .toList(),
        total: data['total'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  void setSearch(String v) {
    state = state.copyWith(search: v, page: 1);
    load();
  }

  void setActiveFilter(bool? v) {
    state = v == null
        ? state.copyWith(clearActive: true, page: 1)
        : state.copyWith(activeFilter: v, page: 1);
    load();
  }

  void goToPage(int p) => load(page: p);

  Future<void> updateStatus(String doctorId, bool isActive) async {
    try {
      await ApiClient.instance.patch(
        '/admin/doctors/$doctorId/status',
        data: {'is_active': isActive},
      );
      load();
    } catch (e) {
      state = state.copyWith(error: errorMessage(e));
    }
  }

  Future<bool> createDoctor({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      await ApiClient.instance.post('/admin/doctors', data: {
        'full_name': fullName,
        'email': email,
        'password': password,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      });
      load();
      return true;
    } catch (e) {
      state = state.copyWith(error: errorMessage(e));
      return false;
    }
  }
}

final doctorsProvider =
    StateNotifierProvider<DoctorsNotifier, DoctorsState>(
        (ref) => DoctorsNotifier());
