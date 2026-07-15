import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated waveform bars — active when listening or speaking.
class WaveformBars extends StatefulWidget {
  final bool active;
  final Color color;
  final int barCount;
  final double height;

  const WaveformBars({
    super.key,
    required this.active,
    required this.color,
    this.barCount = 13,
    this.height = 56,
  });

  @override
  State<WaveformBars> createState() => _WaveformBarsState();
}

class _WaveformBarsState extends State<WaveformBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<Animation<double>> _anims;
  final _rng = math.Random(42);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _anims = List.generate(widget.barCount, (i) {
      final begin = 0.15 + _rng.nextDouble() * 0.25;
      final end   = 0.55 + _rng.nextDouble() * 0.45;
      final offset = _rng.nextDouble();
      return Tween<double>(begin: begin, end: end).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(
            (offset * 0.5).clamp(0, 0.5),
            ((offset * 0.5) + 0.5).clamp(0.5, 1.0),
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  void didUpdateWidget(WaveformBars old) {
    super.didUpdateWidget(old);
    if (widget.active && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.active && _ctrl.isAnimating) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(widget.barCount, (i) {
              final frac = widget.active ? _anims[i].value : 0.12;
              final barH = widget.height * frac;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 50),
                width:  5,
                height: barH,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: widget.active
                      ? widget.color.withValues(alpha: 0.4 + frac * 0.6)
                      : Colors.white12,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
