import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api.dart';
import '../../core/models.dart';

// ── Stats model ───────────────────────────────────────────────────────────────

class ChatbotStats {
  final int totalConversations;
  final int activeConversations;
  final int totalMessages;
  final int emergencyMessages;
  final double avgMessages;
  final int todayConversations;
  final Map<String, int> languageDistribution;

  const ChatbotStats({
    this.totalConversations = 0,
    this.activeConversations = 0,
    this.totalMessages = 0,
    this.emergencyMessages = 0,
    this.avgMessages = 0,
    this.todayConversations = 0,
    this.languageDistribution = const {},
  });

  factory ChatbotStats.fromJson(Map<String, dynamic> j) => ChatbotStats(
        totalConversations: j['total_conversations'] as int? ?? 0,
        activeConversations: j['active_conversations'] as int? ?? 0,
        totalMessages: j['total_messages'] as int? ?? 0,
        emergencyMessages: j['emergency_messages'] as int? ?? 0,
        avgMessages:
            (j['avg_messages_per_conversation'] as num?)?.toDouble() ?? 0.0,
        todayConversations: j['today_conversations'] as int? ?? 0,
        languageDistribution: (j['language_distribution']
                    as Map<String, dynamic>? ??
                {})
            .map((k, v) => MapEntry(k, (v as num).toInt())),
      );
}

// ── State ─────────────────────────────────────────────────────────────────────

class ChatbotState {
  final bool isLoading;
  final bool isLoadingStats;
  final String? error;
  final List<ChatConversation> conversations;
  final ChatbotStats stats;
  final Map<String, dynamic>? config;
  final int total;
  final int page;
  final int pageSize;
  final String search;
  final String? languageFilter;
  final bool? hasEmergencyFilter;

  const ChatbotState({
    this.isLoading = false,
    this.isLoadingStats = false,
    this.error,
    this.conversations = const [],
    this.stats = const ChatbotStats(),
    this.config,
    this.total = 0,
    this.page = 1,
    this.pageSize = 20,
    this.search = '',
    this.languageFilter,
    this.hasEmergencyFilter,
  });

  int get totalPages => (total / pageSize).ceil().clamp(1, 9999);

  ChatbotState copyWith({
    bool? isLoading,
    bool? isLoadingStats,
    String? error,
    bool clearError = false,
    List<ChatConversation>? conversations,
    ChatbotStats? stats,
    Map<String, dynamic>? config,
    int? total,
    int? page,
    String? search,
    String? languageFilter,
    bool? hasEmergencyFilter,
    bool clearLanguage = false,
    bool clearEmergency = false,
  }) =>
      ChatbotState(
        isLoading: isLoading ?? this.isLoading,
        isLoadingStats: isLoadingStats ?? this.isLoadingStats,
        error: clearError ? null : (error ?? this.error),
        conversations: conversations ?? this.conversations,
        stats: stats ?? this.stats,
        config: config ?? this.config,
        total: total ?? this.total,
        page: page ?? this.page,
        pageSize: pageSize,
        search: search ?? this.search,
        languageFilter:
            clearLanguage ? null : (languageFilter ?? this.languageFilter),
        hasEmergencyFilter: clearEmergency
            ? null
            : (hasEmergencyFilter ?? this.hasEmergencyFilter),
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class ChatbotNotifier extends StateNotifier<ChatbotState> {
  ChatbotNotifier() : super(const ChatbotState()) {
    loadStats();
    loadConversations();
  }

  Future<void> loadStats() async {
    state = state.copyWith(isLoadingStats: true);
    try {
      final resp =
          await ApiClient.instance.get('/admin/chatbot/stats');
      state = state.copyWith(
        isLoadingStats: false,
        stats: ChatbotStats.fromJson(resp.data as Map<String, dynamic>),
      );
    } catch (e) {
      state = state.copyWith(
          isLoadingStats: false, error: errorMessage(e));
    }
  }

  Future<void> loadConversations({int? page}) async {
    state = state.copyWith(
        isLoading: true, clearError: true, page: page ?? state.page);
    try {
      final params = <String, dynamic>{
        'page': state.page,
        'page_size': state.pageSize,
      };
      if (state.search.isNotEmpty) params['search'] = state.search;
      if (state.languageFilter != null)
        params['language'] = state.languageFilter;
      if (state.hasEmergencyFilter != null)
        params['has_emergency'] = state.hasEmergencyFilter;

      final resp = await ApiClient.instance
          .get('/admin/chatbot/conversations', queryParameters: params);
      final data = resp.data as Map<String, dynamic>;

      state = state.copyWith(
        isLoading: false,
        clearError: true,
        conversations: (data['conversations'] as List)
            .cast<Map<String, dynamic>>()
            .map(ChatConversation.fromJson)
            .toList(),
        total: data['total'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  Future<void> loadConfig() async {
    try {
      final resp =
          await ApiClient.instance.get('/admin/chatbot/config');
      state = state.copyWith(config: resp.data as Map<String, dynamic>);
    } catch (e) {
      state = state.copyWith(error: errorMessage(e));
    }
  }

  Future<bool> deleteConversation(int conversationId) async {
    try {
      await ApiClient.instance
          .delete('/admin/chatbot/conversations/$conversationId');
      loadConversations(page: state.page);
      return true;
    } catch (e) {
      state = state.copyWith(error: errorMessage(e));
      return false;
    }
  }

  void setSearch(String v) {
    state = state.copyWith(search: v, page: 1);
    loadConversations();
  }

  void setLanguageFilter(String? v) {
    state = v == null
        ? state.copyWith(clearLanguage: true, page: 1)
        : state.copyWith(languageFilter: v, page: 1);
    loadConversations();
  }

  void setEmergencyFilter(bool? v) {
    state = v == null
        ? state.copyWith(clearEmergency: true, page: 1)
        : state.copyWith(hasEmergencyFilter: v, page: 1);
    loadConversations();
  }

  void goToPage(int p) => loadConversations(page: p);

  /// Persist chatbot config changes via PUT /admin/chatbot/config
  Future<bool> updateConfig(Map<String, dynamic> updates) async {
    try {
      await ApiClient.instance.put('/admin/chatbot/config', data: updates);
      // Reload config to reflect saved values
      await loadConfig();
      return true;
    } catch (e) {
      state = state.copyWith(error: errorMessage(e));
      return false;
    }
  }
}

final chatbotProvider =
    StateNotifierProvider<ChatbotNotifier, ChatbotState>(
        (ref) => ChatbotNotifier());
