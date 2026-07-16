import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api.dart';
import '../../core/models.dart';

// ── State ─────────────────────────────────────────────────────────────────────
class DashboardState {
  final bool isLoading;
  final String? error;
  final DashboardStats stats;
  final List<Map<String, dynamic>> userGrowth;
  final List<Map<String, dynamic>> emergencyTrend;
  final List<Map<String, dynamic>> chatbotTrend;
  final List<Map<String, dynamic>> recentUsers;
  final List<Map<String, dynamic>> recentEmergencies;

  DashboardState({
    this.isLoading = false,
    this.error,
    DashboardStats? stats,
    this.userGrowth = const [],
    this.emergencyTrend = const [],
    this.chatbotTrend = const [],
    this.recentUsers = const [],
    this.recentEmergencies = const [],
  }) : stats = stats ?? DashboardStats.empty;
}

// ── Notifier ──────────────────────────────────────────────────────────────────
class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(DashboardState(isLoading: true)) {
    load();
  }

  Future<void> load() async {
    state = DashboardState(isLoading: true);
    try {
      final resp = await ApiClient.instance.get('/admin/dashboard');
      final d    = resp.data as Map<String, dynamic>;

      state = DashboardState(
        stats: DashboardStats.fromJson(d['stats'] as Map<String, dynamic>),
        userGrowth: _castList(d['user_growth']),
        emergencyTrend: _castList(d['emergency_trend']),
        chatbotTrend: _castList(d['chatbot_trend']),
        recentUsers: _castList(d['recent_users']),
        recentEmergencies: _castList(d['recent_emergencies']),
      );
    } catch (e) {
      state = DashboardState(error: errorMessage(e));
    }
  }

  static List<Map<String, dynamic>> _castList(dynamic raw) =>
      (raw as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>(
        (ref) => DashboardNotifier());
