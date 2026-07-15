import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../domain/entities/chat_message.dart';
import 'message_time.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public entry point
// ─────────────────────────────────────────────────────────────────────────────

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onSpeak;

  const MessageBubble({
    super.key,
    required this.message,
    this.onSpeak,
  });

  bool get _isUser => message.sender == ChatSender.user;

  bool get _isEmergency {
    if (message is ChatMessageModel) {
      return (message as ChatMessageModel).isEmergency;
    }
    return _hasEmergencyKeyword(message.text);
  }

  String? get _intent {
    if (message is ChatMessageModel) return (message as ChatMessageModel).intent;
    return null;
  }

  bool get _isOnline {
    if (message is ChatMessageModel) return (message as ChatMessageModel).isOnlineMode;
    return true;
  }

  static bool _hasEmergencyKeyword(String t) {
    final l = t.toLowerCase();
    return l.contains('🚨') || l.contains('emergency') ||
        l.contains('ambulance') || l.contains('108') || l.contains('call 10');
  }

  @override
  Widget build(BuildContext context) {
    if (_isUser) return _UserBubble(message: message);
    if (_isEmergency) return _EmergencyBubble(message: message, onSpeak: onSpeak);
    return _BotBubble(message: message, intent: _intent, isOnline: _isOnline, onSpeak: onSpeak);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// User Bubble — gradient purple pill, right-aligned, matches screenshot
// ─────────────────────────────────────────────────────────────────────────────

class _UserBubble extends StatelessWidget {
  final ChatMessage message;
  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.72),
              child: GestureDetector(
                onLongPress: () => _copy(context, message.text),
                child: Container(
                  margin: const EdgeInsets.only(left: 56),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF926EFF), Color(0xFF6B47E8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF926EFF).withValues(alpha: 0.35),
                        blurRadius: 12, offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Voice message badge — matches screenshot
                      if (message.isVoiceMessage)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.mic_rounded, size: 11, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text('Voice message',
                                        style: TextStyle(color: Colors.white, fontSize: 10,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        message.text,
                        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.45),
                      ),
                      const SizedBox(height: 4),
                      MessageTime(time: message.createdAt, light: true),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          _UserAvatar(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bot Bubble — white card, intent header strip, markdown body, speak btn
// ─────────────────────────────────────────────────────────────────────────────

class _BotBubble extends StatelessWidget {
  final ChatMessage message;
  final String? intent;
  final bool isOnline;
  final VoidCallback? onSpeak;

  const _BotBubble({
    required this.message,
    this.intent,
    required this.isOnline,
    this.onSpeak,
  });

  static const _intentMeta = {
    'SYMPTOM_QUERY':       ('🤒', 'Symptom Guide',    Color(0xFFFF7B3D)),
    'MEDICATION_QUERY':    ('💊', 'Medicine Info',     Color(0xFF4F94FF)),
    'NUTRITION_QUERY':     ('🥗', 'Nutrition Advice',  Color(0xFF2ECC8B)),
    'EXERCISE_QUERY':      ('🏃', 'Exercise Guide',    Color(0xFFFFB829)),
    'PREGNANCY_QUERY':     ('🤰', 'Pregnancy Guide',   Color(0xFFFF5E9E)),
    'CHILDCARE_QUERY':     ('👶', 'Child Healthcare',  Color(0xFF18C8C8)),
    'ELDERLYCARE_QUERY':   ('👴', 'Elderly Care',      Color(0xFFBF8B5E)),
    'MENTAL_HEALTH_QUERY': ('🧠', 'Mental Wellness',   Color(0xFF926EFF)),
    'GENERAL_MEDICAL':     ('🩺', 'Health Guidance',   Color(0xFF926EFF)),
    'GENERAL_CHAT':        ('🤖', 'Assistant',         Color(0xFF4F94FF)),
    'FOLLOW_UP_QUERY':     ('💬', 'Follow-up',         Color(0xFF5F6FFF)),
    'EMERGENCY_QUERY':     ('🚨', 'Emergency',         Color(0xFFFF4757)),
  };

  @override
  Widget build(BuildContext context) {
    final meta  = _intentMeta[intent] ?? const ('🤖', 'Medical Assistant', Color(0xFF926EFF));
    final emoji  = meta.$1;
    final label  = meta.$2;
    final accent = meta.$3;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _BotAvatar(emoji: emoji, accent: accent),
          const SizedBox(width: 6),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.80),
              child: GestureDetector(
                onLongPress: () => _copy(context, message.text),
                child: Container(
                  margin: const EdgeInsets.only(right: 28),
                  decoration: BoxDecoration(
                    color: DesignTokens.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(color: DesignTokens.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8, offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Intent header strip ───────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.10),
                            border: Border(
                              bottom: BorderSide(color: accent.withValues(alpha: 0.20)),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(emoji, style: const TextStyle(fontSize: 13)),
                              const SizedBox(width: 5),
                              Text(label,
                                  style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w800,
                                    color: accent, letterSpacing: 0.3,
                                  )),
                              const Spacer(),
                              // Online / Offline mode badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (isOnline ? DesignTokens.success : DesignTokens.warning)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isOnline ? '🌐 AI' : '📴 Offline',
                                  style: TextStyle(
                                    fontSize: 9, fontWeight: FontWeight.w700,
                                    color: isOnline ? DesignTokens.success : DesignTokens.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── Markdown body ─────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                          child: MarkdownBody(
                            data: message.text,
                            shrinkWrap: true,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(
                                color: DesignTokens.textStrong,
                                fontSize: 13.5, height: 1.5,
                              ),
                              strong: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: DesignTokens.textStrong,
                              ),
                              em: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: DesignTokens.textMuted,
                              ),
                              listBullet: TextStyle(color: accent),
                              h3: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w800, color: accent,
                              ),
                              blockquote: TextStyle(
                                color: DesignTokens.textMuted, fontSize: 13,
                                fontStyle: FontStyle.italic,
                                backgroundColor: accent.withValues(alpha: 0.05),
                              ),
                              code: TextStyle(
                                fontSize: 12,
                                backgroundColor: accent.withValues(alpha: 0.08),
                                color: accent,
                              ),
                            ),
                          ),
                        ),

                        // ── Footer row: time + speak btn ──────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
                          child: Row(
                            children: [
                              if (message.isVoiceMessage) ...[
                                const Icon(Icons.mic_rounded,
                                    size: 10, color: DesignTokens.textSubtle),
                                const SizedBox(width: 3),
                              ],
                              MessageTime(time: message.createdAt, light: false),
                              const Spacer(),
                              if (onSpeak != null)
                                _SpeakButton(accent: accent, onTap: onSpeak!),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Emergency Bubble — vivid red card
// ─────────────────────────────────────────────────────────────────────────────

class _EmergencyBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onSpeak;
  const _EmergencyBubble({required this.message, this.onSpeak});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: GestureDetector(
        onLongPress: () => _copy(context, message.text),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF1744), Color(0xFF8B0000)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF4757).withValues(alpha: 0.45),
                blurRadius: 20, offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: Row(
                  children: [
                    const Text('🚨', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    const Text('MEDICAL EMERGENCY',
                        style: TextStyle(color: Colors.white, fontSize: 13,
                            fontWeight: FontWeight.w900, letterSpacing: 0.6)),
                    const Spacer(),
                    if (onSpeak != null)
                      GestureDetector(
                        onTap: onSpeak,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.volume_up_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ),
                  ],
                ),
              ),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(message.text,
                    style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5)),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: Row(
                  children: [
                    _CallBtn('🚑', '108\nIndia'),
                    SizedBox(width: 8),
                    _CallBtn('🏥', '102\nNepal'),
                    SizedBox(width: 8),
                    _CallBtn('🆘', '112\nGlobal'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: MessageTime(time: message.createdAt, light: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallBtn extends StatelessWidget {
  final String emoji, label;
  const _CallBtn(this.emoji, this.label);
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: Colors.white30),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 2),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, height: 1.2)),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Speak button
// ─────────────────────────────────────────────────────────────────────────────

class _SpeakButton extends StatelessWidget {
  final Color accent;
  final VoidCallback onTap;
  const _SpeakButton({required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.volume_up_rounded, size: 12, color: accent),
              const SizedBox(width: 4),
              Text('Speak',
                  style: TextStyle(fontSize: 10, color: accent, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatars
// ─────────────────────────────────────────────────────────────────────────────

class _BotAvatar extends StatelessWidget {
  final String emoji;
  final Color accent;
  const _BotAvatar({required this.emoji, required this.accent});

  @override
  Widget build(BuildContext context) => Container(
        width: 30, height: 30,
        margin: const EdgeInsets.only(bottom: 2, left: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accent, accent.withValues(alpha: 0.7)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 14))),
      );
}

class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 30, height: 30,
        margin: const EdgeInsets.only(bottom: 2, right: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF926EFF), Color(0xFF6B47E8)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(9),
        ),
        child: const Center(
          child: Icon(Icons.person_rounded, size: 16, color: Colors.white),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Copy helper
// ─────────────────────────────────────────────────────────────────────────────

void _copy(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: const Text('✅ Copied to clipboard'),
    duration: const Duration(seconds: 1),
    backgroundColor: DesignTokens.primary,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ));
}
