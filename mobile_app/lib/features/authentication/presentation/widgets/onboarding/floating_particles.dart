import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Ultra-premium floating particles / orbs background widget.
/// Draws layered translucent circles that drift and pulse continuously,
/// giving a deep 3-D depth illusion behind any gradient surface.
class FloatingParticles extends StatefulWidget {
  final List<Color> colors;
  final int particleCount;

  const FloatingParticles({
    super.key,
    required this.colors,
    this.particleCount = 18,
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with TickerProviderStateMixin {
  late final List<_Particle> _particles;
  late final List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(42);
    _particles = List.generate(widget.particleCount, (i) {
      return _Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: 12.0 + rng.nextDouble() * 64,
        opacity: 0.04 + rng.nextDouble() * 0.13,
        driftX: (rng.nextDouble() - 0.5) * 0.15,
        driftY: (rng.nextDouble() - 0.5) * 0.12,
        color: widget.colors[i % widget.colors.length],
        phaseOffset: rng.nextDouble(),
      );
    });

    _controllers = List.generate(widget.particleCount, (i) {
      final duration = Duration(
        milliseconds: 4000 + (_particles[i].phaseOffset * 5000).toInt(),
      );
      return AnimationController(vsync: this, duration: duration)
        ..repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(_controllers),
      builder: (_, __) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            controllers: _controllers,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double radius;
  final double opacity;
  final double driftX;
  final double driftY;
  final Color color;
  final double phaseOffset;

  const _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.opacity,
    required this.driftX,
    required this.driftY,
    required this.color,
    required this.phaseOffset,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final List<AnimationController> controllers;

  const _ParticlePainter({
    required this.particles,
    required this.controllers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];
      final t = controllers[i].value; // 0..1

      final cx = (p.x + p.driftX * t) * size.width;
      final cy = (p.y + p.driftY * t) * size.height;

      // Radial gradient for a glowing 3-D orb effect
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            p.color.withValues(alpha: p.opacity * (0.7 + 0.3 * t)),
            p.color.withValues(alpha: 0.0),
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(cx, cy),
            radius: p.radius * (0.85 + 0.15 * t),
          ),
        );

      canvas.drawCircle(
        Offset(cx, cy),
        p.radius * (0.85 + 0.15 * t),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => true;
}

// ── Floating 3-D geometric ring ──────────────────────────────────────────────
/// A softly spinning translucent ring — used as a decorative 3-D depth element.
class SpinningRing extends StatefulWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  final Duration duration;
  final bool clockwise;

  const SpinningRing({
    super.key,
    required this.size,
    required this.color,
    this.strokeWidth = 1.5,
    this.duration = const Duration(seconds: 12),
    this.clockwise = true,
  });

  @override
  State<SpinningRing> createState() => _SpinningRingState();
}

class _SpinningRingState extends State<SpinningRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: widget.clockwise ? _ctrl : Tween(begin: 1.0, end: 0.0).animate(_ctrl),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _RingPainter(
            color: widget.color,
            strokeWidth: widget.strokeWidth,
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _RingPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth;

    // Dashed arc for a premium look
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw 3/4 arc with a gap — gives a "C" shape that suggests 3-D rotation
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 1.75,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
