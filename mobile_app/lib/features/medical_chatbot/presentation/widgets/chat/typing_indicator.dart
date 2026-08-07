import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

/// Premium ChatGPT-style typing indicator:
/// Bot avatar → bubble with 3 animated dots + "AI is thinking…" shimmer text.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  // Dot animation
  late final AnimationController _dotCtrl;
  // Shimmer text fade
  late final AnimationController _shimmerCtrl;
  late final Animation<double>   _shimmerFade;

  static const _phrases = [
    '🤖 AI is thinking…',
    '🩺 Checking health info…',
    '💊 Looking up medical data…',
    '📚 Searching knowledge base…',
    '✨ Preparing your answer…',
  ];

  int _phraseIndex = 0;

  @override
  void initState() {
    super.initState();

    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shimmerFade = CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut);
    _shimmerCtrl.value = 1.0;

    _cyclePhrases();
  }

  void _cyclePhrases() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 2200));
      if (!mounted) return;
      await _shimmerCtrl.reverse();
      if (!mounted) return;
      setState(() => _phraseIndex = (_phraseIndex + 1) % _phrases.length);
      await _shimmerCtrl.forward();
    }
  }

  @override
  void dispose() {
    _dotCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Bot avatar — matches other bot bubbles
          Container(
            width: 30, height: 30,
            margin: const EdgeInsets.only(bottom: 2, left: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DesignTokens.primary, DesignTokens.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(9),
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.primary.withValues(alpha: 0.3),
                  blurRadius: 6, offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(width: 6),

          // Bubble
          Container(
            margin: const EdgeInsets.only(right: 40),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: DesignTokens.surface,
              borderRadius: const BorderRadius.only(
                topLeft:     Radius.circular(5),
                topRight:    Radius.circular(20),
                bottomLeft:  Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: DesignTokens.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8, offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Three animated dots
                AnimatedBuilder(
                  animation: _dotCtrl,
                  builder: (_, __) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) {
                      final phase  = (i / 3.0);
                      final value  = (_dotCtrl.value + phase) % 1.0;
                      final bounce = math.sin(value * math.pi).clamp(0.0, 1.0);
                      return Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        transform: Matrix4.translationValues(0, -7 * bounce, 0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: DesignTokens.primary.withValues(
                            alpha: 0.35 + 0.65 * bounce,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 8),

                // Rotating shimmer phrase
                FadeTransition(
                  opacity: _shimmerFade,
                  child: Text(
                    _phrases[_phraseIndex],
                    style: const TextStyle(
                      fontSize: 11,
                      color: DesignTokens.textSubtle,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
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
