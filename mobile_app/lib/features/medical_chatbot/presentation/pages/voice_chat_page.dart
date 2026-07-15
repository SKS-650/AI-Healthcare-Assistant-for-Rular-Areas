import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../providers/chatbot_provider.dart';
import '../widgets/voice/language_pill.dart';
import '../widgets/voice/orb_animation.dart';
import '../widgets/voice/waveform_bars.dart';
import 'chat_page.dart';

/// Alexa / Siri style voice chat page.
/// Dark gradient background, animated orb, waveform, transcript card.
class VoiceChatPage extends ConsumerStatefulWidget {
  const VoiceChatPage({super.key});

  @override
  ConsumerState<VoiceChatPage> createState() => _VoiceChatPageState();
}

class _VoiceChatPageState extends ConsumerState<VoiceChatPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final Animation<double>   _enterFade;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _enterFade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state      = ref.watch(chatbotControllerProvider);
    final controller = ref.read(chatbotControllerProvider.notifier);
    final voice      = state.voiceState;

    final isListening = voice.isListening;
    final isSpeaking  = voice.isSpeaking;
    final transcript  = voice.transcript;

    final lastBotMsg = state.messages
        .where((m) => m.sender.name == 'bot')
        .lastOrNull
        ?.text ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF08051A),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(state.isOnlineMode, state.selectedLanguage),
      body: FadeTransition(
        opacity: _enterFade,
        child: Stack(
          children: [
            // ── Decorative background blobs ───────────────────────────────
            const Positioned(
              top: -80, left: -80,
              child: _Blob(color: Color(0xFF926EFF), size: 280),
            ),
            const Positioned(
              bottom: 120, right: -60,
              child: _Blob(color: Color(0xFF4F94FF), size: 200),
            ),

            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 4),

                  // ── Status pill ───────────────────────────────────────
                  _StatusPill(isListening: isListening, isSpeaking: isSpeaking),

                  const Spacer(flex: 2),

                  // ── Animated orb ──────────────────────────────────────
                  OrbAnimation(
                    isListening: isListening,
                    isSpeaking: isSpeaking,
                    size: 175,
                  ),

                  const SizedBox(height: 20),

                  // ── Waveform ──────────────────────────────────────────
                  WaveformBars(
                    active: isListening || isSpeaking,
                    color: isListening ? DesignTokens.danger : DesignTokens.primary,
                    barCount: 17,
                    height: 56,
                  ),

                  const Spacer(flex: 1),

                  // ── Transcript / response / hint card ─────────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: (transcript.isNotEmpty || isSpeaking)
                        ? Padding(
                            key: const ValueKey('content'),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _ContentCard(
                              label: transcript.isNotEmpty ? '📝 You said' : '🔊 Response',
                              text: transcript.isNotEmpty ? transcript : lastBotMsg,
                              color: transcript.isNotEmpty
                                  ? DesignTokens.primary
                                  : DesignTokens.success,
                              isResponse: transcript.isEmpty && isSpeaking,
                            ),
                          )
                        : Padding(
                            key: const ValueKey('hint'),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _HintCard(language: state.selectedLanguage),
                          ),
                  ),

                  const Spacer(flex: 2),

                  // ── Language selector ─────────────────────────────────
                  _LangRow(
                    selected: state.selectedLanguage,
                    onSelect: controller.updateLanguageCode,
                  ),

                  const SizedBox(height: 24),

                  // ── Mic button ────────────────────────────────────────
                  _MicButton(
                    isListening: isListening,
                    isBusy: state.isBusy,
                    onTap: () => controller.toggleListening(continuous: true),
                  ),

                  const SizedBox(height: 14),

                  // ── Action row ────────────────────────────────────────
                  _ActionRow(
                    transcript: transcript,
                    isSpeaking: isSpeaking,
                    onClear: controller.clearTranscript,
                    onSend: () {
                      controller.sendMessage(transcript, isVoiceMessage: true);
                      controller.clearTranscript();
                      Navigator.of(context).pop();
                    },
                    onStop: () => controller.stopContinuousConversation(),
                    onViewChat: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const ChatPage()),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isOnline, String lang) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white70, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Row(
        children: [
          Text('🎙️', style: TextStyle(fontSize: 18)),
          SizedBox(width: 8),
          Text('Voice Assistant',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 14),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: (isOnline ? DesignTokens.success : DesignTokens.warning)
                .withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (isOnline ? DesignTokens.success : DesignTokens.warning)
                  .withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 7,
                  color: isOnline ? DesignTokens.success : DesignTokens.warning),
              const SizedBox(width: 4),
              Text(isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: isOnline ? DesignTokens.success : DesignTokens.warning,
                    fontSize: 11, fontWeight: FontWeight.w700,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background blob
// ─────────────────────────────────────────────────────────────────────────────

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.0)],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Status pill
// ─────────────────────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final bool isListening, isSpeaking;
  const _StatusPill({required this.isListening, required this.isSpeaking});

  @override
  Widget build(BuildContext context) {
    final (String label, Color color, String emoji) = isSpeaking
        ? ('Speaking response…', DesignTokens.success, '🔊')
        : isListening
            ? ('Listening… speak now 🎙️', DesignTokens.danger, '🔴')
            : ('Ready — tap mic to speak', DesignTokens.primary, '🎙️');

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(label),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 7),
            Text(label,
                style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Content card (transcript / response)
// ─────────────────────────────────────────────────────────────────────────────

class _ContentCard extends StatelessWidget {
  final String label, text;
  final Color color;
  final bool isResponse;
  const _ContentCard({
    required this.label, required this.text,
    required this.color, required this.isResponse,
  });

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.4)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.14), blurRadius: 18)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(label,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        color: color, letterSpacing: 0.4)),
                if (isResponse) ...[
                  const Spacer(),
                  _PulsingDot(color: color),
                ],
              ],
            ),
            const SizedBox(height: 7),
            Flexible(
              child: SingleChildScrollView(
                child: Text(text,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, height: 1.45,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      );
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _c,
        child: Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Hint card (idle)
// ─────────────────────────────────────────────────────────────────────────────

class _HintCard extends StatelessWidget {
  final String language;
  const _HintCard({required this.language});

  static const _hints = {
    'en':  '💬 Say:\n"I have a fever" or "What is Paracetamol?"',
    'hi':  '💬 बोलें:\n"मुझे बुखार है" या "पेरासिटामोल क्या है?"',
    'ne':  '💬 भन्नुहोस्:\n"मलाई ज्वरो छ" वा "औषधि के हो?"',
    'bho': '💬 बोला:\n"हमरा बुखार बा" या "दवाई का बा?"',
  };

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Text(
          _hints[language] ?? _hints['en']!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white38, fontSize: 14, height: 1.5),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Language row
// ─────────────────────────────────────────────────────────────────────────────

class _LangRow extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _LangRow({required this.selected, required this.onSelect});

  static const _langs = [
    ('en',  '🇬🇧', 'EN'),
    ('hi',  '🇮🇳', 'HI'),
    ('ne',  '🇳🇵', 'NE'),
    ('bho', '🗣️',  'BHO'),
  ];

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const Text('🌍 Select Language',
              style: TextStyle(color: Colors.white38, fontSize: 11,
                  fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _langs.map((l) => GestureDetector(
                  onTap: () => onSelect(l.$1),
                  child: LanguagePill(
                      flag: l.$2, code: l.$3, isActive: selected == l.$1),
                )).toList(),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Mic button
// ─────────────────────────────────────────────────────────────────────────────

class _MicButton extends StatefulWidget {
  final bool isListening, isBusy;
  final VoidCallback onTap;
  const _MicButton({required this.isListening, required this.isBusy, required this.onTap});
  @override
  State<_MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<_MicButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final color = widget.isListening ? DesignTokens.danger : DesignTokens.primary;
    return GestureDetector(
      onTap: widget.isBusy ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, child) {
          final scale = widget.isListening ? (1.0 + _pulse.value * 0.12) : 1.0;
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Container(
          width: 82, height: 82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: widget.isListening
                  ? [DesignTokens.danger, const Color(0xFF8B0000)]
                  : [DesignTokens.primary, DesignTokens.primaryDark],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: widget.isListening ? 0.65 : 0.5),
                blurRadius: widget.isListening ? 42 : 24,
                spreadRadius: widget.isListening ? 8 : 2,
              ),
            ],
          ),
          child: Icon(
            widget.isBusy
                ? Icons.hourglass_top_rounded
                : widget.isListening
                    ? Icons.stop_rounded
                    : Icons.mic_rounded,
            color: Colors.white,
            size: 38,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action row
// ─────────────────────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  final String transcript;
  final bool isSpeaking;
  final VoidCallback onClear, onSend, onStop, onViewChat;
  const _ActionRow({
    required this.transcript, required this.isSpeaking,
    required this.onClear, required this.onSend,
    required this.onStop, required this.onViewChat,
  });

  @override
  Widget build(BuildContext context) {
    if (isSpeaking) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Btn('⏹️ Stop', DesignTokens.danger, onStop),
          const SizedBox(width: 12),
          _Btn('💬 View Chat', DesignTokens.primary, onViewChat),
        ],
      );
    }
    if (transcript.isNotEmpty) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Btn('🗑️ Clear', Colors.white38, onClear),
          const SizedBox(width: 12),
          _Btn('📤 Send', DesignTokens.success, onSend),
        ],
      );
    }
    return GestureDetector(
      onTap: onViewChat,
      child: Text('💬 Switch to text chat',
          style: TextStyle(
              color: DesignTokens.primary.withValues(alpha: 0.75),
              fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Btn(this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
        ),
      );
}
