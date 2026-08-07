import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class FeedbackItem {
  final String id;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final String category;
  final int? rating;
  final String? title;
  final String message;
  final String? module;
  final String status;
  final String priority;
  final String? adminNotes;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final String? appVersion;
  final String? platform;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FeedbackItem({
    required this.id,
    this.userId,
    this.userName,
    this.userEmail,
    required this.category,
    this.rating,
    this.title,
    required this.message,
    this.module,
    required this.status,
    required this.priority,
    this.adminNotes,
    this.resolvedBy,
    this.resolvedAt,
    this.appVersion,
    this.platform,
    required this.isAnonymous,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeedbackItem.fromJson(Map<String, dynamic> j) => FeedbackItem(
        id: j['id'] as String,
        userId: j['user_id'] as String?,
        userName: j['user_name'] as String?,
        userEmail: j['user_email'] as String?,
        category: j['category'] as String? ?? 'general',
        rating: j['rating'] as int?,
        title: j['title'] as String?,
        message: j['message'] as String,
        module: j['module'] as String?,
        status: j['status'] as String? ?? 'pending',
        priority: j['priority'] as String? ?? 'normal',
        adminNotes: j['admin_notes'] as String?,
        resolvedBy: j['resolved_by'] as String?,
        resolvedAt: j['resolved_at'] != null
            ? DateTime.tryParse(j['resolved_at'] as String)
            : null,
        appVersion: j['app_version'] as String?,
        platform: j['platform'] as String?,
        isAnonymous: j['is_anonymous'] as bool? ?? false,
        createdAt: DateTime.parse(j['created_at'] as String),
        updatedAt: DateTime.parse(j['updated_at'] as String),
      );
}

class FeedbackStats {
  final int total;
  final int pending;
  final int reviewed;
  final int inProgress;
  final int resolved;
  final int dismissed;
  final double avgRating;
  final int todayCount;
  final int thisWeekCount;
  final Map<String, int> byCategory;
  final Map<String, int> byPriority;

  const FeedbackStats({
    this.total = 0,
    this.pending = 0,
    this.reviewed = 0,
    this.inProgress = 0,
    this.resolved = 0,
    this.dismissed = 0,
    this.avgRating = 0.0,
    this.todayCount = 0,
    this.thisWeekCount = 0,
    this.byCategory = const {},
    this.byPriority = const {},
  });

  factory FeedbackStats.fromJson(Map<String, dynamic> j) => FeedbackStats(
        total: j['total'] as int? ?? 0,
        pending: j['pending'] as int? ?? 0,
        reviewed: j['reviewed'] as int? ?? 0,
        inProgress: j['in_progress'] as int? ?? 0,
        resolved: j['resolved'] as int? ?? 0,
        dismissed: j['dismissed'] as int? ?? 0,
        avgRating: (j['avg_rating'] as num?)?.toDouble() ?? 0.0,
        todayCount: j['today_count'] as int? ?? 0,
        thisWeekCount: j['this_week_count'] as int? ?? 0,
        byCategory: (j['by_category'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v as int)) ??
            {},
        byPriority: (j['by_priority'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v as int)) ??
            {},
      );

  static FeedbackStats get empty => const FeedbackStats();
}

// ── State ─────────────────────────────────────────────────────────────────────

class FeedbackState {
  final bool isLoading;
  final String? error;
  final List<FeedbackItem> items;
  final FeedbackStats stats;
  final int total;
  final int page;
  final int pageSize;
  // filters
  final String search;
  final String? categoryFilter;
  final String? statusFilter;
  final String? priorityFilter;
  final int? ratingFilter;

  const FeedbackState({
    this.isLoading = false,
    this.error,
    this.items = const [],
    this.stats = const FeedbackStats(),
    this.total = 0,
    this.page = 1,
    this.pageSize = 20,
    this.search = '',
    this.categoryFilter,
    this.statusFilter,
    this.priorityFilter,
    this.ratingFilter,
  });

  int get totalPages => (total / pageSize).ceil().clamp(1, 9999);

  FeedbackState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<FeedbackItem>? items,
    FeedbackStats? stats,
    int? total,
    int? page,
    String? search,
    String? categoryFilter,
    String? statusFilter,
    String? priorityFilter,
    int? ratingFilter,
    bool clearCategory = false,
    bool clearStatus = false,
    bool clearPriority = false,
    bool clearRating = false,
  }) =>
      FeedbackState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        items: items ?? this.items,
        stats: stats ?? this.stats,
        total: total ?? this.total,
        page: page ?? this.page,
        pageSize: this.pageSize,
        search: search ?? this.search,
        categoryFilter: clearCategory ? null : (categoryFilter ?? this.categoryFilter),
        statusFilter: clearStatus ? null : (statusFilter ?? this.statusFilter),
        priorityFilter: clearPriority ? null : (priorityFilter ?? this.priorityFilter),
        ratingFilter: clearRating ? null : (ratingFilter ?? this.ratingFilter),
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class FeedbackNotifier extends StateNotifier<FeedbackState> {
  FeedbackNotifier() : super(const FeedbackState()) {
    loadStats();
    loadFeedback();
  }

  Future<void> loadStats() async {
    try {
      final resp = await ApiClient.instance.get('/admin/feedback/stats');
      final stats = FeedbackStats.fromJson(resp.data as Map<String, dynamic>);
      state = state.copyWith(stats: stats);
    } catch (_) {}
  }

  Future<void> loadFeedback({int? page}) async {
    state = state.copyWith(isLoading: true, clearError: true, page: page ?? state.page);
    try {
      final params = <String, dynamic>{
        'page': state.page,
        'page_size': state.pageSize,
      };
      if (state.search.isNotEmpty) params['search'] = state.search;
      if (state.categoryFilter != null) params['category'] = state.categoryFilter;
      if (state.statusFilter != null) params['status'] = state.statusFilter;
      if (state.priorityFilter != null) params['priority'] = state.priorityFilter;
      if (state.ratingFilter != null) params['rating'] = state.ratingFilter;

      final resp = await ApiClient.instance.get(
        '/admin/feedback',
        queryParameters: params,
      );
      final data = resp.data as Map<String, dynamic>;
      final items = (data['feedback'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(FeedbackItem.fromJson)
          .toList();

      state = state.copyWith(
        isLoading: false,
        clearError: true,
        items: items,
        total: data['total'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  void setSearch(String v) {
    state = state.copyWith(search: v, page: 1);
    loadFeedback();
  }

  void setCategoryFilter(String? v) {
    state = v == null
        ? state.copyWith(clearCategory: true, page: 1)
        : state.copyWith(categoryFilter: v, page: 1);
    loadFeedback();
  }

  void setStatusFilter(String? v) {
    state = v == null
        ? state.copyWith(clearStatus: true, page: 1)
        : state.copyWith(statusFilter: v, page: 1);
    loadFeedback();
  }

  void setPriorityFilter(String? v) {
    state = v == null
        ? state.copyWith(clearPriority: true, page: 1)
        : state.copyWith(priorityFilter: v, page: 1);
    loadFeedback();
  }

  void setRatingFilter(int? v) {
    state = v == null
        ? state.copyWith(clearRating: true, page: 1)
        : state.copyWith(ratingFilter: v, page: 1);
    loadFeedback();
  }

  void goToPage(int p) => loadFeedback(page: p);

  /// Update status, priority, or admin notes for a single feedback item.
  Future<bool> updateFeedback(
    String feedbackId, {
    String? status,
    String? priority,
    String? adminNotes,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (status != null) body['status'] = status;
      if (priority != null) body['priority'] = priority;
      if (adminNotes != null) body['admin_notes'] = adminNotes;

      await ApiClient.instance.patch('/admin/feedback/$feedbackId', data: body);
      await loadFeedback();
      await loadStats();
      return true;
    } catch (e) {
      state = state.copyWith(error: errorMessage(e));
      return false;
    }
  }

  Future<bool> deleteFeedback(String feedbackId) async {
    try {
      await ApiClient.instance.delete('/admin/feedback/$feedbackId');
      await loadFeedback();
      await loadStats();
      return true;
    } catch (e) {
      state = state.copyWith(error: errorMessage(e));
      return false;
    }
  }

  void reload() {
    loadStats();
    loadFeedback();
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final feedbackProvider =
    StateNotifierProvider<FeedbackNotifier, FeedbackState>(
        (ref) => FeedbackNotifier());
