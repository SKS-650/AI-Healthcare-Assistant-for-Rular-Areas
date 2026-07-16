import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api.dart';
import '../../core/models.dart';

class EmergencyStats {
  final int total, critical, high, medium, low, sosTriggered, todayCount, thisWeek;
  const EmergencyStats({
    this.total = 0, this.critical = 0, this.high = 0,
    this.medium = 0, this.low = 0, this.sosTriggered = 0,
    this.todayCount = 0, this.thisWeek = 0,
  });
  factory EmergencyStats.fromJson(Map<String, dynamic> j) => EmergencyStats(
    total: j['total'] as int? ?? 0, critical: j['critical'] as int? ?? 0,
    high: j['high'] as int? ?? 0, medium: j['medium'] as int? ?? 0,
    low: j['low'] as int? ?? 0, sosTriggered: j['sos_triggered'] as int? ?? 0,
    todayCount: j['today_count'] as int? ?? 0, thisWeek: j['this_week'] as int? ?? 0,
  );
}

class EmergencyState {
  final bool isLoading; final String? error;
  final List<EmergencyItem> items; final int total, page, pageSize;
  final String? riskFilter; final bool? isEmergencyFilter;
  final EmergencyStats stats;
  const EmergencyState({
    this.isLoading = false, this.error, this.items = const [],
    this.total = 0, this.page = 1, this.pageSize = 20,
    this.riskFilter, this.isEmergencyFilter,
    this.stats = const EmergencyStats(),
  });
  int get totalPages => (total / pageSize).ceil().clamp(1, 9999);
  EmergencyState copyWith({
    bool? isLoading, String? error, bool clearError = false,
    List<EmergencyItem>? items, int? total, int? page,
    String? riskFilter, bool? isEmergencyFilter,
    EmergencyStats? stats, bool clearRisk = false, bool clearEmergency = false,
  }) => EmergencyState(
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    items: items ?? this.items, total: total ?? this.total,
    page: page ?? this.page, pageSize: pageSize, stats: stats ?? this.stats,
    riskFilter: clearRisk ? null : (riskFilter ?? this.riskFilter),
    isEmergencyFilter: clearEmergency ? null : (isEmergencyFilter ?? this.isEmergencyFilter),
  );
}

class EmergencyNotifier extends StateNotifier<EmergencyState> {
  EmergencyNotifier() : super(const EmergencyState()) { load(); }

  Future<void> load({int? page}) async {
    state = state.copyWith(isLoading: true, clearError: true, page: page ?? state.page);
    try {
      final params = <String, dynamic>{'page': state.page, 'page_size': state.pageSize};
      if (state.riskFilter != null) params['risk_level'] = state.riskFilter;
      if (state.isEmergencyFilter != null) params['is_emergency'] = state.isEmergencyFilter;

      final results = await Future.wait([
        ApiClient.instance.get('/admin/emergency', queryParameters: params),
        ApiClient.instance.get('/admin/emergency/stats'),
      ]);
      final data      = results[0].data as Map<String, dynamic>;
      final statsData = results[1].data as Map<String, dynamic>;

      state = state.copyWith(
        isLoading: false, clearError: true,
        items: (data['emergencies'] as List).cast<Map<String, dynamic>>().map(EmergencyItem.fromJson).toList(),
        total: data['total'] as int? ?? 0,
        stats: EmergencyStats.fromJson(statsData),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  void setRiskFilter(String? v) {
    state = v == null ? state.copyWith(clearRisk: true, page: 1) : state.copyWith(riskFilter: v, page: 1);
    load();
  }
  void setEmergencyFilter(bool? v) {
    state = v == null ? state.copyWith(clearEmergency: true, page: 1) : state.copyWith(isEmergencyFilter: v, page: 1);
    load();
  }
  void goToPage(int p) => load(page: p);
}

final emergencyProvider = StateNotifierProvider<EmergencyNotifier, EmergencyState>((ref) => EmergencyNotifier());
