import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/api.dart';
import '../../core/models.dart';
import '../../core/theme.dart';
import '../../shared/widgets/chart_card.dart';
import '../../shared/widgets/data_table_card.dart';
import '../../shared/widgets/stat_card.dart';

// ── Provider ──────────────────────────────────────────────────────────────────
class _ChatbotStats {
  final int totalConversations, activeConversations, totalMessages,
      emergencyMessages, todayConversations;
  final double avgMessages;
  final Map<String, int> langDistribution;
  const _ChatbotStats({
    this.totalConversations = 0, this.activeConversations = 0,
    this.totalMessages = 0, this.emergencyMessages = 0,
    this.todayConversations = 0, this.avgMessages = 0.0,
    this.langDistribution = const {},
  });
  factory _ChatbotStats.fromJson(Map<String, dynamic> j) => _ChatbotStats(
    totalConversations: j['total_conversations'] as int? ?? 0,
    activeConversations: j['active_conversations'] as int? ?? 0,
    totalMessages: j['total_messages'] as int? ?? 0,
    emergencyMessages: j['emergency_messages'] as int? ?? 0,
    todayConversations: j['today_conversations'] as int? ?? 0,
    avgMessages: (j['avg_messages_per_conversation'] as num?)?.toDouble() ?? 0.0,
    langDistribution: Map<String, int>.from(j['language_distribution'] as Map? ?? {}),
  );
}

class _ChatbotState {
  final bool isLoading; final String? error;
  final _ChatbotStats stats;
  final List<ChatConversation> conversations;
  final int total, page;
  const _ChatbotState({
    this.isLoading = false, this.error, this.stats = const _ChatbotStats(),
    this.conversations = const [], this.total = 0, this.page = 1,
  });
}

class _ChatbotNotifier extends StateNotifier<_ChatbotState> {
  _ChatbotNotifier() : super(const _ChatbotState()) { load(); }
  Future<void> load({int page = 1}) async {
    state = _ChatbotState(isLoading: true, stats: state.stats, page: page);
    try {
      final results = await Future.wait([
        ApiClient.instance.get('/admin/chatbot/conversations', queryParameters: {'page': page, 'page_size': 20}),
        ApiClient.instance.get('/admin/chatbot/stats'),
      ]);
      final data = results[0].data as Map<String, dynamic>;
      final statsData = results[1].data as Map<String, dynamic>;
      state = _ChatbotState(
        stats: _ChatbotStats.fromJson(statsData),
        conversations: (data['conversations'] as List).cast<Map<String, dynamic>>().map(ChatConversation.fromJson).toList(),
        total: data['total'] as int? ?? 0, page: page,
      );
    } catch (e) {
      state = _ChatbotState(error: ApiResult.fromError(e).error);
    }
  }
}

final _chatbotProvider = StateNotifierProvider<_ChatbotNotifier, _ChatbotState>((ref) => _ChatbotNotifier());

// ── Page ──────────────────────────────────────────────────────────────────────
class ChatbotPage extends ConsumerWidget {
  const ChatbotPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_chatbotProvider);
    final s = state.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Chatbot Monitoring', style: Theme.of(context).textTheme.headlineMedium
            ?.copyWith(fontWeight: FontWeight.w700)).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 4),
        Text('Monitor all chatbot conversations and analytics',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.lightTextMuted))
            .animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 24),

        // Stats
        LayoutBuilder(builder: (ctx, cst) {
          final cols = cst.maxWidth > 900 ? 4 : 2;
          return GridView.count(
            crossAxisCount: cols, crossAxisSpacing: 16, mainAxisSpacing: 16,
            childAspectRatio: 1.6, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            children: [
              StatCard(title: 'Total Conversations', value: '${s.totalConversations}',
                  icon: Icons.chat_bubble_rounded, color: AppColors.accent, animDelay: 0),
              StatCard(title: 'Total Messages', value: '${s.totalMessages}',
                  icon: Icons.message_rounded, color: AppColors.primary, animDelay: 80),
              StatCard(title: 'Emergency Detected', value: '${s.emergencyMessages}',
                  subtitle: 'Messages with emergency flag',
                  icon: Icons.warning_rounded, color: AppColors.error, animDelay: 160),
              StatCard(title: 'Avg Messages', value: s.avgMessages.toStringAsFixed(1),
                  subtitle: 'Per conversation',
                  icon: Icons.analytics_rounded, color: AppColors.info, animDelay: 240),
            ],
          );
        }),
        const SizedBox(height: 24),

        // Language distribution
        if (s.langDistribution.isNotEmpty)
          DonutChartCard(
            title: 'Language Distribution',
            slices: s.langDistribution.entries.toList().asMap().entries.map((e) =>
              PieSlice(
                label: e.value.key.toUpperCase(),
                value: e.value.value,
                color: AppColors.chartPalette[e.key % AppColors.chartPalette.length],
              )
            ).toList(),
            animDelay: 200,
          ),
        const SizedBox(height: 24),

        // Conversations table
        DataTableCard(
          title: 'Recent Conversations',
          isLoading: state.isLoading,
          totalRows: state.total, currentPage: state.page, pageSize: 20,
          onPageChanged: (p) => ref.read(_chatbotProvider.notifier).load(page: p),
          columns: const [
            DataColumn(label: Text('User')),
            DataColumn(label: Text('Title')),
            DataColumn(label: Text('Language')),
            DataColumn(label: Text('Messages')),
            DataColumn(label: Text('Emergency')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Date')),
          ],
          rows: state.conversations.map((c) => DataRow(
            color: WidgetStateProperty.resolveWith((_) =>
                c.emergencyCount > 0 ? AppColors.errorSurface.withOpacity(0.5) : null),
            cells: [
              DataCell(Text(c.userName ?? 'Anonymous', style: Theme.of(context).textTheme.bodyMedium)),
              DataCell(SizedBox(width: 200, child: Text(c.title,
                  style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis))),
              DataCell(Text(c.language.toUpperCase(), style: Theme.of(context).textTheme.bodySmall)),
              DataCell(Text('${c.messageCount}', style: Theme.of(context).textTheme.bodyMedium)),
              DataCell(c.emergencyCount > 0
                  ? Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.errorSurface, borderRadius: BorderRadius.circular(6)),
                      child: Text('${c.emergencyCount} ⚠️', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.error)))
                  : const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.success)),
              DataCell(StatusBadge(active: c.isActive, activeLabel: 'Active', inactiveLabel: 'Closed')),
              DataCell(Text(DateFormat('MMM d').format(c.createdAt), style: Theme.of(context).textTheme.bodySmall)),
            ],
          )).toList(),
        ).animate().fadeIn(delay: 300.ms),
      ]),
    );
  }
}
