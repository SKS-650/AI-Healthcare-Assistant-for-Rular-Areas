import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api.dart';
import '../../core/models.dart';

class DashboardState {
  final bool isLoading;
  final String? error;
  final DashboardStats stats;
  final List<Map<String, dynamic>> recentUsers;
  final List<Map<String, dynamic>> recentEmergencies;
  final List<Map<String, dynamic>> userGrowth;
  final List<Map<String, dynamic>> emergencyTrend;
  final List<Map<String, dynamic>> chatbotTrend;
  final Map<String, dynamic>? systemHealth;

  DashboardState({
    this.isLoading = false,
    this.error,
    DashboardStats? stats,
    this.recentUsers = const [],
    this.recentEmergencies = const [],
    this.userGrowth = const [],
    this.emergencyTrend = const [],
    this.chatbotTrend = const [],
    this.systemHealth,
  }) : stats = stats ?? DashboardStats.empty;

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    DashboardStats? stats,
    List<Map<String, dynamic>>? recentUsers,
    List<Map<String, dynamic>>? recentEmergencies,
    List<Map<String, dynamic>>? userGrowth,
    List<Map<String, dynamic>>? emergencyTrend,
    List<Map<String, dynamic>>? chatbotTrend,
    Map<String, dynamic>? systemHealth,
  }) =>
      DashboardState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        stats: stats ?? this.stats,
        recentUsers: recentUsers ?? this.recentUsers,
        recentEmergencies: recentEmergencies ?? this.recentEmergencies,
        userGrowth: userGrowth ?? this.userGrowth,
        emergencyTrend: emergencyTrend ?? this.emergencyTrend,
        chatbotTrend: chatbotTrend ?? this.chatbotTrend,
        systemHealth: systemHealth ?? this.systemHealth,
      );
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(DashboardState()) {
    load();
  }

  static List<Map<String, dynamic>> _list(dynamic d) =>
      d == null ? [] : (d as List).cast<Map<String, dynamic>>();

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dashResp = await ApiClient.instance.get('/admin/dashboard');
      final data = dashResp.data as Map<String, dynamic>;
      final statsData = data['stats'] as Map<String, dynamic>;

      // System health — non-critical, ignore errors
      Map<String, dynamic>? healthData;
      try {
        final healthResp =
            await ApiClient.instance.get('/admin/system/health');
        healthData = healthResp.data as Map<String, dynamic>?;
      } catch (_) {}

      state = state.copyWith(
        isLoading: false,
        clearError: true,
        stats: DashboardStats.fromJson(statsData),
        recentUsers: _list(data['recent_users']),
        recentEmergencies: _list(data['recent_emergencies']),
        userGrowth: _list(data['user_growth']),
        emergencyTrend: _list(data['emergency_trend']),
        chatbotTrend: _list(data['chatbot_trend']),
        systemHealth: healthData,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>(
        (ref) => DashboardNotifier());
