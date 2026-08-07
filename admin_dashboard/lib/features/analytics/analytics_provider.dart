import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class SymptomFreqItem {
  final String symptom;
  final int count;
  const SymptomFreqItem({required this.symptom, required this.count});
  factory SymptomFreqItem.fromJson(Map<String, dynamic> j) =>
      SymptomFreqItem(
          symptom: j['symptom'] as String? ?? '',
          count: j['count'] as int? ?? 0);
}

class AnalyticsState {
  final bool isLoadingReports;
  final bool isLoadingSymptoms;
  final String? error;
  // Reports data
  final List<Map<String, dynamic>> userRegistrationTrend;
  final List<Map<String, dynamic>> chatbotDailyUsage;
  final List<Map<String, dynamic>> emergencyWeekly;
  final List<Map<String, dynamic>> educationEngagement;
  // Symptom analytics
  final Map<String, dynamic>? symptomStats;
  final List<SymptomFreqItem> symptomFrequency;
  final List<Map<String, dynamic>> riskDistribution;
  final List<Map<String, dynamic>> genderDistribution;
  final List<Map<String, dynamic>> ageDistribution;
  final List<Map<String, dynamic>> emergencyTypes;
  final List<Map<String, dynamic>> assessmentTrend;
  final int reportsDays;

  const AnalyticsState({
    this.isLoadingReports = false,
    this.isLoadingSymptoms = false,
    this.error,
    this.userRegistrationTrend = const [],
    this.chatbotDailyUsage = const [],
    this.emergencyWeekly = const [],
    this.educationEngagement = const [],
    this.symptomStats,
    this.symptomFrequency = const [],
    this.riskDistribution = const [],
    this.genderDistribution = const [],
    this.ageDistribution = const [],
    this.emergencyTypes = const [],
    this.assessmentTrend = const [],
    this.reportsDays = 30,
  });

  AnalyticsState copyWith({
    bool? isLoadingReports,
    bool? isLoadingSymptoms,
    String? error,
    bool clearError = false,
    List<Map<String, dynamic>>? userRegistrationTrend,
    List<Map<String, dynamic>>? chatbotDailyUsage,
    List<Map<String, dynamic>>? emergencyWeekly,
    List<Map<String, dynamic>>? educationEngagement,
    Map<String, dynamic>? symptomStats,
    List<SymptomFreqItem>? symptomFrequency,
    List<Map<String, dynamic>>? riskDistribution,
    List<Map<String, dynamic>>? genderDistribution,
    List<Map<String, dynamic>>? ageDistribution,
    List<Map<String, dynamic>>? emergencyTypes,
    List<Map<String, dynamic>>? assessmentTrend,
    int? reportsDays,
  }) =>
      AnalyticsState(
        isLoadingReports: isLoadingReports ?? this.isLoadingReports,
        isLoadingSymptoms: isLoadingSymptoms ?? this.isLoadingSymptoms,
        error: clearError ? null : (error ?? this.error),
        userRegistrationTrend:
            userRegistrationTrend ?? this.userRegistrationTrend,
        chatbotDailyUsage: chatbotDailyUsage ?? this.chatbotDailyUsage,
        emergencyWeekly: emergencyWeekly ?? this.emergencyWeekly,
        educationEngagement: educationEngagement ?? this.educationEngagement,
        symptomStats: symptomStats ?? this.symptomStats,
        symptomFrequency: symptomFrequency ?? this.symptomFrequency,
        riskDistribution: riskDistribution ?? this.riskDistribution,
        genderDistribution: genderDistribution ?? this.genderDistribution,
        ageDistribution: ageDistribution ?? this.ageDistribution,
        emergencyTypes: emergencyTypes ?? this.emergencyTypes,
        assessmentTrend: assessmentTrend ?? this.assessmentTrend,
        reportsDays: reportsDays ?? this.reportsDays,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier() : super(const AnalyticsState()) {
    loadReports();
    loadSymptomAnalytics();
  }

  static List<Map<String, dynamic>> _asList(dynamic data) {
    if (data == null) return [];
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<void> loadReports({int days = 30}) async {
    state = state.copyWith(
        isLoadingReports: true, clearError: true, reportsDays: days);
    try {
      final resp = await ApiClient.instance
          .get('/admin/reports', queryParameters: {'days': days});
      final data = resp.data as Map<String, dynamic>;
      state = state.copyWith(
        isLoadingReports: false,
        userRegistrationTrend:
            _asList(data['user_registration_trend']),
        chatbotDailyUsage: _asList(data['chatbot_daily_usage']),
        emergencyWeekly: _asList(data['emergency_weekly']),
        educationEngagement: _asList(data['education_engagement']),
      );
    } catch (e) {
      state = state.copyWith(
          isLoadingReports: false, error: errorMessage(e));
    }
  }

  Future<void> loadSymptomAnalytics() async {
    state = state.copyWith(isLoadingSymptoms: true);
    try {
      final results = await Future.wait([
        ApiClient.instance.get('/admin/analytics/stats'),
        ApiClient.instance.get('/admin/analytics/symptom-frequency',
            queryParameters: {'limit': 20}),
        ApiClient.instance.get('/admin/analytics/risk-distribution'),
        ApiClient.instance.get('/admin/analytics/gender-distribution'),
        ApiClient.instance.get('/admin/analytics/age-distribution'),
        ApiClient.instance.get('/admin/analytics/emergency-types'),
        ApiClient.instance.get('/admin/analytics/trend',
            queryParameters: {'days': 30}),
      ]);

      state = state.copyWith(
        isLoadingSymptoms: false,
        symptomStats: results[0].data as Map<String, dynamic>?,
        symptomFrequency: _asList(results[1].data)
            .map(SymptomFreqItem.fromJson)
            .toList(),
        riskDistribution: _asList(results[2].data),
        genderDistribution: _asList(results[3].data),
        ageDistribution: _asList(results[4].data),
        emergencyTypes: _asList(results[5].data),
        assessmentTrend: _asList(results[6].data),
      );
    } catch (e) {
      state =
          state.copyWith(isLoadingSymptoms: false, error: errorMessage(e));
    }
  }

  void changeReportDays(int days) => loadReports(days: days);
}

final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>(
        (ref) => AnalyticsNotifier());
