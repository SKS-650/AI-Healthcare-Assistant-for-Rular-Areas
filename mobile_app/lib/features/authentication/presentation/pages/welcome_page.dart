import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../routing/route_names.dart';
import '../widgets/onboarding/floating_particles.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Ultra-Premium Welcome / Auth Gateway  (dark-theme, matches splash+onboarding)
// ─────────────────────────────────────────────────────────────────────────────
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  // ── Entrance ──────────────────────────────────────────────────────────────
  late final AnimationController _enterCtrl;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _pillSlide;
  late final Animation<double> _pillFade;
  late final Animation<Offset> _btnSlide;
  late final Animation<double> _btnFade;

  // ── Ring rotation ─────────────────────────────────────────────────────────
  late final AnimationController _ringCtrl;

  // ── Logo pulse ────────────────────────────────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  // ── Button shimmer ────────────────────────────────────────────────────────
  late final AnimationController _shimmerCtrl;

  static const _bg = [
    Color(0xFF0D0628),
    Color(0xFF1A0E4F),
    Color(0xFF2A1280),
  ];

  static const _particles = [
    Color(0xFF926EFF),
    Color(0xFF4F94FF),
    Color(0xFFFF5E9E),
    Color(0xFF2ECC8B),
    Color(0xFF18C8C8),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoFade = CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    _logoScale = Tween(begin: 0.6, end: 1.0).animate(CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
    ));

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.25, 0.60, curve: Curves.easeOutCubic),
    ));
    _titleFade = CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
    );

    _pillSlide = Tween<Offset>(
      begin: const Offset(0, 0.30),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.42, 0.72, curve: Curves.easeOutCubic),
    ));
    _pillFade = CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.42, 0.68, curve: Curves.easeOut),
    );

    _btnSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.58, 0.90, curve: Curves.easeOutCubic),
    ));
    _btnFade = CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.58, 0.85, curve: Curves.easeOut),
    );

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulse = Tween(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _ringCtrl.dispose();
    _pulseCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: _bg.first,
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: _bg,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // particles
              const FloatingParticles(colors: _particles, particleCount: 18),

              // top-left glow blob
              const Positioned(
                top: -60, left: -40,
                child: _WBlob(radius: 220, color: Color(0xFF6B47E8), opacity: 0.18),
              ),
              // bottom-right glow blob
              const Positioned(
                bottom: 40, right: -60,
                child: _WBlob(radius: 200, color: Color(0xFF4F94FF), opacity: 0.14),
              ),

              SafeArea(child: _buildBody(size)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(Size size) {
    // Wrap in SingleChildScrollView so that on small phones the spacers
    // collapse gracefully and content is never clipped or overflowed.
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: ConstrainedBox(
        // Ensure the Column fills at least the full screen height so that
        // Spacers still push content apart on large phones.
        constraints: BoxConstraints(minHeight: size.height),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // ── Logo orb ─────────────────────────────────────────────────
              AnimatedBuilder(
                animation: Listenable.merge([_enterCtrl, _pulseCtrl]),
                builder: (_, __) => FadeTransition(
                  opacity: _logoFade,
                  child: Transform.scale(
                    scale: _logoScale.value * _pulse.value,
                    child: _LogoOrb(ringCtrl: _ringCtrl),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── App name ──────────────────────────────────────────────────
              SlideTransition(
                position: _titleSlide,
                child: FadeTransition(
                  opacity: _titleFade,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (b) => const LinearGradient(
                          colors: [Colors.white, Color(0xFFD4C8FF)],
                        ).createShader(b),
                        child: const Text(
                          'AI Healthcare',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                            height: 1.05,
                          ),
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (b) => const LinearGradient(
                          colors: [Color(0xFFB89EFF), Color(0xFF926EFF)],
                        ).createShader(b),
                        child: const Text(
                          'A S S I S T A N T',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 6,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Smart, accessible healthcare for everyone',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 13.5,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Feature pills ─────────────────────────────────────────────
              SlideTransition(
                position: _pillSlide,
                child: FadeTransition(
                  opacity: _pillFade,
                  child: const _FeaturePills(),
                ),
              ),

              const Spacer(flex: 3),

              // ── Auth buttons ──────────────────────────────────────────────
              SlideTransition(
                position: _btnSlide,
                child: FadeTransition(
                  opacity: _btnFade,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _AuthButtons(shimmerCtrl: _shimmerCtrl),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ── Terms ─────────────────────────────────────────────────────
              FadeTransition(
                opacity: _btnFade,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'By continuing you agree to our Terms & Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Colors.white.withValues(alpha: 0.28),
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Logo Orb — same style as splash, no emoji
// ─────────────────────────────────────────────────────────────────────────────
class _LogoOrb extends StatelessWidget {
  final AnimationController ringCtrl;
  const _LogoOrb({required this.ringCtrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160, height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow halo
          Container(
            width: 160, height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                const Color(0xFF926EFF).withValues(alpha: 0.32),
                const Color(0xFF4F94FF).withValues(alpha: 0.12),
                Colors.transparent,
              ], stops: const [0.0, 0.5, 1.0]),
            ),
          ),
          // Outer ring — counter-clockwise
          RotationTransition(
            turns: Tween(begin: 0.0, end: -1.0).animate(ringCtrl),
            child: SizedBox(
              width: 140, height: 140,
              child: CustomPaint(
                painter: _WRingPainter(
                  color: Colors.white.withValues(alpha: 0.16),
                  dashCount: 28,
                  strokeWidth: 1.2,
                ),
              ),
            ),
          ),
          // Inner ring — clockwise
          RotationTransition(
            turns: ringCtrl,
            child: SizedBox(
              width: 116, height: 116,
              child: CustomPaint(
                painter: _WRingPainter(
                  color: const Color(0xFF926EFF).withValues(alpha: 0.50),
                  dashCount: 16,
                  strokeWidth: 2.0,
                ),
              ),
            ),
          ),
          // Glass sphere
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF7B5EE8), Color(0xFF4228C8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF926EFF).withValues(alpha: 0.70),
                  blurRadius: 36,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.30),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.26),
                width: 1.5,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Specular
                Positioned(
                  top: 10, left: 12,
                  child: Container(
                    width: 24, height: 13,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(colors: [
                        Colors.white.withValues(alpha: 0.40),
                        Colors.transparent,
                      ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    ),
                  ),
                ),
                // Custom medical cross — no emoji
                CustomPaint(
                  size: const Size(40, 40),
                  painter: _WCrossPainter(),
                ),
              ],
            ),
          ),
          // Orbiting dots
          AnimatedBuilder(
            animation: ringCtrl,
            builder: (_, __) {
              final a = ringCtrl.value * 2 * math.pi;
              return Transform.translate(
                offset: Offset(math.cos(a) * 70, math.sin(a) * 70),
                child: const _WDot(color: Color(0xFF4F94FF), size: 9),
              );
            },
          ),
          AnimatedBuilder(
            animation: ringCtrl,
            builder: (_, __) {
              final a = (ringCtrl.value * 2 * math.pi) + math.pi;
              return Transform.translate(
                offset: Offset(math.cos(a) * 70, math.sin(a) * 70),
                child: const _WDot(color: Color(0xFFFF5E9E), size: 7),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Feature pills row
// ─────────────────────────────────────────────────────────────────────────────
class _FeaturePills extends StatelessWidget {
  const _FeaturePills();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.monitor_heart_rounded, 'Symptom Check', Color(0xFF926EFF)),
      (Icons.smart_toy_rounded,     'AI Chat',        Color(0xFF4F94FF)),
      (Icons.emergency_rounded,     'SOS Alert',      Color(0xFFFF4757)),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: items.map((item) {
        final (icon, label, color) = item;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: color.withValues(alpha: 0.12),
            border: Border.all(color: color.withValues(alpha: 0.28), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Auth buttons
// ─────────────────────────────────────────────────────────────────────────────
class _AuthButtons extends StatelessWidget {
  final AnimationController shimmerCtrl;
  const _AuthButtons({required this.shimmerCtrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Sign In — shimmer gradient button ────────────────────────────
        _ShimmerButton(
          label: 'Sign In',
          icon: Icons.login_rounded,
          shimmerCtrl: shimmerCtrl,
          onTap: () => Navigator.of(context).pushNamed(RouteNames.login),
        ),

        const SizedBox(height: 12),

        // ── Create Account — outlined ─────────────────────────────────────
        _OutlinedAuthButton(
          label: 'Create Account',
          icon: Icons.person_add_rounded,
          onTap: () => Navigator.of(context).pushNamed(RouteNames.register),
        ),

        const SizedBox(height: 10),

        // ── Guest ──────────────────────────────────────────────────────────
        _GhostButton(
          label: 'Continue as Guest',
          icon: Icons.visibility_rounded,
          onTap: () => Navigator.of(context).pushNamed(RouteNames.guestMode),
        ),
      ],
    );
  }
}

class _ShimmerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final AnimationController shimmerCtrl;
  final VoidCallback onTap;
  const _ShimmerButton({
    required this.label,
    required this.icon,
    required this.shimmerCtrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: shimmerCtrl,
        builder: (_, __) => Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF7B5EE8), Color(0xFF4F94FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF926EFF).withValues(alpha: 0.52),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // shimmer sweep
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Transform.translate(
                  offset: Offset(
                    (shimmerCtrl.value * 2 - 0.5) * MediaQuery.sizeOf(context).width,
                    0,
                  ),
                  child: Container(
                    width: 80, height: 54,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.transparent,
                        Color(0x25FFFFFF),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 19),
                  const SizedBox(width: 9),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlinedAuthButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _OutlinedAuthButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 19),
            const SizedBox(width: 9),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _GhostButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.45)),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Private painter helpers (scoped to welcome page)
// ─────────────────────────────────────────────────────────────────────────────

class _WCrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const t = 0.28; // arm thickness ratio
    const r = 6.0;

    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.white, Color(0xFFD4C8FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    // Horizontal bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, (h - h * t) / 2, w, h * t),
        const Radius.circular(r),
      ),
      paint,
    );
    // Vertical bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH((w - w * t) / 2, 0, w * t, h),
        const Radius.circular(r),
      ),
      paint,
    );
    // Pink center dot
    canvas.drawCircle(
      Offset(w / 2, h / 2),
      w * 0.07,
      Paint()..color = const Color(0xFFFF5E9E).withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _WRingPainter extends CustomPainter {
  final Color color;
  final int dashCount;
  final double strokeWidth;
  const _WRingPainter({
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
    final radius = size.width / 2 - strokeWidth;
    final step = (2 * math.pi) / dashCount;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * step, 0.12, false, paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WRingPainter old) =>
      old.color != color || old.dashCount != dashCount;
}

class _WDot extends StatelessWidget {
  final Color color;
  final double size;
  const _WDot({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
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

class _WBlob extends StatelessWidget {
  final double radius;
  final Color color;
  final double opacity;
  const _WBlob({required this.radius, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2, height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: opacity), Colors.transparent],
        ),
      ),
    );
  }
}
