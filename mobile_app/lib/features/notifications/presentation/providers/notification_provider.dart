import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../config/api_config.dart';
import '../../../authentication/presentation/providers/authentication_provider.dart';
import '../../data/models/notification_model.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class NotificationState {
  final bool isLoading;
  final List<NotificationModel> notifications;
  final int unreadCount;
  final int total;
  final int page;
  final String? error;

  const NotificationState({
    this.isLoading = false,
    this.notifications = const [],
    this.unreadCount = 0,
    this.total = 0,
    this.page = 1,
    this.error,
  });

  bool get hasMore => notifications.length < total;

  NotificationState copyWith({
    bool? isLoading,
    List<NotificationModel>? notifications,
    int? unreadCount,
    int? total,
    int? page,
    String? error,
    bool clearError = false,
  }) =>
      NotificationState(
        isLoading:     isLoading     ?? this.isLoading,
        notifications: notifications ?? this.notifications,
        unreadCount:   unreadCount   ?? this.unreadCount,
        total:         total         ?? this.total,
        page:          page          ?? this.page,
        error:         clearError ? null : (error ?? this.error),
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class NotificationNotifier extends StateNotifier<NotificationState> {
  final Ref _ref;

  NotificationNotifier(this._ref) : super(const NotificationState()) {
    load();
  }

  String? get _token {
    try {
      return _ref.read(authRepositoryProvider).accessToken;
    } catch (_) {
      return null;
    }
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<void> load({bool refresh = true}) async {
    if (state.isLoading) return;
    final page = refresh ? 1 : state.page + 1;
    state = state.copyWith(isLoading: true, clearError: true, page: page);

    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/v1/notifications/?page=$page&page_size=20',
      );
      final resp = await http.get(uri, headers: _headers);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final items = (data['notifications'] as List)
            .cast<Map<String, dynamic>>()
            .map(NotificationModel.fromJson)
            .toList();

        state = state.copyWith(
          isLoading: false,
          notifications: refresh ? items : [...state.notifications, ...items],
          unreadCount: data['unread_count'] as int? ?? 0,
          total:       data['total']        as int? ?? 0,
        );
      } else if (resp.statusCode == 401) {
        state = state.copyWith(
            isLoading: false, error: 'Session expired. Please log in again.');
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markRead(String notificationId) async {
    try {
      await http.post(
        Uri.parse(
            '${ApiConfig.baseUrl}/api/v1/notifications/mark-read'),
        headers: _headers,
        body: jsonEncode({'notification_ids': [notificationId]}),
      );
      // Optimistically update local state
      state = state.copyWith(
        notifications: state.notifications
            .map((n) => n.id == notificationId
                ? NotificationModel(
                    id:          n.id,
                    userId:      n.userId,
                    title:       n.title,
                    body:        n.body,
                    ntype:       n.ntype,
                    module:      n.module,
                    referenceId: n.referenceId,
                    isRead:      true,
                    createdAt:   n.createdAt,
                  )
                : n)
            .toList(),
        unreadCount:
            (state.unreadCount - 1).clamp(0, state.unreadCount),
      );
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await http.post(
        Uri.parse(
            '${ApiConfig.baseUrl}/api/v1/notifications/mark-all-read'),
        headers: _headers,
      );
      state = state.copyWith(
        notifications: state.notifications
            .map((n) => NotificationModel(
                  id:          n.id,
                  userId:      n.userId,
                  title:       n.title,
                  body:        n.body,
                  ntype:       n.ntype,
                  module:      n.module,
                  referenceId: n.referenceId,
                  isRead:      true,
                  createdAt:   n.createdAt,
                ))
            .toList(),
        unreadCount: 0,
      );
    } catch (_) {}
  }

  Future<void> deleteNotification(String id) async {
    try {
      await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/notifications/$id'),
        headers: _headers,
      );
      state = state.copyWith(
        notifications:
            state.notifications.where((n) => n.id != id).toList(),
        total: (state.total - 1).clamp(0, state.total),
      );
    } catch (_) {}
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>(
  (ref) => NotificationNotifier(ref),
);

// Convenience: unread badge count only
final unreadNotificationCountProvider = Provider<int>(
  (ref) => ref.watch(notificationProvider).unreadCount,
);
