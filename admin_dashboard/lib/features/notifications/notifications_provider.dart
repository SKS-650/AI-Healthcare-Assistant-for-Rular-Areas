import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class AdminNotificationItem {
  final String id;
  final String title;
  final String message;
  final String ntype;
  final String? module;
  final bool isRead;
  final DateTime createdAt;

  const AdminNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.ntype,
    this.module,
    required this.isRead,
    required this.createdAt,
  });

  factory AdminNotificationItem.fromJson(Map<String, dynamic> j) =>
      AdminNotificationItem(
        id: j['id'] as String,
        title: j['title'] as String,
        message: j['message'] as String,
        ntype: j['ntype'] as String? ?? 'info',
        module: j['module'] as String?,
        isRead: j['is_read'] as bool? ?? false,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  AdminNotificationItem copyWith({bool? isRead}) => AdminNotificationItem(
        id: id,
        title: title,
        message: message,
        ntype: ntype,
        module: module,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );
}

// ── State ─────────────────────────────────────────────────────────────────────

class NotificationsState {
  final bool isLoading;
  final String? error;
  final List<AdminNotificationItem> notifications;
  final int unreadCount;

  const NotificationsState({
    this.isLoading = false,
    this.error,
    this.notifications = const [],
    this.unreadCount = 0,
  });

  List<AdminNotificationItem> get unread =>
      notifications.where((n) => !n.isRead).toList();

  NotificationsState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<AdminNotificationItem>? notifications,
    int? unreadCount,
  }) =>
      NotificationsState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        notifications: notifications ?? this.notifications,
        unreadCount: unreadCount ?? this.unreadCount,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier() : super(const NotificationsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final resp = await ApiClient.instance.get('/admin/notifications');
      final data = resp.data as Map<String, dynamic>;
      state = state.copyWith(
        isLoading: false,
        notifications: (data['notifications'] as List)
            .cast<Map<String, dynamic>>()
            .map(AdminNotificationItem.fromJson)
            .toList(),
        unreadCount: data['unread_count'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await ApiClient.instance
          .patch('/admin/notifications/$notificationId/read', data: {});
      final updated = state.notifications.map((n) {
        if (n.id == notificationId && !n.isRead) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      final newUnread =
          updated.where((n) => !n.isRead).length;
      state = state.copyWith(
          notifications: updated, unreadCount: newUnread);
    } catch (e) {
      state = state.copyWith(error: errorMessage(e));
    }
  }

  Future<void> markAllAsRead() async {
    final unread = state.notifications.where((n) => !n.isRead).toList();
    for (final n in unread) {
      await markAsRead(n.id);
    }
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>(
        (ref) => NotificationsNotifier());
