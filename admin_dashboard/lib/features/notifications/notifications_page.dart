import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import 'notifications_provider.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Notifications',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700))
                .animate().fadeIn(duration: 400.ms),
            Text('${state.unreadCount} unread system notifications',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.lightTextMuted))
                .animate().fadeIn(delay: 100.ms),
          ])),
          if (state.unreadCount > 0)
            OutlinedButton.icon(
              onPressed: () => notifier.markAllAsRead(),
              icon: const Icon(Icons.done_all_rounded, size: 16),
              label: const Text('Mark All Read'),
            ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => notifier.load(),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Refresh'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ]).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 24),

        if (state.isLoading)
          const Center(child: Padding(padding: EdgeInsets.all(48),
              child: CircularProgressIndicator()))
        else if (state.notifications.isEmpty)
          _EmptyState()
        else
          ...state.notifications.asMap().entries.map((e) =>
              _NotificationCard(
                notification: e.value,
                onMarkRead: () => notifier.markAsRead(e.value.id),
              ).animate().fadeIn(delay: Duration(milliseconds: e.key * 40))),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          child: Center(child: Column(children: [
            const Icon(Icons.notifications_none_rounded,
                size: 48, color: AppColors.lightTextLight),
            const SizedBox(height: 12),
            Text('No notifications',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(color: AppColors.lightTextMuted)),
            const SizedBox(height: 4),
            Text('System alerts will appear here.',
                style: Theme.of(context).textTheme.bodySmall),
          ])),
        ),
      );
}

class _NotificationCard extends StatelessWidget {
  final AdminNotificationItem notification;
  final VoidCallback onMarkRead;
  const _NotificationCard({required this.notification, required this.onMarkRead});

  Color get _color => switch (notification.ntype) {
        'error' => AppColors.error,
        'warning' => AppColors.warning,
        'success' => AppColors.success,
        _ => AppColors.info,
      };

  IconData get _icon => switch (notification.ntype) {
        'error' => Icons.error_rounded,
        'warning' => Icons.warning_rounded,
        'success' => Icons.check_circle_rounded,
        _ => Icons.info_rounded,
      };

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: notification.isRead ? null : onMarkRead,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icon, color: _color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(notification.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: notification.isRead
                              ? FontWeight.w500 : FontWeight.w700))),
                  if (notification.module != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(notification.module!,
                          style: const TextStyle(fontSize: 10,
                              fontWeight: FontWeight.w600, color: AppColors.accent)),
                    ),
                ]),
                const SizedBox(height: 4),
                Text(notification.message,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppColors.lightTextMuted)),
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.access_time_rounded, size: 11, color: AppColors.lightTextLight),
                  const SizedBox(width: 4),
                  Text(DateFormat('MMM d, HH:mm').format(notification.createdAt),
                      style: Theme.of(context).textTheme.labelSmall),
                  if (!notification.isRead) ...[
                    const Spacer(),
                    Container(width: 8, height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('Unread', style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ],
                ]),
              ])),
            ]),
          ),
        ),
      );
}
