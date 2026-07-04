import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../providers/chatbot_provider.dart';
import '../widgets/history/history_card.dart';
import 'chat_page.dart';
import 'chatbot_settings_page.dart';
import 'conversation_history_page.dart';
import 'voice_chat_page.dart';

class ChatbotHomePage extends ConsumerWidget {
  const ChatbotHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatbotControllerProvider);

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        foregroundColor: const Color(0xFF1A1035),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: DesignTokens.textStrong,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Row(
          children: [
            Text('🤖', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              'AI Medical Assistant',
              style: TextStyle(
                color: DesignTokens.textStrong,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Material(
              color: DesignTokens.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const ChatbotSettingsPage()),
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: DesignTokens.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.settings_outlined,
                    color: DesignTokens.primaryDark,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: DesignTokens.maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroBanner(),
                const SizedBox(height: 4),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _ActionCard(
                        emoji: '💬',
                        title: 'Text Chat',
                        subtitle: 'Type your symptoms and health questions',
                        gradColors: const [
                          Color(0xFF926EFF),
                          Color(0xFF6B47E8)
                        ],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ChatPage()),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _ActionCard(
                        emoji: '🎤',
                        title: 'Voice Chat',
                        subtitle:
                            'Speak in Nepali, Hindi, English or Bhojpuri',
                        gradColors: const [
                          Color(0xFF18C8C8),
                          Color(0xFF0B9B9B)
                        ],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const VoiceChatPage()),
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 22, 16, 10),
                  child: Text(
                    '✨ What I can help with',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: DesignTokens.textStrong,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const _CapabilitiesGrid(),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '🗂️ Recent Chats',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: DesignTokens.textStrong,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (state.history.isNotEmpty)
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ConversationHistoryPage(),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 13, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF926EFF),
                                  Color(0xFF6B47E8)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'View all →',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                if (state.history.isEmpty)
                  const _EmptyHistory()
                else
                  for (final conversation in state.history.take(3))
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: HistoryCard(conversation: conversation),
                    ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF926EFF), Color(0xFF4F94FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF926EFF).withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'AI Powered  •  Multilingual',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your Personal\nHealth Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ask about symptoms, medicines,\nand health advice — anytime.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Text('🤖', style: TextStyle(fontSize: 58)),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradColors;
  final VoidCallback onTap;

  const _ActionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DesignTokens.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: gradColors[0].withValues(alpha: 0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: gradColors[0].withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: gradColors[0].withValues(alpha: 0.30),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: DesignTokens.textStrong,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: DesignTokens.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: gradColors[0],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CapabilitiesGrid extends StatelessWidget {
  const _CapabilitiesGrid();

  static const _caps = [
    ('🩺', 'Symptoms', Color(0xFF926EFF), Color(0xFFF0EBFF)),
    ('💊', 'Medicines', Color(0xFF4F94FF), Color(0xFFE8F1FF)),
    ('🍎', 'Nutrition', Color(0xFF2ECC8B), Color(0xFFE4FBF0)),
    ('🏃', 'Exercise', Color(0xFFFFB829), Color(0xFFFFF8E6)),
    ('🤰', 'Pregnancy', Color(0xFFFF5E9E), Color(0xFFFFEAF3)),
    ('👶', 'Child Care', Color(0xFF18C8C8), Color(0xFFE4FAFA)),
    ('👴', 'Elderly', Color(0xFFBF8B5E), Color(0xFFF9EDE0)),
    ('🚨', 'Emergency', Color(0xFFFF4757), Color(0xFFFFECED)),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _caps.map((cap) {
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cap.$4,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: cap.$3.withValues(alpha: 0.30),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(cap.$1, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  cap.$2,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: cap.$3,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: DesignTokens.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: DesignTokens.primary.withValues(alpha: 0.20)),
        ),
        child: const Column(
          children: [
            Text('💬', style: TextStyle(fontSize: 32)),
            SizedBox(height: 10),
            Text(
              'No conversations yet',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: DesignTokens.primaryDark,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Start chatting to see your history here',
              style: TextStyle(
                color: DesignTokens.primaryDark,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
