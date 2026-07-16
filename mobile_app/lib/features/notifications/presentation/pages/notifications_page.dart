import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../data/models/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = ref.read(notificationProvider);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !state.isLoading &&
        state.hasMore) {
      ref.read(notificationProvider.notifier).load(refresh: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Row(children: [
          Text('🔔', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Text('Notifications',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.textStrong)),
        ]),
        actions: [
          if (state.unreadCount > 0)
            TextButton.icon(
              onPressed: notifier.markAllRead,
              icon: const Icon(Icons.done_all_rounded, size: 16,
                  color: DesignTokens.primary),
              label: const Text('Mark all read',
                  style: TextStyle(
                      color: DesignTokens.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: () => notifier.load(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: DesignTokens.primary,
        backgroundColor: DesignTokens.surface,
        onRefresh: () => notifier.load(),
        child: _buildBody(context, state, notifier),
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotificationState state,
      NotificationNotifier notifier) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: DesignTokens.primary));
    }

    if (state.error != null && state.notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(state.error!, textAlign: TextAlign.center,
                style: const TextStyle(
                    color: DesignTokens.textMuted, fontSize: 15)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => notifier.load(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                  backgroundColor: DesignTokens.primary),
            ),
          ]),
        ),
      );
    }

    if (state.notifications.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: DesignTokens.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
                child: Text('🔔', style: TextStyle(fontSize: 36))),
          ).animate().scale(
              begin: const Offset(0.7, 0.7),
              duration: 500.ms,
              curve: Curves.elasticOut),
          const SizedBox(height: 20),
          const Text('All caught up!',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.textStrong)),
          const SizedBox(height: 8),
          const Text('No notifications yet.',
              style: TextStyle(color: DesignTokens.textMuted, fontSize: 14)),
        ]),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.notifications.length + (state.isLoading ? 1 : 0),
      itemBuilder: (ctx, i) {
        if (i == state.notifications.length) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(
                strokeWidth: 2, color: DesignTokens.primary),
          ));
        }
        final n = state.notifications[i];
        return _NotificationCard(
          item: n,
          index: i,
          onMarkRead: () => notifier.markRead(n.id),
          onDelete: () => notifier.deleteNotification(n.id),
        );
      },
    );
  }
}

// ── Notification card ─────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final NotificationModel item;
  final int index;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.item,
    required this.index,
    required this.onMarkRead,
    required this.onDelete,
  });

  Color get _typeColor => switch (item.ntype) {
        'warning' => DesignTokens.warning,
        'alert'   => DesignTokens.danger,
        'success' => DesignTokens.success,
        _         => DesignTokens.info,
      };

  IconData get _typeIcon => switch (item.ntype) {
        'warning' => Icons.warning_rounded,
        'alert'   => Icons.error_rounded,
        'success' => Icons.check_circle_rounded,
        _         => Icons.info_rounded,
      };

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    if (diff.inDays < 7)     return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: DesignTokens.danger,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.delete_rounded, color: Colors.white, size: 24),
          SizedBox(height: 4),
          Text('Delete', style: TextStyle(color: Colors.white, fontSize: 11)),
        ]),
      ),
      confirmDismiss: (_) async => true,
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: item.isRead ? null : onMarkRead,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: item.isRead
                ? DesignTokens.surface
                : _typeColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: item.isRead
                  ? DesignTokens.border
                  : _typeColor.withValues(alpha: 0.3),
              width: item.isRead ? 1 : 1.5,
            ),
            boxShadow: item.isRead
                ? []
                : [
                    BoxShadow(
                      color: _typeColor.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_typeIcon, color: _typeColor, size: 22),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: item.isRead
                                ? FontWeight.w600
                                : FontWeight.w800,
                            color: DesignTokens.textStrong,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8, top: 4),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: _typeColor),
                        ),
                    ]),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: TextStyle(
                        fontSize: 13,
                        color: item.isRead
                            ? DesignTokens.textMuted
                            : DesignTokens.textStrong.withValues(alpha: 0.8),
                        height: 1.45,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      if (item.module != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: DesignTokens.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.module!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: DesignTokens.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        _timeAgo(item.createdAt),
                        style: const TextStyle(
                            fontSize: 11, color: DesignTokens.textSubtle),
                      ),
                      if (!item.isRead) ...[
                        const Spacer(),
                        GestureDetector(
                          onTap: onMarkRead,
                          child: const Text(
                            'Mark read',
                            style: TextStyle(
                              fontSize: 11,
                              color: DesignTokens.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ).animate(delay: Duration(milliseconds: index * 40))
            .fadeIn(duration: 300.ms)
            .slideX(begin: 0.05, end: 0),
      ),
    );
  }
}
