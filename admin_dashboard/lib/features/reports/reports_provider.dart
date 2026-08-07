import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api.dart';

class ReportsState {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> userRegistrationTrend;
  final List<Map<String, dynamic>> symptomFrequency;
  final List<Map<String, dynamic>> riskDistribution;
  final List<Map<String, dynamic>> chatbotDailyUsage;
  final List<Map<String, dynamic>> emergencyWeekly;
  final List<Map<String, dynamic>> educationEngagement;
  final int days;

  const ReportsState({
    this.isLoading = false,
    this.error,
    this.userRegistrationTrend = const [],
    this.symptomFrequency = const [],
    this.riskDistribution = const [],
    this.chatbotDailyUsage = const [],
    this.emergencyWeekly = const [],
    this.educationEngagement = const [],
    this.days = 30,
  });

  ReportsState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<Map<String, dynamic>>? userRegistrationTrend,
    List<Map<String, dynamic>>? symptomFrequency,
    List<Map<String, dynamic>>? riskDistribution,
    List<Map<String, dynamic>>? chatbotDailyUsage,
    List<Map<String, dynamic>>? emergencyWeekly,
    List<Map<String, dynamic>>? educationEngagement,
    int? days,
  }) =>
      ReportsState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        userRegistrationTrend:
            userRegistrationTrend ?? this.userRegistrationTrend,
        symptomFrequency: symptomFrequency ?? this.symptomFrequency,
        riskDistribution: riskDistribution ?? this.riskDistribution,
        chatbotDailyUsage: chatbotDailyUsage ?? this.chatbotDailyUsage,
        emergencyWeekly: emergencyWeekly ?? this.emergencyWeekly,
        educationEngagement: educationEngagement ?? this.educationEngagement,
        days: days ?? this.days,
      );
}

class ReportsNotifier extends StateNotifier<ReportsState> {
  ReportsNotifier() : super(const ReportsState()) {
    load();
  }

  static List<Map<String, dynamic>> _list(dynamic d) =>
      d == null ? [] : (d as List).cast<Map<String, dynamic>>();

  Future<void> load({int? days}) async {
    final d = days ?? state.days;
    state = state.copyWith(isLoading: true, clearError: true, days: d);
    try {
      final resp = await ApiClient.instance
          .get('/admin/reports', queryParameters: {'days': d});
      final data = resp.data as Map<String, dynamic>;
      state = state.copyWith(
        isLoading: false,
        userRegistrationTrend: _list(data['user_registration_trend']),
        symptomFrequency: _list(data['symptom_frequency']),
        riskDistribution: _list(data['risk_distribution']),
        chatbotDailyUsage: _list(data['chatbot_daily_usage']),
        emergencyWeekly: _list(data['emergency_weekly']),
        educationEngagement: _list(data['education_engagement']),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  void changeDays(int d) => load(days: d);
}

final reportsProvider =
    StateNotifierProvider<ReportsNotifier, ReportsState>(
        (ref) => ReportsNotifier());
