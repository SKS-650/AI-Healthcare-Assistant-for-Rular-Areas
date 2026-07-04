import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../controllers/chatbot_state.dart';
import '../providers/chatbot_provider.dart';
import '../widgets/chat/chat_input_field.dart';
import '../widgets/chat/message_bubble.dart';
import '../widgets/chat/typing_indicator.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/suggestions/quick_questions.dart';

class ChatPage extends ConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatbotControllerProvider);
    final controller = ref.read(chatbotControllerProvider.notifier);

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
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
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [DesignTokens.primary, DesignTokens.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Medical Assistant',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: DesignTokens.textStrong,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: DesignTokens.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Online • Responds instantly',
                        style: TextStyle(
                            fontSize: 11, color: DesignTokens.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, size: 20),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: DesignTokens.border),
        ),
      ),
      body: switch (state.status) {
        ChatbotStatus.initial ||
        ChatbotStatus.loading =>
          const ChatbotLoadingWidget(),
        ChatbotStatus.error when state.conversation == null =>
          _ErrorView(message: state.errorMessage),
        _ => Column(
            children: [
              if (state.suggestions.isNotEmpty && state.messages.isEmpty)
                QuickQuestions(
                  suggestions: state.suggestions,
                  onSelected: controller.sendMessage,
                ),
              Expanded(
                child: state.messages.isEmpty
                    ? const _WelcomeView()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        itemCount: state.messages.length +
                            (state.status == ChatbotStatus.sending ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= state.messages.length) {
                            return const TypingIndicator();
                          }
                          final message = state.messages[index];
                          return MessageBubble(
                              key: ValueKey(message.id), message: message);
                        },
                      ),
              ),
              ChatInputField(
                enabled: state.status != ChatbotStatus.sending,
                onSend: controller.sendMessage,
              ),
            ],
          ),
      },
    );
  }
}

class _WelcomeView extends StatelessWidget {
  const _WelcomeView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DesignTokens.primary, DesignTokens.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 44))),
          ),
          const SizedBox(height: 20),
          const Text(
            'How can I help you today?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: DesignTokens.textStrong,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ask me anything about your health,\nsymptoms, or medical questions.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: DesignTokens.textMuted, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _SamplePrompt('I have a headache'),
              _SamplePrompt('Is this medicine safe?'),
              _SamplePrompt('Fever remedies?'),
              _SamplePrompt('When to see a doctor?'),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: DesignTokens.warningContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DesignTokens.warningLight),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⚠️', style: TextStyle(fontSize: 16)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This AI assistant does not replace professional medical advice. Always consult a doctor for serious conditions.',
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF92400E),
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SamplePrompt extends StatelessWidget {
  final String text;
  const _SamplePrompt(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: DesignTokens.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: DesignTokens.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: DesignTokens.primaryDark,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String? message;
  const _ErrorView({this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              message ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15,
                  color: DesignTokens.textMuted,
                  height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
