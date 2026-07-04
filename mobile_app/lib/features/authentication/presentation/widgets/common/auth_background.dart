import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../shared/design_system/design_tokens.dart';

/// Decorative soft purple background with floating blob shapes.
class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base colour
        const ColoredBox(color: DesignTokens.background),

        // Top-right large blob
        Positioned(
          top: -80,
          right: -80,
          child: _Blob(
            size: 280,
            color: DesignTokens.primary.withValues(alpha: 0.08),
          ),
        ),

        // Top-left small blob
        Positioned(
          top: 60,
          left: -60,
          child: _Blob(
            size: 160,
            color: DesignTokens.primaryLight.withValues(alpha: 0.07),
          ),
        ),

        // Bottom-left blob
        Positioned(
          bottom: -100,
          left: -60,
          child: _Blob(
            size: 300,
            color: DesignTokens.primary.withValues(alpha: 0.06),
          ),
        ),

        // Bottom-right small blob
        Positioned(
          bottom: 80,
          right: -40,
          child: _Blob(
            size: 140,
            color: DesignTokens.blue.withValues(alpha: 0.06),
          ),
        ),

        // Content
        child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BlobPainter(color: color),
    );
  }
}

class _BlobPainter extends CustomPainter {
  final Color color;
  const _BlobPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w * 0.5, 0);
    path.cubicTo(w * 0.85, 0, w, h * 0.2, w * 0.95, h * 0.5);
    path.cubicTo(w * 0.9, h * 0.8, w * 0.7, h, w * 0.5, h);
    path.cubicTo(w * 0.25, h, 0, h * 0.78, 0, h * 0.5);
    path.cubicTo(0, h * 0.2, w * 0.15, 0, w * 0.5, 0);
    path.close();

    // Rotate slightly for variety using a canvas save/restore approach
    canvas.save();
    canvas.translate(w / 2, h / 2);
    canvas.rotate(math.pi / 6);
    canvas.translate(-w / 2, -h / 2);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
