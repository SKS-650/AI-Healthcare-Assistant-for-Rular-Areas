import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/conversation.dart';
import '../providers/chatbot_provider.dart';
import 'chat_page.dart';

class ChatHistoryPage extends ConsumerStatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  ConsumerState<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends ConsumerState<ChatHistoryPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state      = ref.watch(chatbotControllerProvider);
    final controller = ref.read(chatbotControllerProvider.notifier);

    final history = state.history
        .where((c) =>
            _query.isEmpty ||
            c.title.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    // Group conversations by date
    final grouped = _groupByDate(history);

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: DesignTokens.textStrong, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Chat History',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: DesignTokens.textStrong,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_rounded,
                color: DesignTokens.primary, size: 22),
            tooltip: 'New chat',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ChatPage()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _SearchBar(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
      ),
      body: history.isEmpty
          ? _EmptyHistory(query: _query)
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: grouped.keys.length,
              itemBuilder: (context, sectionIndex) {
                final label = grouped.keys.elementAt(sectionIndex);
                final conversations = grouped[label]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DateHeader(label: label),
                    ...conversations.map(
                      (conv) => _ConversationTile(
                        conversation: conv,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChatPage(),
                            ),
                          );
                        },
                        onDelete: () => _confirmDelete(
                          context, conv, controller,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Map<String, List<Conversation>> _groupByDate(List<Conversation> convs) {
    final result = <String, List<Conversation>>{};
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final c in convs) {
      final d = DateTime(
          c.updatedAt.year, c.updatedAt.month, c.updatedAt.day);
      final String label;
      if (d == today) {
        label = 'Today';
      } else if (d == yesterday) {
        label = 'Yesterday';
      } else if (now.difference(d).inDays < 7) {
        label = DateFormat('EEEE').format(c.updatedAt); // e.g. "Monday"
      } else {
        label = DateFormat('MMMM d, y').format(c.updatedAt);
      }
      result.putIfAbsent(label, () => []).add(c);
    }
    return result;
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Conversation conv,
    dynamic controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: DesignTokens.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete chat?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
          'This will permanently delete "${conv.title}".',
          style: const TextStyle(color: DesignTokens.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: DesignTokens.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      controller.deleteConversation(conv.id);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: DesignTokens.surfaceMuted,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: DesignTokens.border),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14, color: DesignTokens.textStrong),
          decoration: const InputDecoration(
            hintText: 'Search conversations…',
            hintStyle: TextStyle(color: DesignTokens.textSubtle, fontSize: 13),
            prefixIcon: Icon(Icons.search_rounded,
                size: 18, color: DesignTokens.textMuted),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final String label;
  const _DateHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: DesignTokens.textMuted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _ConversationTile({
    required this.conversation,
    required this.onTap,
    required this.onDelete,
  });

  String get _preview {
    if (conversation.messages.isEmpty) return 'No messages yet';
    final last = conversation.messages.last;
    return last.text.length > 80
        ? '${last.text.substring(0, 77)}…'
        : last.text;
  }

  String get _time =>
      DateFormat('h:mm a').format(conversation.updatedAt);

  int get _msgCount => conversation.messages.length;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: DesignTokens.danger,
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: DesignTokens.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: DesignTokens.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [DesignTokens.primary, DesignTokens.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('💬', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: DesignTokens.textStrong,
                            ),
                          ),
                        ),
                        Text(
                          _time,
                          style: const TextStyle(
                              fontSize: 11, color: DesignTokens.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: DesignTokens.textMuted),
                          ),
                        ),
                        if (_msgCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: DesignTokens.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$_msgCount',
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: DesignTokens.primaryDark),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: DesignTokens.textSubtle),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  final String query;
  const _EmptyHistory({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              query.isEmpty ? '🗂️' : '🔍',
              style: const TextStyle(fontSize: 52),
            ),
            const SizedBox(height: 16),
            Text(
              query.isEmpty
                  ? 'No conversations yet'
                  : 'No results for "$query"',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: DesignTokens.textStrong,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              query.isEmpty
                  ? 'Start a chat to see your history here.'
                  : 'Try a different search term.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: DesignTokens.textMuted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
