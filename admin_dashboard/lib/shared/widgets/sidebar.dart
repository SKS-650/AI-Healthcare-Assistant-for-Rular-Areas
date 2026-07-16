import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/router.dart';
import '../../core/theme.dart';
import '../../features/authentication/auth_provider.dart';
import 'app_shell.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

const _navItems = [
  _NavItem(
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard_rounded,
    route: AppRoutes.dashboard,
  ),
  _NavItem(
    label: 'Users',
    icon: Icons.people_outline_rounded,
    activeIcon: Icons.people_rounded,
    route: AppRoutes.users,
  ),
  _NavItem(
    label: 'Emergency',
    icon: Icons.emergency_outlined,
    activeIcon: Icons.emergency_rounded,
    route: AppRoutes.emergency,
  ),
  _NavItem(
    label: 'Chatbot',
    icon: Icons.chat_bubble_outline_rounded,
    activeIcon: Icons.chat_bubble_rounded,
    route: AppRoutes.chatbot,
  ),
  _NavItem(
    label: 'Education',
    icon: Icons.menu_book_outlined,
    activeIcon: Icons.menu_book_rounded,
    route: AppRoutes.education,
  ),
  _NavItem(
    label: 'Analytics',
    icon: Icons.analytics_outlined,
    activeIcon: Icons.analytics_rounded,
    route: AppRoutes.analytics,
  ),
  _NavItem(
    label: 'Datasets',
    icon: Icons.dataset_outlined,
    activeIcon: Icons.dataset_rounded,
    route: AppRoutes.datasets,
  ),
  _NavItem(
    label: 'Reports',
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart_rounded,
    route: AppRoutes.reports,
  ),
  _NavItem(
    label: 'Logs',
    icon: Icons.list_alt_outlined,
    activeIcon: Icons.list_alt_rounded,
    route: AppRoutes.logs,
  ),
  _NavItem(
    label: 'Settings',
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings_rounded,
    route: AppRoutes.settings,
  ),
];

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collapsed = ref.watch(sidebarCollapsedProvider);
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final auth = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      color: bg,
      child: Column(
        children: [
          // ── Logo ─────────────────────────────────────────────────────────
          Container(
            height: AppConstants.topBarHeight,
            padding: EdgeInsets.symmetric(horizontal: collapsed ? 12 : 20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_hospital_rounded,
                      color: Colors.white, size: 20),
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Healthcare AI',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        Text('Admin Panel',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Navigation items ─────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              children: _navItems
                  .asMap()
                  .entries
                  .map((e) => _NavTile(
                        item: e.value,
                        isActive: currentRoute.startsWith(e.value.route),
                        collapsed: collapsed,
                      )
                          .animate()
                          .fadeIn(
                              delay: Duration(milliseconds: e.key * 40),
                              duration: 300.ms))
                  .toList(),
            ),
          ),

          // ── User profile ─────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.all(collapsed ? 10 : 16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: collapsed
                ? _Avatar(initials: auth.userInitials)
                : Row(
                    children: [
                      _Avatar(initials: auth.userInitials),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(auth.userName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.darkText
                                            : AppColors.lightText),
                                overflow: TextOverflow.ellipsis),
                            Text(auth.userRole.replaceAll('_', ' ').toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: AppColors.primary)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        tooltip: 'Sign out',
                        color: AppColors.lightTextMuted,
                        onPressed: () async {
                          await ref
                              .read(authStateProvider.notifier)
                              .logout();
                          if (context.mounted) context.go(AppRoutes.login);
                        },
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  const _Avatar({required this.initials});

  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppColors.accent, AppColors.accentLight]),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(initials,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
        ),
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

    return Tooltip(
      message: collapsed ? item.label : '',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primarySurface
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => context.go(item.route),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: collapsed ? 12 : 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isActive ? item.activeIcon : item.icon,
                  size: 20,
                  color: isActive
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted),
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isActive
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkText
                                  : AppColors.lightText),
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
