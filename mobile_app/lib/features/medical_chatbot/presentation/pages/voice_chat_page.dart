import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../providers/chatbot_provider.dart';

class VoiceChatPage extends ConsumerWidget {
  const VoiceChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatbotControllerProvider);
    final controller = ref.read(chatbotControllerProvider.notifier);
    final voice = state.voiceState;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        foregroundColor: const Color(0xFF1A1035),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: DesignTokens.textStrong, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          children: [
            Text('🎤', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text('Voice Chat'),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              _StatusCard(
                  isListening: voice.isListening,
                  isRecording: voice.isRecording),

              const Spacer(),

              // Wave animation bars
              SizedBox(
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(9, (i) {
                    final active = voice.isListening;
                    final heights = [
                      20.0, 35.0, 50.0, 65.0, 80.0, 65.0, 50.0, 35.0, 20.0
                    ];
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 200 + (i * 60)),
                      curve: Curves.easeInOut,
                      width: 6,
                      height: active ? heights[i] : 12,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: active
                            ? DesignTokens.primary
                                .withValues(alpha: 0.5 + (i / 20))
                            : DesignTokens.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 32),

              _MicButton(
                isListening: voice.isListening,
                onPressed: controller.toggleListening,
              ),

              const SizedBox(height: 24),

              // Transcript / hint
              if (voice.transcript.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DesignTokens.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: DesignTokens.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('📝', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 6),
                          Text(
                            'Transcript',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: DesignTokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        voice.transcript,
                        style: const TextStyle(
                          fontSize: 15,
                          color: DesignTokens.textStrong,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        DesignTokens.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Text('💬', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Text(
                        voice.isListening
                            ? 'Listening... speak now'
                            : 'Tap the mic button to start speaking',
                        style: const TextStyle(
                          color: DesignTokens.primaryDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              _LanguageRow(),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: voice.transcript.isEmpty
                      ? null
                      : () {
                          controller.sendMessage(
                            voice.transcript,
                            isVoiceMessage: true,
                          );
                          controller.clearTranscript();
                          Navigator.of(context).pop();
                        },
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text(
                    'Send Voice Message',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: DesignTokens.primary,
                    disabledBackgroundColor: DesignTokens.border,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final bool isListening;
  final bool isRecording;

  const _StatusCard(
      {required this.isListening, required this.isRecording});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isListening
              ? [DesignTokens.danger, const Color(0xFFB91C1C)]
              : [DesignTokens.primary, DesignTokens.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isListening
                    ? DesignTokens.danger
                    : DesignTokens.primary)
                .withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            isListening ? '🔴' : '🎤',
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isListening ? 'Listening...' : 'Voice Assistant Ready',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  isListening
                      ? 'Speak clearly in English, Hindi or Nepali'
                      : 'Tap mic to start • Supports 4 languages',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
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

class _MicButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onPressed;

  const _MicButton(
      {required this.isListening, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isListening
                ? [DesignTokens.danger, const Color(0xFFB91C1C)]
                : [DesignTokens.primary, DesignTokens.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isListening
                      ? DesignTokens.danger
                      : DesignTokens.primary)
                  .withValues(alpha: 0.4),
              blurRadius: 24,
              spreadRadius: 4,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          isListening ? Icons.stop_rounded : Icons.mic_rounded,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🌐', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        const Text(
          'Supports:',
          style: TextStyle(color: DesignTokens.textMuted, fontSize: 12),
        ),
        const SizedBox(width: 8),
        ...['🇬🇧 EN', '🇮🇳 HI', '🇳🇵 NP', '🗣️ BHO'].map(
          (lang) => Container(
            margin: const EdgeInsets.only(left: 6),
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: DesignTokens.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: DesignTokens.border),
            ),
            child: Text(
              lang,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: DesignTokens.textStrong,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
