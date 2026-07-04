import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../providers/chatbot_provider.dart';
import 'chat_page.dart';

class ConversationHistoryPage extends ConsumerWidget {
  const ConversationHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatbotControllerProvider);

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        foregroundColor: const Color(0xFF1A1035),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: DesignTokens.textStrong, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          children: [
            Text('ðŸ—‚ï¸', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text('Chat History'),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: DesignTokens.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: DesignTokens.border),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 20),
              onPressed: () =>
                  ref.read(chatbotControllerProvider.notifier).refreshHistory(),
            ),
          ),
        ],
      ),
      body: state.history.isEmpty
          ? _EmptyHistory(
              onStart: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChatPage()),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final convo = state.history[index];
                final lastMsg = convo.messages.isNotEmpty
                    ? convo.messages.last.text
                    : 'No messages';
                final msgCount = convo.messages.length;

                return _ConvoCard(
                  title: convo.title.isNotEmpty ? convo.title : 'Conversation ${index + 1}',
                  preview: lastMsg,
                  messageCount: msgCount,
                  updatedAt: convo.updatedAt,
                  index: index,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChatPage()),
                  ),
                );
              },
            ),
    );
  }
}

class _ConvoCard extends StatelessWidget {
  final String title;
  final String preview;
  final int messageCount;
  final DateTime updatedAt;
  final int index;
  final VoidCallback onTap;

  const _ConvoCard({
    required this.title,
    required this.preview,
    required this.messageCount,
    required this.updatedAt,
    required this.index,
    required this.onTap,
  });

  static const _gradients = [
    [Color(0xFF0D9488), Color(0xFF2563EB)],
    [Color(0xFF7C3AED), Color(0xFF0D9488)],
    [Color(0xFF2563EB), Color(0xFF0891B2)],
    [Color(0xFF0891B2), Color(0xFF10B981)],
  ];

  @override
  Widget build(BuildContext context) {
    final grad = _gradients[index % _gradients.length];
    final timeStr = _formatTime(updatedAt);

    return Material(
      color: DesignTokens.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: DesignTokens.border),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: grad,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('ðŸ’¬', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: DesignTokens.textStrong,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: DesignTokens.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeStr,
                    style: const TextStyle(
                      color: DesignTokens.textSubtle,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: DesignTokens.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$messageCount ðŸ’¬',
                      style: const TextStyle(
                        color: DesignTokens.primaryDark,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _EmptyHistory extends StatelessWidget {
  final VoidCallback onStart;
  const _EmptyHistory({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: DesignTokens.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(child: Text('ðŸ’¬', style: TextStyle(fontSize: 50))),
            ),
            const SizedBox(height: 24),
            const Text(
              'No conversations yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textStrong,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start chatting with the AI assistant\nto see your history here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DesignTokens.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onStart,
              icon: const Text('ðŸ¤–', style: TextStyle(fontSize: 16)),
              label: const Text(
                'Start New Chat',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: DesignTokens.primary,
                minimumSize: const Size(200, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
