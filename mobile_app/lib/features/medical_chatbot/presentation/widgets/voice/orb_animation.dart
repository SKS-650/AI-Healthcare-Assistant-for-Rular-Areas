import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../shared/design_system/design_tokens.dart';

/// Alexa/Siri-style pulsing orb animation.
/// - Idle:      gentle slow pulse, purple gradient
/// - Listening: faster pulse + red glow rings
/// - Speaking:  breathing blue-green gradient
class OrbAnimation extends StatefulWidget {
  final bool isListening;
  final bool isSpeaking;
  final double size;

  const OrbAnimation({
    super.key,
    required this.isListening,
    required this.isSpeaking,
    this.size = 160,
  });

  @override
  State<OrbAnimation> createState() => _OrbAnimationState();
}

class _OrbAnimationState extends State<OrbAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _rotateCtrl;
  late final AnimationController _ringCtrl;

  late Animation<double> _pulseAnim;
  late Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _pulseAnim = Tween<double>(begin: 0.92, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _ringAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(OrbAnimation old) {
    super.didUpdateWidget(old);
    if (widget.isListening) {
      _pulseCtrl.duration = const Duration(milliseconds: 600);
      _pulseCtrl.repeat(reverse: true);
    } else if (widget.isSpeaking) {
      _pulseCtrl.duration = const Duration(milliseconds: 900);
      _pulseCtrl.repeat(reverse: true);
    } else {
      _pulseCtrl.duration = const Duration(milliseconds: 1800);
      _pulseCtrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rotateCtrl.dispose();
    _ringCtrl.dispose();
    super.dispose();
  }

  List<Color> get _gradientColors {
    if (widget.isListening) {
      return [DesignTokens.danger, const Color(0xFF7B0000)];
    } else if (widget.isSpeaking) {
      return [DesignTokens.success, DesignTokens.teal];
    }
    return [DesignTokens.primary, DesignTokens.primaryDark];
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;

    return SizedBox(
      width:  s * 1.5,
      height: s * 1.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ripple ring (only while listening)
          if (widget.isListening)
            AnimatedBuilder(
              animation: _ringAnim,
              builder: (_, __) {
                final scale = 1.0 + _ringAnim.value * 0.55;
                final opacity = (1 - _ringAnim.value).clamp(0.0, 1.0);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width:  s,
                    height: s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: DesignTokens.danger.withValues(alpha: opacity * 0.7),
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),

          // Second ripple ring (offset)
          if (widget.isListening)
            AnimatedBuilder(
              animation: _ringAnim,
              builder: (_, __) {
                final v = (_ringAnim.value + 0.5) % 1.0;
                final scale = 1.0 + v * 0.55;
                final opacity = (1 - v).clamp(0.0, 1.0);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width:  s,
                    height: s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: DesignTokens.danger.withValues(alpha: opacity * 0.5),
                        width: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),

          // Rotating shimmer ring
          AnimatedBuilder(
            animation: _rotateCtrl,
            builder: (_, __) => Transform.rotate(
              angle: _rotateCtrl.value * 2 * math.pi,
              child: Container(
                width:  s + 18,
                height: s + 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Colors.transparent,
                      _gradientColors[0].withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main orb
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Transform.scale(
              scale: _pulseAnim.value,
              child: Container(
                width:  s,
                height: s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _gradientColors[0].withValues(alpha: 0.9),
                      _gradientColors[1],
                    ],
                    center: const Alignment(-0.3, -0.3),
                    radius: 0.85,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:       _gradientColors[0].withValues(alpha: 0.45),
                      blurRadius:  widget.isListening ? 48 : 28,
                      spreadRadius: widget.isListening ? 8 : 2,
                    ),
                    BoxShadow(
                      color:       _gradientColors[1].withValues(alpha: 0.25),
                      blurRadius:  60,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.isListening ? '🔴' : widget.isSpeaking ? '🔊' : '🤖',
                    style: TextStyle(fontSize: s * 0.32),
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
