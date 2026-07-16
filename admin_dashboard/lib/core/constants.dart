// Core application constants

class AppConstants {
  AppConstants._();

  // ── API ────────────────────────────────────────────────────────────────────
  static const String baseUrl = 'http://localhost:8000';
  static const String apiPrefix = '/api/v1';
  static const String apiBase = '$baseUrl$apiPrefix';

  // ── Storage keys ──────────────────────────────────────────────────────────
  static const String kAccessToken = 'admin_access_token';
  static const String kRefreshToken = 'admin_refresh_token';
  static const String kAdminUser = 'admin_user_data';
  static const String kThemeMode = 'theme_mode';

  // ── Sidebar ────────────────────────────────────────────────────────────────
  static const double sidebarWidthExpanded = 260;
  static const double sidebarWidthCollapsed = 72;
  static const double topBarHeight = 64;

  // ── Responsive breakpoints ────────────────────────────────────────────────
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1100;

  // ── Animation durations ───────────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 600);

  // ── Pagination ────────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;

  // ── Risk levels ───────────────────────────────────────────────────────────
  static const String riskLow = 'LOW';
  static const String riskMedium = 'MEDIUM';
  static const String riskHigh = 'HIGH';
  static const String riskCritical = 'CRITICAL';
}
