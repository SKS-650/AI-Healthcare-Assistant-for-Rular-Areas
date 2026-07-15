import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/chat_message.dart';
import '../controllers/chatbot_state.dart';
import '../providers/chatbot_provider.dart';
import '../widgets/chat/chat_input_field.dart';
import '../widgets/chat/emergency_card.dart';
import '../widgets/chat/follow_up_chips.dart';
import '../widgets/chat/message_bubble.dart';
import '../widgets/chat/typing_indicator.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/suggestions/quick_questions.dart';
import 'voice_chat_page.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state      = ref.watch(chatbotControllerProvider);
    final controller = ref.read(chatbotControllerProvider.notifier);

    ref.listen(chatbotControllerProvider, (prev, next) {
      if (next.messages.length != (prev?.messages.length ?? 0)) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: _ChatAppBar(
        isOnline: state.isOnlineMode,
        language: state.selectedLanguage,
        onVoiceTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VoiceChatPage()),
        ),
        onLanguageTap: () => _showLanguagePicker(context, state.selectedLanguage, controller),
      ),
      body: switch (state.status) {
        ChatbotStatus.initial || ChatbotStatus.loading => const ChatbotLoadingWidget(),
        ChatbotStatus.error when state.conversation == null => _ErrorView(
            message: state.errorMessage,
            onRetry: controller.load,
          ),
        _ => _ChatBody(state: state, controller: controller, scroll: _scroll),
      },
    );
  }

  void _showLanguagePicker(
      BuildContext ctx, String current, dynamic ctrl) {
    const langs = [
      ('en',  '🇬🇧', 'English'),
      ('hi',  '🇮🇳', 'हिंदी'),
      ('ne',  '🇳🇵', 'नेपाली'),
      ('bho', '🗣️',  'भोजपुरी'),
    ];
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: DesignTokens.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: DesignTokens.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text('🌍 Select Language',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                    color: DesignTokens.textStrong)),
            const SizedBox(height: 16),
            ...langs.map((l) => ListTile(
                  leading: Text(l.$2, style: const TextStyle(fontSize: 24)),
                  title: Text(l.$3,
                      style: TextStyle(
                        fontWeight: current == l.$1 ? FontWeight.w800 : FontWeight.w500,
                        color: current == l.$1 ? DesignTokens.primary : DesignTokens.textStrong,
                      )),
                  trailing: current == l.$1
                      ? const Icon(Icons.check_circle_rounded, color: DesignTokens.primary)
                      : null,
                  onTap: () {
                    ctrl.updateLanguageCode(l.$1);
                    Navigator.pop(ctx);
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppBar — matches screenshot: bot avatar, Online●, language badge, mic icon
// ─────────────────────────────────────────────────────────────────────────────

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isOnline;
  final String language;
  final VoidCallback onVoiceTap;
  final VoidCallback onLanguageTap;

  const _ChatAppBar({
    required this.isOnline,
    required this.language,
    required this.onVoiceTap,
    required this.onLanguageTap,
  });

  static const _langLabels = {
    'en': '🇬🇧 EN', 'hi': '🇮🇳 HI', 'ne': '🇳🇵 NE', 'bho': '🗣️ BHO',
  };

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: DesignTokens.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: DesignTokens.textStrong, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          // Bot avatar
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DesignTokens.primary, DesignTokens.secondary],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Center(child: Text('🤖', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Medical Assistant',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                        color: DesignTokens.textStrong)),
                Row(
                  children: [
                    // Online/offline dot
                    Container(
                      width: 7, height: 7,
                      decoration: BoxDecoration(
                        color: isOnline ? DesignTokens.success : DesignTokens.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(isOnline ? 'Online' : 'Offline mode',
                        style: const TextStyle(fontSize: 11, color: DesignTokens.textMuted)),
                    const SizedBox(width: 8),
                    // Language badge — tappable
                    GestureDetector(
                      onTap: onLanguageTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: DesignTokens.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: DesignTokens.primary.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          _langLabels[language] ?? '🌐 $language',
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w700,
                              color: DesignTokens.primaryDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Voice button
        Container(
          margin: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: DesignTokens.aquaGradient,
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.mic_rounded, color: Colors.white, size: 18),
            ),
            tooltip: 'Voice chat',
            onPressed: onVoiceTap,
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: DesignTokens.border),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────────────────────────────

class _ChatBody extends StatelessWidget {
  final ChatbotState state;
  final dynamic controller;
  final ScrollController scroll;
  const _ChatBody({required this.state, required this.controller, required this.scroll});

  @override
  Widget build(BuildContext context) {
    final messages  = state.messages;
    final isSending = state.status == ChatbotStatus.sending;
    final followUps = state.followUpQuestions;
    final isEmerg   = state.lastResponseWasEmergency;

    // Extra item count for emergency card and follow-up chips
    final extras = (isEmerg ? 1 : 0) + (followUps.isNotEmpty && !isSending ? 1 : 0);

    return Column(
      children: [
        // Suggestions on empty state
        if (state.suggestions.isNotEmpty && messages.isEmpty)
          QuickQuestions(
            suggestions: state.suggestions,
            onSelected: controller.sendMessage,
          ),

        Expanded(
          child: messages.isEmpty
              ? _WelcomeView(onSend: controller.sendMessage)
              : ListView.builder(
                  controller: scroll,
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
                  itemCount: messages.length + (isSending ? 1 : 0) + extras,
                  itemBuilder: (ctx, i) {
                    // After last message: emergency card
                    if (isEmerg && i == messages.length) {
                      return const EmergencyCard();
                    }
                    // Adjust index after emergency card
                    int adj = (isEmerg && i > messages.length) ? i - 1 : i;

                    // After messages (+emergency): typing or follow-up chips
                    if (adj == messages.length) {
                      if (isSending) return const TypingIndicator();
                      if (followUps.isNotEmpty) {
                        return FollowUpChips(
                          questions: followUps,
                          onTap: controller.sendMessage,
                        );
                      }
                    }

                    if (adj >= messages.length) return const SizedBox.shrink();

                    final msg = messages[adj];
                    return MessageBubble(
                      key: ValueKey(msg.id),
                      message: msg,
                      onSpeak: msg.sender == ChatSender.bot
                          ? () => controller.speakText(msg.text)
                          : null,
                    );
                  },
                ),
        ),

        // Input field
        ChatInputField(
          enabled: !isSending,
          onSend: controller.sendMessage,
          onVoice: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VoiceChatPage()),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Welcome view — shown when no messages yet
// ─────────────────────────────────────────────────────────────────────────────

class _WelcomeView extends StatelessWidget {
  final ValueChanged<String> onSend;
  const _WelcomeView({required this.onSend});

  static const _starters = [
    ('🌡️', 'I have fever and cough',     Color(0xFFFF4757), Color(0xFFFFECED)),
    ('🤕', 'I have a headache',           Color(0xFFFF7B3D), Color(0xFFFFF0E8)),
    ('💊', 'What is Paracetamol?',         Color(0xFF4F94FF), Color(0xFFE8F1FF)),
    ('🥗', 'Foods for diabetes',           Color(0xFF2ECC8B), Color(0xFFE4FBF0)),
    ('🤰', 'Pregnancy nutrition tips',     Color(0xFFFF5E9E), Color(0xFFFFEAF3)),
    ('👶', 'Child vaccination schedule',   Color(0xFF18C8C8), Color(0xFFE4FAFA)),
    ('🚨', 'Heart attack symptoms',        Color(0xFFFF4757), Color(0xFFFFECED)),
    ('🧠', 'I feel stressed and anxious',  Color(0xFF926EFF), Color(0xFFF0EBFF)),
    ('👴', 'Joint pain in elderly',        Color(0xFFBF8B5E), Color(0xFFF9EDE0)),
    ('🏃', 'Exercise for weight loss',     Color(0xFFFFB829), Color(0xFFFFF8E6)),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          const SizedBox(height: 4),
          // Bot avatar orb
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6B47E8), Color(0xFF4F94FF)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF926EFF).withValues(alpha: 0.45),
                  blurRadius: 28, offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(child: Text('🤖', style: TextStyle(fontSize: 44))),
          ),
          const SizedBox(height: 16),
          const Text('How can I help you today? 😊',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                  color: DesignTokens.textStrong, letterSpacing: -0.4)),
          const SizedBox(height: 8),
          const Text('🇬🇧 English  •  🇮🇳 हिंदी  •  🇳🇵 नेपाली  •  🗣️ भोजपुरी',
              textAlign: TextAlign.center,
              style: TextStyle(color: DesignTokens.textMuted, fontSize: 12.5, height: 1.5)),
          const SizedBox(height: 6),
          const Text(
            'Ask about symptoms 🤒, medicines 💊, diet 🥗, pregnancy 🤰, mental health 🧠 or emergencies 🚨.',
            textAlign: TextAlign.center,
            style: TextStyle(color: DesignTokens.textSubtle, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('💡 Try asking:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
                    color: DesignTokens.textMuted)),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 8,
              mainAxisSpacing: 8, childAspectRatio: 2.6,
            ),
            itemCount: _starters.length,
            itemBuilder: (_, i) {
              final s = _starters[i];
              return GestureDetector(
                onTap: () => onSend(s.$2),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: s.$4,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: s.$3.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      Text(s.$1, style: const TextStyle(fontSize: 17)),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(s.$2,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                                color: s.$3, height: 1.2),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          // Disclaimer
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: DesignTokens.warningContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DesignTokens.warning.withValues(alpha: 0.4)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⚠️', style: TextStyle(fontSize: 14)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This AI provides general health information only. '
                    'Always consult a qualified doctor for medical advice. 🩺',
                    style: TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error view
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  const _ErrorView({this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(message ?? 'Something went wrong.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15,
                      color: DesignTokens.textMuted, height: 1.5)),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
                style: FilledButton.styleFrom(
                    backgroundColor: DesignTokens.primary),
              ),
            ],
          ),
        ),
      );
}
