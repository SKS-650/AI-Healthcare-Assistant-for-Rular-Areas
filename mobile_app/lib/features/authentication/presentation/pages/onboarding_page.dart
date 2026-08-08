import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../routing/route_names.dart';
import '../../data/repositories/authentication_repository_impl.dart';
import '../providers/authentication_provider.dart';
import '../widgets/onboarding/floating_particles.dart';
import '../widgets/onboarding/onboarding_indicator.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Data model
// ─────────────────────────────────────────────────────────────────────────────

class _Chip {
  final IconData icon;
  final String label;
  const _Chip(this.icon, this.label);
}

class _Slide {
  final String badge;
  final String title;
  final String subtitle;
  final List<Color> bg;
  final List<Color> orb;
  final Color accent;
  final List<_Chip> chips;
  final _OrbIcon orbIcon;

  const _Slide({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.bg,
    required this.orb,
    required this.accent,
    required this.chips,
    required this.orbIcon,
  });
}

enum _OrbIcon { stethoscope, chatBot, emergency, education, prediction }

// ─────────────────────────────────────────────────────────────────────────────
//  Slide data — 5 screens
// ─────────────────────────────────────────────────────────────────────────────

const _slides = [
  _Slide(
    badge: 'SYMPTOM CHECKER',
    title: 'Smart\nDiagnosis AI',
    subtitle:
        'Describe any symptom and get instant AI-driven health insights — accurate, private, and personalised.',
    bg: [Color(0xFF0D0628), Color(0xFF1A0E4F), Color(0xFF2C1490)],
    orb: [Color(0xFF926EFF), Color(0xFF6B47E8), Color(0xFFB89EFF)],
    accent: Color(0xFF926EFF),
    chips: [
      _Chip(Icons.bolt_rounded, 'Instant Results'),
      _Chip(Icons.lock_rounded, 'Private & Secure'),
    ],
    orbIcon: _OrbIcon.stethoscope,
  ),
  _Slide(
    badge: 'AI CHATBOT',
    title: '24 / 7 Health\nAssistant',
    subtitle:
        'Chat with our intelligent medical assistant in your own language — anytime, anywhere, always on.',
    bg: [Color(0xFF06142A), Color(0xFF0A2550), Color(0xFF1040A0)],
    orb: [Color(0xFF4F94FF), Color(0xFF2563EB), Color(0xFF82B4FF)],
    accent: Color(0xFF4F94FF),
    chips: [
      _Chip(Icons.language_rounded, 'Multilingual'),
      _Chip(Icons.psychology_rounded, 'AI-Powered'),
      _Chip(Icons.wifi_off_rounded, 'Works Offline'),
    ],
    orbIcon: _OrbIcon.chatBot,
  ),
  _Slide(
    badge: 'EMERGENCY SOS',
    title: 'Life-Saving\nAlert System',
    subtitle:
        'One-tap SOS and real-time emergency detection — instantly connect to help when every second counts.',
    bg: [Color(0xFF1A0608), Color(0xFF3D0E12), Color(0xFF6B1A20)],
    orb: [Color(0xFFFF4757), Color(0xFFFF7B3D), Color(0xFFFF5E9E)],
    accent: Color(0xFFFF4757),
    chips: [
      _Chip(Icons.location_on_rounded, 'GPS Location'),
      _Chip(Icons.phone_rounded, 'One-Tap SOS'),
    ],
    orbIcon: _OrbIcon.emergency,
  ),
  _Slide(
    badge: 'HEALTH EDUCATION',
    title: 'Learn &\nStay Informed',
    subtitle:
        'Curated medical articles, expert health tips, and interactive lessons — grow your health IQ every day.',
    bg: [Color(0xFF0A1628), Color(0xFF102840), Color(0xFF1A4060)],
    orb: [Color(0xFF18C8C8), Color(0xFF1BB8A3), Color(0xFF5CDEDE)],
    accent: Color(0xFF18C8C8),
    chips: [
      _Chip(Icons.menu_book_rounded, 'Expert Articles'),
      _Chip(Icons.bookmark_rounded, 'Save & Read Later'),
      _Chip(Icons.translate_rounded, 'Multi-Language'),
    ],
    orbIcon: _OrbIcon.education,
  ),
  _Slide(
    badge: 'DISEASE PREDICTION',
    title: 'Predict Before\nIt Happens',
    subtitle:
        'Advanced ML models analyse your health data to flag disease risks early — stay one step ahead.',
    bg: [Color(0xFF061A14), Color(0xFF0A3328), Color(0xFF124A38)],
    orb: [Color(0xFF2ECC8B), Color(0xFF16A34A), Color(0xFF6EE8B5)],
    accent: Color(0xFF2ECC8B),
    chips: [
      _Chip(Icons.bar_chart_rounded, 'Risk Analysis'),
      _Chip(Icons.biotech_rounded, 'ML Models'),
      _Chip(Icons.trending_up_rounded, 'Health Trends'),
    ],
    orbIcon: _OrbIcon.prediction,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
//  OnboardingPage
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});
  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _current = 0;

  // Content entrance per slide
  late AnimationController _contentCtrl;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _contentScale;

  // Card slide-up
  late AnimationController _cardCtrl;
  late Animation<Offset> _cardSlide;
  late Animation<double> _cardFade;

  // Orb floating
  late AnimationController _floatCtrl;
  late Animation<double> _floatY;

  // Orb rings rotation
  late AnimationController _orbCtrl;

  // Button shimmer
  late AnimationController _shimmerCtrl;

  // Tilt / parallax on orb
  late AnimationController _tiltCtrl;
  late Animation<double> _tiltX;

  @override
  void initState() {
    super.initState();

    _contentCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
    _contentFade = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.20), end: Offset.zero)
        .animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic));
    _contentScale = Tween(begin: 0.86, end: 1.0)
        .animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutBack));

    _cardCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 580));
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));
    _cardFade = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);

    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))
      ..repeat(reverse: true);
    _floatY = Tween(begin: -11.0, end: 11.0)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _orbCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..repeat();

    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();

    _tiltCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 4000))
      ..repeat(reverse: true);
    _tiltX = Tween(begin: -0.06, end: 0.06)
        .animate(CurvedAnimation(parent: _tiltCtrl, curve: Curves.easeInOut));

    _contentCtrl.forward();
    _cardCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _contentCtrl.dispose();
    _cardCtrl.dispose();
    _floatCtrl.dispose();
    _orbCtrl.dispose();
    _shimmerCtrl.dispose();
    _tiltCtrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _current = page);
    _contentCtrl..reset()..forward();
    _cardCtrl..reset()..forward();
  }

  void _next() {
    if (_current < _slides.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final repo = ref.read(authRepositoryProvider) as AuthenticationRepositoryImpl;
    await repo.markOnboardingSeen();
    if (!mounted) return;

    // If already logged in, go straight to home.
    // Otherwise go to welcome (login/register screen).
    final hasToken = repo.accessToken != null && repo.accessToken!.isNotEmpty;
    Navigator.of(context).pushReplacementNamed(
      hasToken ? RouteNames.home : RouteNames.welcome,
    );
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_current];
    final isLast = _current == _slides.length - 1;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: slide.bg.first,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: slide.bg,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // ── Particles ────────────────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              child: FloatingParticles(
                key: ValueKey(_current),
                colors: slide.orb,
                particleCount: 22,
              ),
            ),

            // ── Background glow blob ─────────────────────────────────────
            Positioned(
              top: -80,
              left: -60,
              child: _GlowBlob(radius: 240, color: slide.accent, opacity: 0.14),
            ),
            Positioned(
              bottom: 100,
              right: -80,
              child: _GlowBlob(radius: 200, color: slide.orb.last, opacity: 0.12),
            ),

            // ── Content ──────────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  _TopBar(
                    current: _current,
                    total: _slides.length,
                    onSkip: _finish,
                    accentColor: slide.accent,
                  ),
                  _buildOrb(slide),
                  _buildCard(slide, isLast),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrb(_Slide slide) {
    return Expanded(
      flex: 5,
      child: PageView.builder(
        controller: _pageCtrl,
        onPageChanged: _onPageChanged,
        itemCount: _slides.length,
        itemBuilder: (_, i) {
          final s = _slides[i];
          return Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_contentCtrl, _floatCtrl, _tiltCtrl]),
              builder: (_, child) => SlideTransition(
                position: _contentSlide,
                child: FadeTransition(
                  opacity: _contentFade,
                  child: Transform.scale(
                    scale: _contentScale.value,
                    child: Transform.translate(
                      offset: Offset(0, _floatY.value),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(_tiltX.value),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
              child: _OrbWidget(
                slide: s,
                orbCtrl: _orbCtrl,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(_Slide slide, bool isLast) {
    return SlideTransition(
      position: _cardSlide,
      child: FadeTransition(
        opacity: _cardFade,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.11),
                Colors.white.withValues(alpha: 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.16), width: 1),
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.38),
                blurRadius: 36,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dot indicator + badge
              Row(
                children: [
                  PremiumOnboardingIndicator(
                    count: _slides.length,
                    current: _current,
                    activeColor: slide.accent,
                  ),
                  const Spacer(),
                  _BadgePill(label: slide.badge, color: slide.accent),
                ],
              ),

              const SizedBox(height: 16),

              // Title
              AnimatedBuilder(
                animation: _contentCtrl,
                builder: (_, child) => FadeTransition(
                  opacity: _contentFade,
                  child: SlideTransition(position: _contentSlide, child: child),
                ),
                child: ShaderMask(
                  shaderCallback: (b) => LinearGradient(
                    colors: [Colors.white, slide.accent.withValues(alpha: 0.80)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(b),
                  child: Text(
                    slide.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                      height: 1.18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 9),

              // Subtitle
              AnimatedBuilder(
                animation: _contentFade,
                builder: (_, child) => FadeTransition(opacity: _contentFade, child: child),
                child: Text(
                  slide.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 13,
                    height: 1.62,
                    letterSpacing: 0.1,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Chips
              AnimatedBuilder(
                animation: _contentFade,
                builder: (_, child) => FadeTransition(opacity: _contentFade, child: child),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: slide.chips
                      .map((c) => _ChipWidget(chip: c, accent: slide.accent))
                      .toList(),
                ),
              ),

              const SizedBox(height: 20),

              // CTA
              _CTAButton(
                isLast: isLast,
                accent: slide.accent,
                orbColors: slide.orb,
                shimmerCtrl: _shimmerCtrl,
                onTap: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Top bar: page counter + premium Skip button
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final int current;
  final int total;
  final VoidCallback onSkip;
  final Color accentColor;

  const _TopBar({
    required this.current,
    required this.total,
    required this.onSkip,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Page pill
          AnimatedContainer(
            duration: const Duration(milliseconds: 380),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white.withValues(alpha: 0.09),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor,
                    boxShadow: [
                      BoxShadow(color: accentColor.withValues(alpha: 0.7), blurRadius: 6),
                    ],
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  '${current + 1}  /  $total',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          // Skip button
          GestureDetector(
            onTap: onSkip,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white.withValues(alpha: 0.07),
                border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.62),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 11, color: Colors.white.withValues(alpha: 0.50)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  3-D Orb widget with custom icon painter per slide
// ─────────────────────────────────────────────────────────────────────────────

class _OrbWidget extends StatelessWidget {
  final _Slide slide;
  final AnimationController orbCtrl;

  const _OrbWidget({required this.slide, required this.orbCtrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outermost halo
          Container(
            width: 250, height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                slide.accent.withValues(alpha: 0.22),
                slide.accent.withValues(alpha: 0.07),
                Colors.transparent,
              ], stops: const [0.0, 0.5, 1.0]),
            ),
          ),

          // Outer ring — clockwise
          RotationTransition(
            turns: orbCtrl,
            child: SizedBox(
              width: 218, height: 218,
              child: CustomPaint(
                painter: _DashedRing(
                  color: slide.accent.withValues(alpha: 0.28),
                  dashCount: 40,
                  strokeWidth: 1.0,
                ),
              ),
            ),
          ),

          // Middle ring — counter-clockwise
          RotationTransition(
            turns: Tween(begin: 0.0, end: -1.0).animate(orbCtrl),
            child: SizedBox(
              width: 186, height: 186,
              child: CustomPaint(
                painter: _DashedRing(
                  color: Colors.white.withValues(alpha: 0.13),
                  dashCount: 24,
                  strokeWidth: 1.5,
                ),
              ),
            ),
          ),

          // Inner accent ring — faster clockwise
          RotationTransition(
            turns: Tween(begin: 0.0, end: 2.0).animate(orbCtrl),
            child: SizedBox(
              width: 162, height: 162,
              child: CustomPaint(
                painter: _DashedRing(
                  color: slide.accent.withValues(alpha: 0.45),
                  dashCount: 14,
                  strokeWidth: 2.2,
                ),
              ),
            ),
          ),

          // Sphere
          Container(
            width: 130, height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  slide.orb[0].withValues(alpha: 0.92),
                  slide.orb.length > 1 ? slide.orb[1] : slide.orb[0],
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: slide.accent.withValues(alpha: 0.68),
                  blurRadius: 52,
                  spreadRadius: 6,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.32),
                  blurRadius: 22,
                  offset: const Offset(0, 14),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.08),
                  blurRadius: 0,
                  spreadRadius: 2,
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
                // Specular sheen
                Positioned(
                  top: 16, left: 20,
                  child: Container(
                    width: 38, height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(colors: [
                        Colors.white.withValues(alpha: 0.42),
                        Colors.transparent,
                      ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    ),
                  ),
                ),
                // Custom vector icon
                CustomPaint(
                  size: const Size(58, 58),
                  painter: _SlideIconPainter(slide.orbIcon, slide.accent),
                ),
              ],
            ),
          ),

          // Three orbiting dots at 120° apart
          ...List.generate(3, (i) {
            return AnimatedBuilder(
              animation: orbCtrl,
              builder: (_, __) {
                final base = orbCtrl.value * 2 * math.pi;
                final offset = (2 * math.pi / 3) * i;
                final angle = base + offset;
                const r = 108.0;
                final dotColors = [slide.accent, slide.orb.last, Colors.white70];
                final sizes = [11.0, 8.0, 6.0];
                return Transform.translate(
                  offset: Offset(math.cos(angle) * r, math.sin(angle) * r),
                  child: _GlowDot(color: dotColors[i], size: sizes[i]),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Custom vector icon painter — one per slide, no emoji
// ─────────────────────────────────────────────────────────────────────────────

class _SlideIconPainter extends CustomPainter {
  final _OrbIcon icon;
  final Color accent;
  const _SlideIconPainter(this.icon, this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    switch (icon) {
      case _OrbIcon.stethoscope:
        _paintStethoscope(canvas, size);
      case _OrbIcon.chatBot:
        _paintChatBot(canvas, size);
      case _OrbIcon.emergency:
        _paintEmergency(canvas, size);
      case _OrbIcon.education:
        _paintEducation(canvas, size);
      case _OrbIcon.prediction:
        _paintPrediction(canvas, size);
    }
  }

  Paint _fill(Color c) => Paint()..color = c..style = PaintingStyle.fill;
  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round;

  // ── Stethoscope (medical cross + circle at bottom) ────────────────────────
  void _paintStethoscope(Canvas canvas, Size s) {
    final w = s.width; final h = s.height;
    final p = _stroke(Colors.white, w * 0.095);

    // Vertical bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.44, h * 0.08, w * 0.12, h * 0.52),
        Radius.circular(w * 0.06),
      ),
      _fill(Colors.white),
    );
    // Horizontal bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.20, h * 0.30, w * 0.60, h * 0.12),
        Radius.circular(w * 0.06),
      ),
      _fill(Colors.white),
    );
    // Pink center dot
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.50),
      w * 0.07,
      _fill(const Color(0xFFFF5E9E)),
    );
    // Bottom circle (earpiece)
    canvas.drawCircle(Offset(w * 0.50, h * 0.84), w * 0.12, p);
    canvas.drawCircle(Offset(w * 0.50, h * 0.84), w * 0.05, _fill(accent));
  }

  // ── Chat bot (speech bubble + dots) ──────────────────────────────────────
  void _paintChatBot(Canvas canvas, Size s) {
    final w = s.width; final h = s.height;

    // Main bubble
    final bubblePath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.10, w * 0.84, h * 0.58),
        Radius.circular(w * 0.18),
      ));
    canvas.drawPath(bubblePath, _fill(Colors.white.withValues(alpha: 0.22)));
    canvas.drawPath(bubblePath, _stroke(Colors.white, w * 0.04));

    // Tail
    final tail = Path()
      ..moveTo(w * 0.22, h * 0.68)
      ..lineTo(w * 0.15, h * 0.82)
      ..lineTo(w * 0.36, h * 0.68)
      ..close();
    canvas.drawPath(tail, _fill(Colors.white.withValues(alpha: 0.22)));
    canvas.drawPath(tail, _stroke(Colors.white, w * 0.04));

    // Three dots inside bubble
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(w * (0.32 + i * 0.18), h * 0.39),
        w * 0.065,
        _fill(Colors.white),
      );
    }
  }

  // ── Emergency (cross + pulse line) ────────────────────────────────────────
  void _paintEmergency(Canvas canvas, Size s) {
    final w = s.width; final h = s.height;

    // White cross
    final t = w * 0.22;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.40, h * 0.08, t, h * 0.56),
        Radius.circular(t * 0.3),
      ),
      _fill(Colors.white),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.16, h * 0.32, w * 0.68, t),
        Radius.circular(t * 0.3),
      ),
      _fill(Colors.white),
    );

    // Red glow center
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.36),
      w * 0.09,
      _fill(const Color(0xFFFF4757).withValues(alpha: 0.9)),
    );

    // EKG pulse line at bottom
    final ekgP = _stroke(accent, w * 0.055);
    final ekgPath = Path()
      ..moveTo(w * 0.08, h * 0.82)
      ..lineTo(w * 0.28, h * 0.82)
      ..lineTo(w * 0.36, h * 0.68)
      ..lineTo(w * 0.43, h * 0.92)
      ..lineTo(w * 0.50, h * 0.64)
      ..lineTo(w * 0.57, h * 0.82)
      ..lineTo(w * 0.92, h * 0.82);
    canvas.drawPath(ekgPath, ekgP);
  }

  // ── Education (open book) ─────────────────────────────────────────────────
  void _paintEducation(Canvas canvas, Size s) {
    final w = s.width; final h = s.height;
    final p = _stroke(Colors.white, w * 0.055);

    // Left page
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(w * 0.06, h * 0.20, w * 0.40, h * 0.58),
        topLeft: Radius.circular(w * 0.08),
        bottomLeft: Radius.circular(w * 0.08),
      ),
      _fill(Colors.white.withValues(alpha: 0.18)),
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(w * 0.06, h * 0.20, w * 0.40, h * 0.58),
        topLeft: Radius.circular(w * 0.08),
        bottomLeft: Radius.circular(w * 0.08),
      ),
      p,
    );
    // Right page
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(w * 0.54, h * 0.20, w * 0.40, h * 0.58),
        topRight: Radius.circular(w * 0.08),
        bottomRight: Radius.circular(w * 0.08),
      ),
      _fill(Colors.white.withValues(alpha: 0.18)),
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(w * 0.54, h * 0.20, w * 0.40, h * 0.58),
        topRight: Radius.circular(w * 0.08),
        bottomRight: Radius.circular(w * 0.08),
      ),
      p,
    );
    // Spine line
    canvas.drawLine(Offset(w * 0.50, h * 0.20), Offset(w * 0.50, h * 0.78), p);
    // Lines on left page
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(w * 0.13, h * (0.34 + i * 0.12)),
        Offset(w * 0.42, h * (0.34 + i * 0.12)),
        _stroke(Colors.white.withValues(alpha: 0.5), w * 0.035),
      );
    }
    // Accent bookmark on right page
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.64, h * 0.20, w * 0.10, h * 0.22),
        Radius.circular(w * 0.02),
      ),
      _fill(accent),
    );
  }

  // ── Prediction (bar chart + trend arrow) ──────────────────────────────────
  void _paintPrediction(Canvas canvas, Size s) {
    final w = s.width; final h = s.height;

    // Bars
    final barData = [0.40, 0.65, 0.30, 0.80, 0.55];
    for (int i = 0; i < barData.length; i++) {
      final bh = h * barData[i] * 0.70;
      final bx = w * (0.10 + i * 0.17);
      final isHigh = barData[i] >= 0.65;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, h * 0.78 - bh, w * 0.10, bh),
          Radius.circular(w * 0.04),
        ),
        _fill(isHigh ? accent : Colors.white.withValues(alpha: 0.55)),
      );
    }

    // Trend line
    final linePaint = _stroke(accent, w * 0.05);
    final path = Path()
      ..moveTo(w * 0.10, h * 0.62)
      ..lineTo(w * 0.27, h * 0.42)
      ..lineTo(w * 0.44, h * 0.55)
      ..lineTo(w * 0.61, h * 0.28)
      ..lineTo(w * 0.78, h * 0.18);
    canvas.drawPath(path, linePaint);

    // Arrow head
    final arrowPaint = _fill(accent);
    final arrow = Path()
      ..moveTo(w * 0.78, h * 0.10)
      ..lineTo(w * 0.86, h * 0.22)
      ..lineTo(w * 0.70, h * 0.22)
      ..close();
    canvas.drawPath(arrow, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant _SlideIconPainter old) => old.icon != icon;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _BadgePill extends StatelessWidget {
  final String label;
  final Color color;
  const _BadgePill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: color.withValues(alpha: 0.18),
        border: Border.all(color: color.withValues(alpha: 0.38), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _ChipWidget extends StatelessWidget {
  final _Chip chip;
  final Color accent;
  const _ChipWidget({required this.chip, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white.withValues(alpha: 0.07),
        border: Border.all(color: Colors.white.withValues(alpha: 0.13), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chip.icon, size: 13, color: accent),
          const SizedBox(width: 5),
          Text(
            chip.label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowDot extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowDot({required this.color, required this.size});

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

class _GlowBlob extends StatelessWidget {
  final double radius;
  final Color color;
  final double opacity;
  const _GlowBlob({required this.radius, required this.color, required this.opacity});

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

// ─────────────────────────────────────────────────────────────────────────────
//  Premium CTA button with shimmer
// ─────────────────────────────────────────────────────────────────────────────

class _CTAButton extends StatelessWidget {
  final bool isLast;
  final Color accent;
  final List<Color> orbColors;
  final AnimationController shimmerCtrl;
  final VoidCallback onTap;

  const _CTAButton({
    required this.isLast,
    required this.accent,
    required this.orbColors,
    required this.shimmerCtrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: shimmerCtrl,
        builder: (_, __) {
          return Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [
                  orbColors[0],
                  orbColors.length > 1 ? orbColors[1] : orbColors[0],
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.52),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Shimmer sweep
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
                          Color(0x2EFFFFFF),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                  ),
                ),
                // Label
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLast) ...[
                      const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      isLast ? 'Get Started' : 'Continue',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (!isLast) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 17),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Dashed ring painter
// ─────────────────────────────────────────────────────────────────────────────

class _DashedRing extends CustomPainter {
  final Color color;
  final int dashCount;
  final double strokeWidth;

  const _DashedRing({
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
    const dashArc = 0.10;

    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * step, dashArc, false, paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRing old) =>
      old.color != color || old.dashCount != dashCount;
}
