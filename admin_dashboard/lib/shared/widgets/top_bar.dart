import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/api.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../features/authentication/auth_provider.dart';

// ── Theme mode provider ───────────────────────────────────────────────────────
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

// ── Notification model ────────────────────────────────────────────────────────
class AdminNotifItem {
  final String id;
  final String title;
  final String message;
  final String ntype;
  final bool isRead;
  final DateTime createdAt;

  const AdminNotifItem({
    required this.id,
    required this.title,
    required this.message,
    required this.ntype,
    required this.isRead,
    required this.createdAt,
  });

  factory AdminNotifItem.fromJson(Map<String, dynamic> j) => AdminNotifItem(
        id:        j['id'] as String,
        title:     j['title'] as String,
        message:   j['message'] as String? ?? j['body'] as String? ?? '',
        ntype:     j['ntype'] as String? ?? 'info',
        isRead:    j['is_read'] as bool? ?? false,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

// ── Notification state & notifier ─────────────────────────────────────────────
class _NotifState {
  final bool isLoading;
  final List<AdminNotifItem> items;
  final int unreadCount;
  const _NotifState({
    this.isLoading = false,
    this.items = const [],
    this.unreadCount = 0,
  });
}

class _NotifNotifier extends StateNotifier<_NotifState> {
  _NotifNotifier() : super(const _NotifState()) {
    load();
  }

  Future<void> load() async {
    state = const _NotifState(isLoading: true);
    try {
      final resp = await ApiClient.instance.get('/admin/notifications');
      final data = resp.data as Map<String, dynamic>;
      final items = (data['notifications'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(AdminNotifItem.fromJson)
          .toList();
      final unread = data['unread_count'] as int? ?? 0;
      state = _NotifState(items: items, unreadCount: unread);
    } catch (_) {
      // Silent fail — notifications are non-critical
      state = const _NotifState();
    }
  }

  Future<void> markRead(String id) async {
    try {
      await ApiClient.instance.patch('/admin/notifications/$id/read');
      // Optimistic update
      state = _NotifState(
        items: state.items
            .map((n) => n.id == id
                ? AdminNotifItem(
                    id: n.id, title: n.title, message: n.message,
                    ntype: n.ntype, isRead: true, createdAt: n.createdAt)
                : n)
            .toList(),
        unreadCount: (state.unreadCount - 1).clamp(0, 999),
      );
    } catch (_) {}
  }
}

// Provider is package-private (file-level)
final _notifProvider = StateNotifierProvider<_NotifNotifier, _NotifState>(
    (ref) => _NotifNotifier());

// ── TopBar ────────────────────────────────────────────────────────────────────
class TopBar extends ConsumerWidget {
  final VoidCallback? onMenuTap;
  const TopBar({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final bg          = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final auth        = ref.watch(authStateProvider);

    return Container(
      height: AppConstants.topBarHeight,
      decoration: BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Menu toggle (desktop only)
          if (onMenuTap != null) ...[
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: onMenuTap,
              tooltip: 'Toggle sidebar',
            ),
            const SizedBox(width: 8),
          ],

          // Breadcrumb
          const Expanded(child: _Breadcrumb()),

          // Dark mode toggle
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
            ),
            tooltip: isDark ? 'Light mode' : 'Dark mode',
            onPressed: () => ref.read(themeModeProvider.notifier).update(
                  (m) => m == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
                ),
          ),
          const SizedBox(width: 4),

          // Notification bell — self-contained ConsumerWidget (no ref passing)
          const _NotificationBell(),
          const SizedBox(width: 8),

          // Status dot
          const _StatusDot(),
          const SizedBox(width: 12),

          // User chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.accentLight]),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text(
                      auth.userInitials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  auth.userName,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notification Bell ─────────────────────────────────────────────────────────
// This is its own ConsumerWidget so it reads from Riverpod directly,
// avoiding the stale-ref / inactive-element crash.
class _NotificationBell extends ConsumerWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifState = ref.watch(_notifProvider);
    final isDark     = Theme.of(context).brightness == Brightness.dark;

    return PopupMenuButton<void>(
      offset: const Offset(0, 48),
      tooltip: 'Notifications',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      constraints: const BoxConstraints(minWidth: 340, maxWidth: 380),
      icon: _BellIcon(unreadCount: notifState.unreadCount),
      itemBuilder: (ctx) => [
        PopupMenuItem<void>(
          enabled: false,
          padding: EdgeInsets.zero,
          // Build panel inside itemBuilder using a plain widget —
          // it reads from ref via Consumer to avoid stale captures.
          child: _NotificationPanel(isDark: isDark),
        ),
      ],
    );
  }
}

// ── Bell icon with badge ──────────────────────────────────────────────────────
class _BellIcon extends StatelessWidget {
  final int unreadCount;
  const _BellIcon({required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          unreadCount > 0
              ? Icons.notifications_rounded
              : Icons.notifications_none_rounded,
          size: 22,
          color: unreadCount > 0 ? AppColors.warning : null,
        ),
        if (unreadCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                  color: AppColors.error, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Notification Panel ────────────────────────────────────────────────────────
// Uses Consumer internally so it always has a fresh WidgetRef.
class _NotificationPanel extends StatelessWidget {
  final bool isDark;
  const _NotificationPanel({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (ctx, ref, _) {
        final state    = ref.watch(_notifProvider);
        final notifier = ref.read(_notifProvider.notifier);

        return SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_rounded,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Notifications',
                      style: Theme.of(ctx)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (state.unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          '${state.unreadCount} new',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      tooltip: 'Refresh',
                      onPressed: notifier.load,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Divider(
                  height: 1,
                  color:
                      isDark ? AppColors.darkBorder : AppColors.lightBorder),

              // ── Body ──────────────────────────────────────────────────
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else if (state.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: Column(children: [
                      const Icon(Icons.notifications_off_outlined,
                          size: 32, color: AppColors.lightTextLight),
                      const SizedBox(height: 8),
                      Text('No notifications',
                          style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                              color: AppColors.lightTextMuted)),
                    ]),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: SingleChildScrollView(
                    child: Column(
                      children: state.items.take(10).map((n) => _NotifTile(
                            item:   n,
                            isDark: isDark,
                            onTap:  () => notifier.markRead(n.id),
                          )).toList(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── Notification Tile ─────────────────────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  final AdminNotifItem item;
  final bool isDark;
  final VoidCallback onTap;
  const _NotifTile(
      {required this.item, required this.isDark, required this.onTap});

  Color get _typeColor => switch (item.ntype) {
        'warning' => AppColors.warning,
        'error'   => AppColors.error,
        'success' => AppColors.success,
        _         => AppColors.info,
      };

  IconData get _typeIcon => switch (item.ntype) {
        'warning' => Icons.warning_rounded,
        'error'   => Icons.error_rounded,
        'success' => Icons.check_circle_rounded,
        _         => Icons.info_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.isRead ? null : onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        decoration: BoxDecoration(
          color: item.isRead ? null : _typeColor.withOpacity(0.05),
          border: Border(
            bottom: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _typeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_typeIcon, color: _typeColor, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: item.isRead
                                  ? FontWeight.w400
                                  : FontWeight.w700,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!item.isRead)
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(left: 6),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: _typeColor),
                      ),
                  ]),
                  const SizedBox(height: 2),
                  Text(
                    item.message,
                    style: Theme.of(context).textTheme.labelSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeAgo(item.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.lightTextLight,
                          fontSize: 10,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(dt);
  }
}

// ── Breadcrumb ────────────────────────────────────────────────────────────────
class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb();

  @override
  Widget build(BuildContext context) {
    String location = '/dashboard';
    try {
      location = GoRouterState.of(context).matchedLocation;
    } catch (_) {}

    final segments = location.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) segments.add('dashboard');

    return Row(
      children: [
        for (var i = 0; i < segments.length; i++) ...[
          if (i > 0)
            const Icon(Icons.chevron_right_rounded,
                size: 16, color: AppColors.lightTextMuted),
          Text(
            segments[i]
                .replaceAll('-', ' ')
                .split(' ')
                .map((w) =>
                    w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
                .join(' '),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: i == segments.length - 1
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
          ),
        ],
      ],
    );
  }
}

// ── Backend status dot ────────────────────────────────────────────────────────
class _StatusDot extends StatelessWidget {
  const _StatusDot();

  @override
  Widget build(BuildContext context) => Tooltip(
        message: 'Backend connected',
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: AppColors.success),
        ),
      );
}
