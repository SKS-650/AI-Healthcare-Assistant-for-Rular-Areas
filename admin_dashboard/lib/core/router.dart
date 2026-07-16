import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/analytics/analytics_page.dart';
import '../features/authentication/auth_provider.dart';
import '../features/authentication/login_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/dataset/dataset_page.dart';
import '../features/users/users_page.dart';
import '../features/emergency/emergency_page.dart';
import '../features/chatbot/chatbot_page.dart';
import '../features/education/education_page.dart';
import '../features/reports/reports_page.dart';
import '../features/logs/logs_page.dart';
import '../features/settings/settings_page.dart';
import '../shared/widgets/app_shell.dart';

// ── Route paths ───────────────────────────────────────────────────────────────
class AppRoutes {
  static const login      = '/login';
  static const dashboard  = '/dashboard';
  static const users      = '/users';
  static const emergency  = '/emergency';
  static const chatbot    = '/chatbot';
  static const education  = '/education';
  static const analytics  = '/analytics';
  static const datasets   = '/datasets';
  static const reports    = '/reports';
  static const logs       = '/logs';
  static const settings   = '/settings';
}

// ── ChangeNotifier bridge ─────────────────────────────────────────────────────
// GoRouter requires a Listenable for refreshListenable — this bridges
// Riverpod's StateNotifier into a ChangeNotifier without rebuilding the
// GoRouter instance on every auth change.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen<AuthState>(authStateProvider, (_, __) => notifyListeners());
  }
}

// ── Router provider ───────────────────────────────────────────────────────────
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth        = ref.read(authStateProvider);
      final isLoading   = auth.isLoading;
      final isLoggedIn  = auth.isAuthenticated;
      final isLoginPage = state.matchedLocation == AppRoutes.login;

      // Don't redirect while checking the stored session
      if (isLoading) return null;

      if (!isLoggedIn && !isLoginPage) return AppRoutes.login;
      if (isLoggedIn  &&  isLoginPage) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      // ── Public ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginPage(),
      ),

      // ── Authenticated shell ───────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (_, s) => _fade(s, const DashboardPage()),
          ),
          GoRoute(
            path: AppRoutes.users,
            pageBuilder: (_, s) => _fade(s, const UsersPage()),
          ),
          GoRoute(
            path: AppRoutes.emergency,
            pageBuilder: (_, s) => _fade(s, const EmergencyPage()),
          ),
          GoRoute(
            path: AppRoutes.chatbot,
            pageBuilder: (_, s) => _fade(s, const ChatbotPage()),
          ),
          GoRoute(
            path: AppRoutes.education,
            pageBuilder: (_, s) => _fade(s, const EducationPage()),
          ),
          GoRoute(
            path: AppRoutes.analytics,
            pageBuilder: (_, s) => _fade(s, const AnalyticsPage()),
          ),
          GoRoute(
            path: AppRoutes.datasets,
            pageBuilder: (_, s) => _fade(s, const DatasetPage()),
          ),
          GoRoute(
            path: AppRoutes.reports,
            pageBuilder: (_, s) => _fade(s, const ReportsPage()),
          ),
          GoRoute(
            path: AppRoutes.logs,
            pageBuilder: (_, s) => _fade(s, const LogsPage()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (_, s) => _fade(s, const SettingsPage()),
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.error}')),
    ),
  );
});

CustomTransitionPage _fade(GoRouterState state, Widget child) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (_, animation, __, c) =>
          FadeTransition(opacity: animation, child: c),
    );
