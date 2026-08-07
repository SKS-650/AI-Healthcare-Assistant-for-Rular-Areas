import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../routing/route_names.dart';
import '../providers/authentication_provider.dart';
import '../widgets/onboarding/floating_particles.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Ultra-Premium 3-D Animated Splash Screen
// ─────────────────────────────────────────────────────────────────────────────
class AuthSplashPage extends ConsumerStatefulWidget {
  const AuthSplashPage({super.key});

  @override
  ConsumerState<AuthSplashPage> createState() => _AuthSplashPageState();
}

class _AuthSplashPageState extends ConsumerState<AuthSplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _glowScale;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _tagSlide;
  late final Animation<double> _tagFade;
  late final Animation<double> _barFade;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  late final AnimationController _loadCtrl;
  late final AnimationController _ringCtrl;

  late final AnimationController _heartCtrl;
  late final Animation<double> _heartbeat;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _glowScale = Tween(begin: 0.4, end: 1.0).animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.05, 0.55, curve: Curves.easeOutCubic),
    ));

    _logoScale = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.1, 0.55, curve: Curves.elasticOut),
    ));

    _logoFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.1, 0.4, curve: Curves.easeOut),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.4, 0.75, curve: Curves.easeOutCubic),
    ));

    _titleFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
    );

    _tagSlide = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.55, 0.85, curve: Curves.easeOutCubic),
    ));

    _tagFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.55, 0.8, curve: Curves.easeOut),
    );

    _barFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _pulse = Tween(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _loadCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..forward();

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _heartbeat = Tween(begin: 0.88, end: 1.12).animate(
      CurvedAnimation(parent: _heartCtrl, curve: Curves.easeInOut),
    );

    _entranceCtrl.forward();
    Future.delayed(const Duration(milliseconds: 5500), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final repo = ref.read(authRepositoryProvider);

    // Always show onboarding on a fresh install.
    // A "fresh install" means no access token is stored.
    // If no token → force onboarding regardless of the seen flag.
    final hasToken = repo.accessToken != null && repo.accessToken!.isNotEmpty;
    final seenOnboarding = await repo.hasSeenOnboarding();

    if (!mounted) return;

    if (!hasToken && !seenOnboarding) {
      // Brand new user — show onboarding
      Navigator.of(context).pushReplacementNamed(RouteNames.onboarding);
    } else if (!hasToken && seenOnboarding) {
      // Reinstalled or logged out — show onboarding again for fresh experience
      await repo.resetOnboarding();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(RouteNames.onboarding);
    } else {
      // Logged-in returning user — go straight to welcome/home
      Navigator.of(context).pushReplacementNamed(RouteNames.welcome);
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _pulseCtrl.dispose();
    _loadCtrl.dispose();
    _ringCtrl.dispose();
    _heartCtrl.dispose();
    super.dispose();
  }

  static const _gradientColors = [
    Color(0xFF0D0628),
    Color(0xFF1A0E4F),
    Color(0xFF2A1280),
    Color(0xFF3D1FA8),
  ];

  static const _particleColors = [
    Color(0xFF926EFF),
    Color(0xFF4F94FF),
    Color(0xFFFF5E9E),
    Color(0xFF2ECC8B),
    Color(0xFF18C8C8),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: _gradientColors.first,
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: _gradientColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.3, 0.65, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // ── Floating particle orbs ─────────────────────────────────
              const FloatingParticles(colors: _particleColors, particleCount: 22),

              // ── Large background glow blobs ────────────────────────────
              _GlowBlob(
                offset: Offset(size.width * 0.05, size.height * 0.08),
                radius: 220,
                color: const Color(0xFF6B47E8),
                opacity: 0.28,
              ),
              _GlowBlob(
                offset: Offset(size.width * 0.80, size.height * 0.55),
                radius: 180,
                color: const Color(0xFF4F94FF),
                opacity: 0.22,
              ),
              _GlowBlob(
                offset: Offset(size.width * 0.4, size.height * 0.85),
                radius: 200,
                color: const Color(0xFF2ECC8B),
                opacity: 0.15,
              ),

              // ── Main content ───────────────────────────────────────────
              SafeArea(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Equal top spacer — push centre group to true vertical centre ──
        const Spacer(flex: 5),

        // ── 3-D Logo orb ─────────────────────────────────────────────────
        Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_entranceCtrl, _pulseCtrl]),
            builder: (_, __) => Opacity(
              opacity: _logoFade.value,
              child: Transform.scale(
                scale: _logoScale.value * _pulse.value,
                child: _Logo3D(
                  ringCtrl: _ringCtrl,
                  heartbeat: _heartbeat,
                  glowScale: _glowScale.value,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // ── App name ─────────────────────────────────────────────────────
        Center(
          child: AnimatedBuilder(
            animation: _entranceCtrl,
            builder: (_, child) => SlideTransition(
              position: _titleSlide,
              child: FadeTransition(opacity: _titleFade, child: child),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFFFFFF), Color(0xFFD4C8FF)],
                  ).createShader(bounds),
                  child: const Text(
                    'AI Healthcare',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                      height: 1.05,
                    ),
                  ),
                ),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFB89EFF), Color(0xFF926EFF)],
                  ).createShader(bounds),
                  child: const Text(
                    'A S S I S T A N T',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 6,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Tagline pill ─────────────────────────────────────────────────
        Center(
          child: AnimatedBuilder(
            animation: _entranceCtrl,
            builder: (_, child) => SlideTransition(
              position: _tagSlide,
              child: FadeTransition(opacity: _tagFade, child: child),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.eco_rounded, color: Color(0xFF2ECC8B), size: 15),
                  const SizedBox(width: 7),
                  Text(
                    'Smart health guidance, powered by AI',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Equal bottom spacer — mirrors top spacer ──────────────────────
        const Spacer(flex: 5),

        // ── Loading bar — pinned just above the bottom ────────────────────
        Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_barFade, _loadCtrl]),
            builder: (_, __) => Opacity(
              opacity: _barFade.value,
              child: _PremiumLoader(progress: _loadCtrl.value),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ── Made by ──────────────────────────────────────────────────────
        Center(
          child: AnimatedBuilder(
            animation: _barFade,
            builder: (_, child) =>
                FadeTransition(opacity: _barFade, child: child),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 11.5,
                  letterSpacing: 0.4,
                  color: Colors.white.withValues(alpha: 0.38),
                ),
                children: const [
                  TextSpan(text: 'Made by  '),
                  TextSpan(
                    text: 'SPN Empire',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB89EFF),
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        // ── Version badge ────────────────────────────────────────────────
        Center(
          child: AnimatedBuilder(
            animation: _barFade,
            builder: (_, child) =>
                FadeTransition(opacity: _barFade, child: child),
            child: Text(
              'v1.0.0  ·  AI-Powered Healthcare',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.32),
                fontSize: 11,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),

        const SizedBox(height: 28),
      ],
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
//  3-D Logo Orb  (custom-painted cross — no emoji rendering issues)
// ─────────────────────────────────────────────────────────────────────────────
class _Logo3D extends StatelessWidget {
  final AnimationController ringCtrl;
  final Animation<double> heartbeat;
  final double glowScale;

  const _Logo3D({
    required this.ringCtrl,
    required this.heartbeat,
    required this.glowScale,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Outer glow halo ───────────────────────────────────────────────
          Transform.scale(
            scale: glowScale,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF926EFF).withValues(alpha: 0.38),
                    const Color(0xFF4F94FF).withValues(alpha: 0.14),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // ── Outer dashed ring — counter-clockwise ────────────────────────
          RotationTransition(
            turns: Tween(begin: 0.0, end: -1.0).animate(ringCtrl),
            child: SizedBox(
              width: 182,
              height: 182,
              child: CustomPaint(
                painter: _DashedRingPainter(
                  color: Colors.white.withValues(alpha: 0.18),
                  dashCount: 30,
                  strokeWidth: 1.2,
                ),
              ),
            ),
          ),

          // ── Inner dashed ring — clockwise ────────────────────────────────
          RotationTransition(
            turns: Tween(begin: 0.0, end: 1.0).animate(ringCtrl),
            child: SizedBox(
              width: 156,
              height: 156,
              child: CustomPaint(
                painter: _DashedRingPainter(
                  color: const Color(0xFF926EFF).withValues(alpha: 0.55),
                  dashCount: 18,
                  strokeWidth: 2.0,
                ),
              ),
            ),
          ),

          // ── Glass sphere ─────────────────────────────────────────────────
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF7B5EE8), Color(0xFF4228C8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF926EFF).withValues(alpha: 0.72),
                  blurRadius: 44,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: const Color(0xFF4F94FF).withValues(alpha: 0.30),
                  blurRadius: 22,
                  offset: const Offset(6, 12),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.10),
                  blurRadius: 0,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.28),
                width: 1.5,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Specular highlight — top-left sheen
                Positioned(
                  top: 14,
                  left: 18,
                  child: Container(
                    width: 34,
                    height: 18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.42),
                          Colors.transparent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),

                // ── Custom medical cross (no emoji) ───────────────────────
                AnimatedBuilder(
                  animation: heartbeat,
                  builder: (_, child) => Transform.scale(
                    scale: heartbeat.value,
                    child: child,
                  ),
                  child: CustomPaint(
                    size: const Size(52, 52),
                    painter: _MedicalCrossPainter(),
                  ),
                ),
              ],
            ),
          ),

          // ── Orbiting dot — blue ──────────────────────────────────────────
          AnimatedBuilder(
            animation: ringCtrl,
            builder: (_, __) {
              final angle = ringCtrl.value * 2 * math.pi;
              const r = 91.0;
              return Transform.translate(
                offset: Offset(math.cos(angle) * r, math.sin(angle) * r),
                child: const _GlowDot(color: Color(0xFF4F94FF), size: 11),
              );
            },
          ),

          // ── Orbiting dot — pink (opposite) ───────────────────────────────
          AnimatedBuilder(
            animation: ringCtrl,
            builder: (_, __) {
              final angle = (ringCtrl.value * 2 * math.pi) + math.pi;
              const r = 91.0;
              return Transform.translate(
                offset: Offset(math.cos(angle) * r, math.sin(angle) * r),
                child: const _GlowDot(color: Color(0xFFFF5E9E), size: 8),
              );
            },
          ),

          // ── Orbiting dot — green (90° offset) ───────────────────────────
          AnimatedBuilder(
            animation: ringCtrl,
            builder: (_, __) {
              final angle = (ringCtrl.value * 2 * math.pi) + (math.pi / 2);
              const r = 88.0;
              return Transform.translate(
                offset: Offset(math.cos(angle) * r, math.sin(angle) * r),
                child: const _GlowDot(color: Color(0xFF2ECC8B), size: 6),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Medical cross painter — crisp vector, consistent on all Android versions
// ─────────────────────────────────────────────────────────────────────────────
class _MedicalCrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final t = w * 0.28; // arm thickness
    const r = 6.0;      // corner radius

    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFD4C8FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    // Shadow
    final shadowPaint = Paint()
      ..color = const Color(0xFF4A2FC4).withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // Horizontal bar
    final hBar = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, (h - t) / 2, w, t),
      const Radius.circular(r),
    );
    // Vertical bar
    final vBar = RRect.fromRectAndRadius(
      Rect.fromLTWH((w - t) / 2, 0, t, h),
      const Radius.circular(r),
    );

    // Draw shadow offset
    canvas.save();
    canvas.translate(2, 3);
    canvas.drawRRect(hBar, shadowPaint);
    canvas.drawRRect(vBar, shadowPaint);
    canvas.restore();

    // Draw cross
    canvas.drawRRect(hBar, paint);
    canvas.drawRRect(vBar, paint);

    // Heart pulse dot in the center
    final dotPaint = Paint()
      ..color = const Color(0xFFFF5E9E).withValues(alpha: 0.85);
    canvas.drawCircle(Offset(w / 2, h / 2), t * 0.22, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Glowing dot helper
// ─────────────────────────────────────────────────────────────────────────────
class _GlowDot extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowDot({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.85),
            blurRadius: size * 1.8,
            spreadRadius: size * 0.3,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Premium gradient loading bar
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumLoader extends StatelessWidget {
  final double progress;
  const _PremiumLoader({required this.progress});

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (progress) {
      < 0.35 => (Icons.bolt_rounded, 'Initializing systems…'),
      < 0.70 => (Icons.lock_rounded, 'Securing connection…'),
      _ => (Icons.check_circle_rounded, 'Ready to launch!'),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Track + fill
        SizedBox(
          width: 180,
          height: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Stack(
              children: [
                Container(color: Colors.white.withValues(alpha: 0.12)),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF926EFF),
                          Color(0xFF4F94FF),
                          Color(0xFF2ECC8B),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 11),
        // Status row — uses Icon widget, no emoji rendering issues
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.55)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 11.5,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Static glow blob (background decoration)
// ─────────────────────────────────────────────────────────────────────────────
class _GlowBlob extends StatelessWidget {
  final Offset offset;
  final double radius;
  final Color color;
  final double opacity;

  const _GlowBlob({
    required this.offset,
    required this.radius,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx - radius,
      top: offset.dy - radius,
      child: IgnorePointer(
        child: Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: opacity),
                color.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Dashed ring painter
// ─────────────────────────────────────────────────────────────────────────────
class _DashedRingPainter extends CustomPainter {
  final Color color;
  final int dashCount;
  final double strokeWidth;

  const _DashedRingPainter({
    required this.color,
    required this.dashCount,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth;
    final step = (2 * math.pi) / dashCount;
    const dashArc = 0.12;

    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * step,
        dashArc,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
