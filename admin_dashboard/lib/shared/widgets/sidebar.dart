import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/router.dart';
import '../../core/theme.dart';
import '../../features/authentication/auth_provider.dart';
import '../../features/notifications/notifications_provider.dart';
import 'app_shell.dart';

// ── Nav item model ────────────────────────────────────────────────────────────

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  final String? section; // section header above this item (null = same section)

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
    this.section,
  });
}

const _navItems = [
  _NavItem(label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      route: AppRoutes.dashboard,
      section: 'OVERVIEW'),

  _NavItem(label: 'Users',
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      route: AppRoutes.users,
      section: 'USER MANAGEMENT'),

  _NavItem(label: 'Doctors',
      icon: Icons.medical_services_outlined,
      activeIcon: Icons.medical_services_rounded,
      route: AppRoutes.doctors),

  _NavItem(label: 'Authentication',
      icon: Icons.lock_outline_rounded,
      activeIcon: Icons.lock_rounded,
      route: AppRoutes.authentication),

  _NavItem(label: 'User Profiles',
      icon: Icons.manage_accounts_outlined,
      activeIcon: Icons.manage_accounts_rounded,
      route: AppRoutes.profile),

  _NavItem(label: 'Emergency',
      icon: Icons.emergency_outlined,
      activeIcon: Icons.emergency_rounded,
      route: AppRoutes.emergency,
      section: 'MODULES'),

  _NavItem(label: 'AI Chatbot',
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
      route: AppRoutes.chatbot),

  _NavItem(label: 'Disease Prediction',
      icon: Icons.biotech_outlined,
      activeIcon: Icons.biotech_rounded,
      route: AppRoutes.diseasePrediction),

  _NavItem(label: 'Health Records',
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder_rounded,
      route: AppRoutes.healthRecords),

  _NavItem(label: 'Medical History',
      icon: Icons.history_edu_outlined,
      activeIcon: Icons.history_edu_rounded,
      route: AppRoutes.medicalHistory),

  _NavItem(label: 'Education',
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
      route: AppRoutes.education),

  _NavItem(label: 'Feedback',
      icon: Icons.feedback_outlined,
      activeIcon: Icons.feedback_rounded,
      route: AppRoutes.feedback),

  _NavItem(label: 'Analytics',
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics_rounded,
      route: AppRoutes.analytics,
      section: 'DATA & INSIGHTS'),

  _NavItem(label: 'Reports',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      route: AppRoutes.reports),

  _NavItem(label: 'Datasets',
      icon: Icons.dataset_outlined,
      activeIcon: Icons.dataset_rounded,
      route: AppRoutes.datasets),

  _NavItem(label: 'Activity Logs',
      icon: Icons.list_alt_outlined,
      activeIcon: Icons.list_alt_rounded,
      route: AppRoutes.logs,
      section: 'SYSTEM'),

  _NavItem(label: 'Notifications',
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications_rounded,
      route: AppRoutes.notifications),

  _NavItem(label: 'Settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      route: AppRoutes.settings),
];

// ── Sidebar ───────────────────────────────────────────────────────────────────

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collapsed    = ref.watch(sidebarCollapsedProvider);
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final auth         = ref.watch(authStateProvider);
    final isDark       = Theme.of(context).brightness == Brightness.dark;
    final borderColor  = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final bg           = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      color: bg,
      child: Column(children: [
        // ── Logo ──────────────────────────────────────────────────────────
        Container(
          height: AppConstants.topBarHeight,
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 12 : 20),
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor))),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/logo.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            ),
            if (!collapsed) ...[
              const SizedBox(width: 12),
              Expanded(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HealthAI',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  Text('Admin Panel',
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: AppColors.primary)),
                ],
              )),
            ],
          ]),
        ),

        // ── Navigation ────────────────────────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            children: _buildNavItems(context, currentRoute, collapsed, isDark),
          ),
        ),

        // ── User profile footer ───────────────────────────────────────────
        Container(
          padding: EdgeInsets.all(collapsed ? 10 : 16),
          decoration:
              BoxDecoration(border: Border(top: BorderSide(color: borderColor))),
          child: collapsed
              ? _Avatar(initials: auth.userInitials)
              : Row(children: [
                  _Avatar(initials: auth.userInitials),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(auth.userName,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                      Text(auth.userRole.replaceAll('_', ' ').toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.primary)),
                    ],
                  )),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    tooltip: 'Sign out',
                    color: AppColors.lightTextMuted,
                    onPressed: () async {
                      await ref.read(authStateProvider.notifier).logout();
                      if (context.mounted) context.go(AppRoutes.login);
                    },
                  ),
                ]),
        ),
      ]),
    );
  }

  List<Widget> _buildNavItems(BuildContext context, String currentRoute,
      bool collapsed, bool isDark) {
    final widgets = <Widget>[];
    for (var i = 0; i < _navItems.length; i++) {
      final item = _navItems[i];
      // Section header
      if (!collapsed && item.section != null) {
        if (i > 0) widgets.add(const SizedBox(height: 4));
        widgets.add(Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
          child: Text(item.section!,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.darkTextLight : AppColors.lightTextLight)),
        ));
      } else if (collapsed && item.section != null && i > 0) {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Divider(height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ));
      }
      widgets.add(_NavTile(
        item: item,
        isActive: currentRoute.startsWith(item.route),
        collapsed: collapsed,
      ).animate().fadeIn(
          delay: Duration(milliseconds: i * 30), duration: 300.ms));
    }
    return widgets;
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String initials;
  const _Avatar({required this.initials});

  @override
  Widget build(BuildContext context) => Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppColors.accent, AppColors.accentLight]),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: Text(initials,
            style: const TextStyle(color: Colors.white,
                fontWeight: FontWeight.w700, fontSize: 14))),
      );
}

class _NavTile extends ConsumerWidget {
  final _NavItem item;
  final bool isActive;
  final bool collapsed;

  const _NavTile({
    required this.item,
    required this.isActive,
    required this.collapsed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Show badge on notifications
    final unread = item.route == AppRoutes.notifications
        ? ref.watch(notificationsProvider).unreadCount
        : 0;

    return Tooltip(
      message: collapsed ? item.label : '',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => context.go(item.route),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: collapsed ? 12 : 14, vertical: 11),
            child: Row(children: [
              Stack(children: [
                Icon(isActive ? item.activeIcon : item.icon,
                    size: 20,
                    color: isActive ? AppColors.primary
                        : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
                if (unread > 0)
                  Positioned(right: 0, top: 0,
                      child: Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.error, shape: BoxShape.circle),
                      )),
              ]),
              if (!collapsed) ...[
                const SizedBox(width: 12),
                Expanded(child: Text(item.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        color: isActive ? AppColors.primary
                            : (isDark ? AppColors.darkText : AppColors.lightText)))),
                if (unread > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('$unread',
                        style: const TextStyle(color: Colors.white,
                            fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}
