import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../shared/design_system/design_tokens.dart';

/// Full-screen Alexa/Siri-style loading widget.
/// Shows a pulsing orb and cycles through greetings in 4 languages.
class ChatbotLoadingWidget extends StatefulWidget {
  const ChatbotLoadingWidget({super.key});

  @override
  State<ChatbotLoadingWidget> createState() => _ChatbotLoadingWidgetState();
}

class _ChatbotLoadingWidgetState extends State<ChatbotLoadingWidget>
    with TickerProviderStateMixin {
  // Orb pulse
  late final AnimationController _pulseCtrl;
  late final Animation<double>   _pulseAnim;

  // Ring rotate
  late final AnimationController _rotateCtrl;

  // Greeting fade
  late final AnimationController _greetCtrl;
  late final Animation<double>   _greetFade;
  late final Animation<Offset>   _greetSlide;

  int _greetIndex = 0;

  static const _greetings = [
    ('🇬🇧', 'Hello! How can I help you?',              'English'),
    ('🇮🇳', 'नमस्ते! मैं आपकी कैसे मदद कर सकता हूँ?',  'हिंदी'),
    ('🇳🇵', 'नमस्कार! म तपाईलाई कसरी सहयोग गर्न सक्छु?', 'नेपाली'),
    ('🗣️', 'नमस्कार! हम रउआ के कइसे मदद कर सकीला?',   'भोजपुरी'),
  ];

  static const _features = [
    ('🎙️', 'Voice Chat'),
    ('💬', 'Text Chat'),
    ('🌍', '4 Languages'),
    ('📴', 'Works Offline'),
    ('🚨', 'Emergency Help'),
    ('🩺', 'Medical Advice'),
  ];

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.90, end: 1.08)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();

    _greetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _greetFade = CurvedAnimation(parent: _greetCtrl, curve: Curves.easeOut);
    _greetSlide = Tween<Offset>(
            begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _greetCtrl, curve: Curves.easeOut));

    _greetCtrl.forward();
    _cycleGreetings();
  }

  void _cycleGreetings() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      await _greetCtrl.reverse();
      if (!mounted) return;
      setState(() {
        _greetIndex = (_greetIndex + 1) % _greetings.length;
      });
      await _greetCtrl.forward();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rotateCtrl.dispose();
    _greetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = _greetings[_greetIndex];
    return Container(
      color: DesignTokens.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Animated orb ──────────────────────────────────────────────
            SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating shimmer ring
                  AnimatedBuilder(
                    animation: _rotateCtrl,
                    builder: (_, __) => Transform.rotate(
                      angle: _rotateCtrl.value * 2 * math.pi,
                      child: Container(
                        width: 148,
                        height: 148,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              Colors.transparent,
                              DesignTokens.primary,
                              DesignTokens.secondary,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Pulsing orb
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, __) => Transform.scale(
                      scale: _pulseAnim.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF926EFF),
                              Color(0xFF4F94FF),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: DesignTokens.primary
                                  .withValues(alpha: 0.45),
                              blurRadius: 36,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('🤖',
                              style: TextStyle(fontSize: 52)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── App name ──────────────────────────────────────────────────
            const Text(
              'AI Medical Assistant',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: DesignTokens.textStrong,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),

            // ── Animated greeting ──────────────────────────────────────────
            SizedBox(
              height: 56,
              child: SlideTransition(
                position: _greetSlide,
                child: FadeTransition(
                  opacity: _greetFade,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(g.$1,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(
                            g.$2,
                            style: const TextStyle(
                              fontSize: 14,
                              color: DesignTokens.textMuted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        g.$3,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: DesignTokens.primary.withValues(alpha: 0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Loading dots ─────────────────────────────────────────────
            const _LoadingDots(),

            const SizedBox(height: 28),

            // ── Feature pills ─────────────────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _features
                  .map((f) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: DesignTokens.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: DesignTokens.primary
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(f.$1,
                                style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 5),
                            Text(
                              f.$2,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: DesignTokens.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 16),

            // ── Disclaimer ────────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                '⚠️ General health info only — not a substitute for a doctor 🩺',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: DesignTokens.textSubtle,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Three bouncing dots
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.33;
            final phase = (_ctrl.value - delay).clamp(0.0, 1.0);
            final offset = math.sin(phase * math.pi).clamp(0.0, 1.0);
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              transform: Matrix4.translationValues(0, -10 * offset, 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DesignTokens.primary
                    .withValues(alpha: 0.4 + 0.6 * offset),
              ),
            );
          }),
        );
      },
    );
  }
}
