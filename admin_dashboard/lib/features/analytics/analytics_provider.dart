import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class AnalyticsState {
  final bool isLoading;
  final String? error;
  final int days;

  // Stats
  final int totalAssessments;
  final int todayAssessments;
  final int weekAssessments;
  final int emergencyCases;
  final double avgRiskScore;

  // Chart / list data
  final List<Map<String, dynamic>> symptomFrequency;
  final List<Map<String, dynamic>> trend;
  final List<Map<String, dynamic>> riskDistribution;
  final List<Map<String, dynamic>> genderDistribution;
  final List<Map<String, dynamic>> ageDistribution;
  final List<Map<String, dynamic>> emergencyTypes;

  const AnalyticsState({
    this.isLoading = false,
    this.error,
    this.days = 30,
    this.totalAssessments = 0,
    this.todayAssessments = 0,
    this.weekAssessments = 0,
    this.emergencyCases = 0,
    this.avgRiskScore = 0.0,
    this.symptomFrequency = const [],
    this.trend = const [],
    this.riskDistribution = const [],
    this.genderDistribution = const [],
    this.ageDistribution = const [],
    this.emergencyTypes = const [],
  });

  AnalyticsState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    int? days,
    int? totalAssessments,
    int? todayAssessments,
    int? weekAssessments,
    int? emergencyCases,
    double? avgRiskScore,
    List<Map<String, dynamic>>? symptomFrequency,
    List<Map<String, dynamic>>? trend,
    List<Map<String, dynamic>>? riskDistribution,
    List<Map<String, dynamic>>? genderDistribution,
    List<Map<String, dynamic>>? ageDistribution,
    List<Map<String, dynamic>>? emergencyTypes,
  }) =>
      AnalyticsState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        days: days ?? this.days,
        totalAssessments: totalAssessments ?? this.totalAssessments,
        todayAssessments: todayAssessments ?? this.todayAssessments,
        weekAssessments: weekAssessments ?? this.weekAssessments,
        emergencyCases: emergencyCases ?? this.emergencyCases,
        avgRiskScore: avgRiskScore ?? this.avgRiskScore,
        symptomFrequency: symptomFrequency ?? this.symptomFrequency,
        trend: trend ?? this.trend,
        riskDistribution: riskDistribution ?? this.riskDistribution,
        genderDistribution: genderDistribution ?? this.genderDistribution,
        ageDistribution: ageDistribution ?? this.ageDistribution,
        emergencyTypes: emergencyTypes ?? this.emergencyTypes,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier() : super(const AnalyticsState()) {
    load();
  }

  Future<void> load({int? days}) async {
    final d = days ?? state.days;
    state = state.copyWith(isLoading: true, clearError: true, days: d);
    try {
      final results = await Future.wait([
        ApiClient.instance.get('/admin/analytics/stats'),
        ApiClient.instance.get('/admin/analytics/symptom-frequency', queryParameters: {'limit': 20}),
        ApiClient.instance.get('/admin/analytics/trend', queryParameters: {'days': d}),
        ApiClient.instance.get('/admin/analytics/risk-distribution'),
        ApiClient.instance.get('/admin/analytics/gender-distribution'),
        ApiClient.instance.get('/admin/analytics/age-distribution'),
        ApiClient.instance.get('/admin/analytics/emergency-types'),
      ]);

      final stats = results[0].data as Map<String, dynamic>;
      _castList(results[1].data);
      _castList(results[2].data);
      _castList(results[3].data);
      _castList(results[4].data);
      _castList(results[5].data);
      _castList(results[6].data);

      state = state.copyWith(
        isLoading: false,
        clearError: true,
        totalAssessments: stats['total_assessments'] as int? ?? 0,
        todayAssessments: stats['today_assessments'] as int? ?? 0,
        weekAssessments: stats['week_assessments'] as int? ?? 0,
        emergencyCases: stats['emergency_cases'] as int? ?? 0,
        avgRiskScore: (stats['avg_risk_score'] as num?)?.toDouble() ?? 0.0,
        symptomFrequency: _castList(results[1].data),
        trend: _castList(results[2].data),
        riskDistribution: _castList(results[3].data),
        genderDistribution: _castList(results[4].data),
        ageDistribution: _castList(results[5].data),
        emergencyTypes: _castList(results[6].data),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  void setDays(int d) => load(days: d);

  static List<Map<String, dynamic>> _castList(dynamic raw) =>
      (raw as List? ?? []).cast<Map<String, dynamic>>();
}

// ── Provider ──────────────────────────────────────────────────────────────────

final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>(
  (ref) => AnalyticsNotifier(),
);
