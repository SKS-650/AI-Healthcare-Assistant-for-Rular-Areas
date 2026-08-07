/// Ultra-premium Home Dashboard — AI Healthcare Assistant
///
/// Design language:
///   • Glassmorphism hero with animated purple→blue gradient
///   • Staggered flutter_animate entry animations
///   • Animated health-score arc ring with floating effect
///   • Horizontal scrolling cards for tips, articles, predictions
///   • 6-colour Quick Action grid with floating icon animation
///   • Soft section labels with gradient "See all" pill
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../routing/route_names.dart';
import '../../../../shared/design_system/design_tokens.dart';
import '../../../authentication/presentation/providers/authentication_provider.dart';
import '../../../offline/presentation/widgets/offline_status_banner.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/health_score.dart';
import '../../domain/entities/prediction.dart';
import '../../domain/entities/weather.dart';
import '../controller/dashboard_state.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/app_bar/dashboard_app_bar.dart';
import '../widgets/bottom_navigation/home_bottom_navigation.dart';
import '../widgets/emergency/emergency_card.dart';
import '../widgets/guest/guest_banner.dart';
import '../widgets/quick_actions/quick_action_grid.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Root page
// ─────────────────────────────────────────────────────────────────────────────

class HomeDashboardPage extends ConsumerWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: DesignTokens.background,
      appBar: const DashboardAppBar(),
      bottomNavigationBar: const HomeBottomNavigation(),
      body: SafeArea(
        child: Column(
          children: [
            const OfflineStatusBanner(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 380),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _buildBody(context, ref, state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, DashboardState state) {
    if (state.status == DashboardStatus.loading ||
        state.status == DashboardStatus.initial) {
      return const _PremiumSkeletonLoader(key: ValueKey('loading'));
    }
    if (state.status == DashboardStatus.error) {
      return _ErrorView(
        key: const ValueKey('error'),
        message: state.errorMessage,
        onRetry: () =>
            ref.read(dashboardControllerProvider.notifier).loadDashboardData(),
      );
    }

    final isGuest = ref.watch(
      authControllerProvider.select((s) => s.user?.isGuest ?? false),
    );
    final userName = ref.watch(
      authControllerProvider.select((s) {
        final u = s.user;
        if (u == null || u.isGuest) return null;
        return u.name ?? u.email.split('@').first;
      }),
    );

    return RefreshIndicator(
      key: const ValueKey('loaded'),
      color: DesignTokens.primary,
      backgroundColor: DesignTokens.surface,
      displacement: 60,
      onRefresh: () =>
          ref.read(dashboardControllerProvider.notifier).loadDashboardData(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                    maxWidth: DesignTokens.maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero gradient header ─────────────────────────
                    _HeroHeader(
                      weather: state.weather,
                      healthScore: state.healthScore,
                      userName: userName,
                      isGuest: isGuest,
                    ),

                    // ── Guest CTA ────────────────────────────────────
                    if (isGuest) const GuestBanner(),

                    // ── Quick actions ────────────────────────────────
                    const _SectionLabel(
                      title: 'Quick Actions',
                      emoji: '⚡',
                      delay: 200,
                    ),
                    QuickActionGrid(actions: state.quickActions)
                        .animate(delay: 220.ms)
                        .fadeIn(duration: 450.ms)
                        .slideY(begin: 0.08, end: 0,
                            curve: Curves.easeOutCubic),

                    const SizedBox(height: 8),

                    // ── SOS emergency card ───────────────────────────
                    const EmergencyCard()
                        .animate(delay: 320.ms)
                        .fadeIn(duration: 350.ms)
                        .slideY(begin: 0.06, end: 0),

                    // ── Recent predictions ───────────────────────────
                    if (state.recentPredictions.isNotEmpty) ...[
                      _SectionLabel(
                        title: 'Recent Assessments',
                        emoji: '🧬',
                        delay: 380,
                        onSeeAll: () => Navigator.of(context)
                            .pushNamed(RouteNames.history),
                      ),
                      _PredictionsStrip(
                          predictions: state.recentPredictions)
                          .animate(delay: 400.ms)
                          .fadeIn(duration: 350.ms),
                    ],

                    // ── Health tips ──────────────────────────────────
                    if (state.healthTips.isNotEmpty) ...[
                      const _SectionLabel(
                        title: 'Daily Health Tips',
                        emoji: '💡',
                        delay: 450,
                        accentColor: Color(0xFF00C9A7),
                      ),
                      _TipsStrip(tips: state.healthTips)
                          .animate(delay: 470.ms)
                          .fadeIn(duration: 350.ms),
                    ],

                    // ── Latest articles ──────────────────────────────
                    if (state.latestArticles.isNotEmpty) ...[
                      _SectionLabel(
                        title: 'Health Articles',
                        emoji: '📚',
                        delay: 560,
                        accentColor: const Color(0xFF6B47E8),
                        onSeeAll: () => Navigator.of(context)
                            .pushNamed(RouteNames.healthEducation),
                      ),
                      _ArticlesStrip(articles: state.latestArticles)
                          .animate(delay: 580.ms)
                          .fadeIn(duration: 350.ms),
                    ],

                    const SizedBox(height: 40),
                  ],
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
// Hero Header — gradient + weather pill + animated score ring
// ─────────────────────────────────────────────────────────────────────────────

class _HeroHeader extends StatefulWidget {
  const _HeroHeader({
    required this.weather,
    required this.healthScore,
    required this.userName,
    required this.isGuest,
  });
  final Weather?     weather;
  final HealthScore? healthScore;
  final String?      userName;
  final bool         isGuest;

  @override
  State<_HeroHeader> createState() => _HeroHeaderState();
}

class _HeroHeaderState extends State<_HeroHeader>
    with TickerProviderStateMixin {
  late AnimationController _scoreCtrl;
  late Animation<double>   _scoreAnim;
  late AnimationController _shimmerCtrl;
  late Animation<double>   _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _scoreCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600));
    _scoreAnim = Tween<double>(
            begin: 0,
            end: (widget.healthScore?.score ?? 0) / 100.0)
        .animate(
            CurvedAnimation(parent: _scoreCtrl, curve: Curves.easeOutCubic));

    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat();
    _shimmerAnim = Tween<double>(begin: -1.5, end: 2.5)
        .animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.linear));

    Future.delayed(const Duration(milliseconds: 300), _scoreCtrl.forward);
  }

  @override
  void dispose() {
    _scoreCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning ☀️';
    if (h < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.isGuest ? 'Guest' : (widget.userName ?? 'there');

    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (_, child) => Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: const [
              Color(0xFF6B47E8),
              Color(0xFF9161FF),
              Color(0xFF4F94FF),
            ],
            begin: Alignment(_shimmerAnim.value - 1, -0.5),
            end: Alignment(_shimmerAnim.value, 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B47E8).withValues(alpha: 0.45),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: const Color(0xFF4F94FF).withValues(alpha: 0.20),
              blurRadius: 60,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: child,
      ),
      child: Stack(
        children: [
          // Decorative orbs
          const Positioned(right: -30, top: -30,
              child: _GlowOrb(size: 150, opacity: 0.09)),
          const Positioned(left: -20, bottom: -20,
              child: _GlowOrb(size: 110, opacity: 0.07)),
          const Positioned(right: 70, bottom: 8,
              child: _GlowOrb(size: 50, opacity: 0.10)),

          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting + score ring
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_greeting(),
                                style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.82),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500))
                                .animate(delay: 60.ms)
                                .fadeIn(duration: 500.ms),
                            const SizedBox(height: 4),
                            Text(name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 27,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.6,
                                    height: 1.1),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis)
                                .animate(delay: 90.ms)
                                .fadeIn(duration: 500.ms)
                                .slideX(begin: -0.06, end: 0),
                            const SizedBox(height: 12),
                            if (widget.weather != null)
                              _WeatherPill(weather: widget.weather!)
                                  .animate(delay: 150.ms)
                                  .fadeIn(duration: 450.ms)
                                  .slideY(begin: 0.15, end: 0),
                          ],
                        ),
                      ),
                      if (widget.healthScore != null)
                        AnimatedBuilder(
                          animation: _scoreAnim,
                          builder: (_, __) => _ScoreRing(
                            animatedValue: _scoreAnim.value,
                            score: widget.healthScore!.score,
                            status: widget.healthScore!.status,
                          ),
                        ).animate(delay: 120.ms).fadeIn(duration: 500.ms),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Stats row
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18)),
                    ),
                    child: Row(
                      children: [
                        _HeroStat(
                            emoji: '❤️',
                            label: 'Health',
                            value:
                                '${widget.healthScore?.score ?? "--"}/100')
                            .animate(delay: 200.ms)
                            .fadeIn(duration: 400.ms),
                        _vDivider(),
                        _HeroStat(
                            emoji: '🌡️',
                            label: 'Temp',
                            value: widget.weather != null
                                ? '${widget.weather!.temperature.toStringAsFixed(0)}°C'
                                : '--°C')
                            .animate(delay: 240.ms)
                            .fadeIn(duration: 400.ms),
                        _vDivider(),
                        _HeroStat(
                            emoji: '💧',
                            label: 'Humidity',
                            value: widget.weather != null
                                ? '${widget.weather!.humidity}%'
                                : '--%')
                            .animate(delay: 280.ms)
                            .fadeIn(duration: 400.ms),
                      ],
                    ),
                  ).animate(delay: 180.ms).fadeIn(duration: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 550.ms, delay: 50.ms)
        .slideY(begin: -0.06, end: 0,
            duration: 550.ms, curve: Curves.easeOutCubic);
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 30,
        color: Colors.white.withValues(alpha: 0.22),
        margin: const EdgeInsets.symmetric(horizontal: 16),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.opacity});
  final double size;
  final double opacity;
  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      );
}

class _WeatherPill extends StatelessWidget {
  const _WeatherPill({required this.weather});
  final Weather weather;

  String _emoji(String c) {
    final s = c.toLowerCase();
    if (s.contains('sun') || s.contains('clear')) return '☀️';
    if (s.contains('cloud')) return '⛅';
    if (s.contains('rain')) return '🌧️';
    if (s.contains('storm')) return '⛈️';
    if (s.contains('fog') || s.contains('mist')) return '🌫️';
    if (s.contains('snow')) return '❄️';
    return '🌤️';
  }

  @override
  Widget build(BuildContext context) {
    final aqiColor = weather.aqi < 50
        ? Colors.greenAccent
        : weather.aqi < 100
            ? Colors.yellowAccent
            : Colors.orangeAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(_emoji(weather.condition),
            style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            '${weather.condition}  •  ${weather.location}',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.93),
                fontSize: 12,
                fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: aqiColor.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('AQI ${weather.aqi}',
              style: TextStyle(
                  color: aqiColor, fontSize: 10, fontWeight: FontWeight.w800)),
        ),
      ]),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({
    required this.animatedValue,
    required this.score,
    required this.status,
  });
  final double animatedValue;
  final int    score;
  final String status;

  List<Color> _colors() {
    if (score >= 80) return [const Color(0xFF2ECC8B), const Color(0xFF16A34A)];
    if (score >= 60) return [const Color(0xFFFFB829), const Color(0xFFD98E00)];
    if (score >= 40) return [const Color(0xFFFF7B3D), const Color(0xFFE55A1A)];
    return [const Color(0xFFFF4757), const Color(0xFFCC2233)];
  }

  @override
  Widget build(BuildContext context) {
    final cols = _colors();
    return Container(
      width: 92, height: 92,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.22), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: cols[0].withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: CustomPaint(
        painter: _ArcPainter(value: animatedValue, colors: cols),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('$score',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    height: 1.0)),
            Text(status.split(' ').first,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 9,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.value, required this.colors});
  final double      value;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final c      = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 7;
    final rect   = Rect.fromCircle(center: c, radius: radius);

    canvas.drawArc(
      rect, -math.pi * 0.75, math.pi * 1.5, false,
      Paint()
        ..color       = Colors.white.withValues(alpha: 0.18)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap   = StrokeCap.round,
    );
    if (value <= 0) return;
    canvas.drawArc(
      rect, -math.pi * 0.75, math.pi * 1.5 * value, false,
      Paint()
        ..shader = SweepGradient(
          colors: colors,
          startAngle: -math.pi * 0.75,
          endAngle:   -math.pi * 0.75 + math.pi * 1.5 * value,
        ).createShader(rect)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap   = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.value != value;
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.emoji,
    required this.label,
    required this.value,
  });
  final String emoji, label, value;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800)),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 10,
                  fontWeight: FontWeight.w500)),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label  —  gradient pill "See all" button
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.title,
    required this.emoji,
    required this.delay,
    this.onSeeAll,
    this.accentColor,
  });
  final String        title;
  final String        emoji;
  final int           delay;
  final VoidCallback? onSeeAll;
  final Color?        accentColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? DesignTokens.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            // Glowing emoji bubble
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: 0.22),
                    accent.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: accent.withValues(alpha: 0.20), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                  child: Text(emoji,
                      style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: DesignTokens.textStrong)),
                const SizedBox(height: 2),
                Container(
                  height: 2.5, width: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [accent, accent.withValues(alpha: 0.0)]),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ],
            ),
          ]),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent,
                      Color.lerp(accent, DesignTokens.primaryDark, 0.4)!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('See all',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded,
                      size: 12, color: Colors.white),
                ]),
              ),
            ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 380.ms)
        .slideX(begin: -0.04, end: 0, curve: Curves.easeOut);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent Predictions strip
// ─────────────────────────────────────────────────────────────────────────────

class _PredictionsStrip extends StatelessWidget {
  const _PredictionsStrip({required this.predictions});
  final List<Prediction> predictions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: predictions.length,
        itemBuilder: (ctx, i) =>
            _PredictionCard(prediction: predictions[i], index: i),
      ),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  const _PredictionCard({required this.prediction, required this.index});
  final Prediction prediction;
  final int        index;

  static const _gradients = [
    [Color(0xFF9B5DE5), Color(0xFF6B21A8)],
    [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    [Color(0xFF10B981), Color(0xFF065F46)],
    [Color(0xFFF97316), Color(0xFFC2410C)],
    [Color(0xFFEC4899), Color(0xFF9D174D)],
  ];

  @override
  Widget build(BuildContext context) {
    final grad = _gradients[index % _gradients.length];
    final pct  = (prediction.confidence * 100).toStringAsFixed(0);

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(RouteNames.history),
      child: Container(
        width: 172,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: grad.map((c) => c.withValues(alpha: 0.10)).toList()),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: grad[0].withValues(alpha: 0.28), width: 1.3),
          boxShadow: [
            BoxShadow(
                color: grad[0].withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: grad),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.biotech_rounded,
                    color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(DateFormat('MMM d').format(prediction.date),
                    style: TextStyle(
                        fontSize: 11,
                        color: grad[0],
                        fontWeight: FontWeight.w600)),
              ),
            ]),
            Text(prediction.diseaseName,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.textStrong,
                    height: 1.25),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            Row(children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: prediction.confidence,
                    backgroundColor: grad[0].withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(grad[0]),
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('$pct%',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: grad[0])),
            ]),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: 400 + index * 60))
          .fadeIn(duration: 320.ms)
          .slideX(begin: 0.10, end: 0),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ✨ Ultra-Premium Health Tips — cinematic full-bleed cards with auto-scroll
// ─────────────────────────────────────────────────────────────────────────────

class _TipsStrip extends StatefulWidget {
  const _TipsStrip({required this.tips});
  final List<String> tips;

  @override
  State<_TipsStrip> createState() => _TipsStripState();
}

class _TipsStripState extends State<_TipsStrip>
    with SingleTickerProviderStateMixin {
  int _current = 0;
  late final PageController _pageCtrl;
  late final AnimationController _shimmerCtrl;

  // ── Curated world-class palettes — each pair is distinct, WCAG-contrast-safe
  // Strategy: warm → cool → vibrant → muted → jewel tones, never two adjacent cards the same hue
  static const _tipPalettes = [
    // 1  Deep Teal
    [Color(0xFF0ABFBC), Color(0xFF048A87), Color(0xFF025655)],
    // 2  Royal Indigo
    [Color(0xFF7C5CBF), Color(0xFF5836A6), Color(0xFF33196E)],
    // 3  Coral Sunset
    [Color(0xFFFF6B6B), Color(0xFFEE4545), Color(0xFFB51C1C)],
    // 4  Sapphire Blue
    [Color(0xFF2B7EF5), Color(0xFF1558C9), Color(0xFF0B3482)],
    // 5  Fern Green
    [Color(0xFF27AE60), Color(0xFF1A8248), Color(0xFF0D5430)],
    // 6  Amber Honey
    [Color(0xFFF5A623), Color(0xFFD4840C), Color(0xFF8A5300)],
    // 7  Magenta Rose
    [Color(0xFFE91E8C), Color(0xFFC1156E), Color(0xFF7D0C47)],
    // 8  Slate Ocean
    [Color(0xFF1A6B8A), Color(0xFF125070), Color(0xFF08303D)],
    // 9  Grape Violet
    [Color(0xFF9B3DD4), Color(0xFF7721B2), Color(0xFF4B1274)],
    // 10 Olive Sage
    [Color(0xFF5D9B3F), Color(0xFF417B28), Color(0xFF254E15)],
    // 11 Crimson Wine
    [Color(0xFFB5233A), Color(0xFF8E1528), Color(0xFF5A0A18)],
    // 12 Sky Cyan
    [Color(0xFF00B4D8), Color(0xFF008FB5), Color(0xFF005C77)],
    // 13 Rust Terracotta
    [Color(0xFFD4623A), Color(0xFFB04020), Color(0xFF6E2610)],
    // 14 Midnight Navy
    [Color(0xFF3D5AF1), Color(0xFF2338CC), Color(0xFF0D1C82)],
    // 15 Jade Emerald
    [Color(0xFF00897B), Color(0xFF00675C), Color(0xFF003E38)],
    // 16 Plum Purple
    [Color(0xFF7B1FA2), Color(0xFF5E1580), Color(0xFF380D4D)],
    // 17 Sunrise Orange
    [Color(0xFFFF8C00), Color(0xFFD96B00), Color(0xFF8A4200)],
    // 18 Steel Blue
    [Color(0xFF1976D2), Color(0xFF0D55A8), Color(0xFF08336A)],
  ];

  static const _tipEmojis = [
    '💧', '🧠', '📱', '🥦', '🫁', '🍎',
    '🧼', '🪑', '😴', '🥛', '🧂', '☀️',
    '👥', '🍳', '🥜', '👟', '💦', '🍽️',
  ];
  static const _tipTags = [
    'Hydration', 'Mental', 'Sleep', 'Nutrition', 'Breathing', 'Sugar',
    'Hygiene', 'Fitness', 'Rest', 'Gut Health', 'Diet', 'Vitamin D',
    'Wellness', 'Breakfast', 'Heart', 'Activity', 'Alertness', 'Digestion',
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl   = PageController(viewportFraction: 0.86, initialPage: 0);
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // Auto-advance every 4 s
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return false;
      final next = (_current + 1) % math.max(1, widget.tips.length).toInt();
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
      return true;
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.tips.length;
    return Column(children: [
      SizedBox(
        height: 178,
        child: PageView.builder(
          controller: _pageCtrl,
          itemCount: count,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (ctx, i) => _TipCard(
            tip:       widget.tips[i],
            palette:   _tipPalettes[i % _tipPalettes.length],
            emoji:     _tipEmojis[i % _tipEmojis.length],
            tag:       _tipTags[i % _tipTags.length],
            index:     i,
            shimmerCtrl: _shimmerCtrl,
          ),
        ),
      ),
      const SizedBox(height: 14),
      // Smart dot indicator — show max 6 dots centred on current page
      _TipsDotIndicator(total: count, current: _current, palettes: _tipPalettes),
    ]);
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.tip,
    required this.palette,
    required this.emoji,
    required this.tag,
    required this.index,
    required this.shimmerCtrl,
  });
  final String             tip;
  final List<Color>        palette;
  final String             emoji;
  final String             tag;
  final int                index;
  final AnimationController shimmerCtrl;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmerCtrl,
      builder: (_, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: palette,
              begin: Alignment(
                  -1.2 + shimmerCtrl.value * 2.4, -0.6),
              end:   Alignment(
                   0.8 + shimmerCtrl.value * 1.2,  0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: palette[0].withValues(alpha: 0.42),
                blurRadius: 28,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: palette[1].withValues(alpha: 0.20),
                blurRadius: 50,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            // Translucent orb — top-right
            Positioned(
              right: -28, top: -28,
              child: Container(
                width: 130, height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.09),
                ),
              ),
            ),
            // Translucent orb — bottom-left
            Positioned(
              left: -20, bottom: -20,
              child: Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: tag pill + emoji
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tag pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 11, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                            width: 6, height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(tag,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4)),
                        ]),
                      ),
                      const Spacer(),
                      // Tip number badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text('# ${index + 1}',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.80),
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Big emoji
                  Text(emoji,
                      style: const TextStyle(fontSize: 32, height: 1.0))
                      .animate(delay: Duration(milliseconds: 100 + index * 60))
                      .scale(begin: const Offset(0.6, 0.6), curve: Curves.elasticOut, duration: 700.ms),
                  const SizedBox(height: 8),
                  // Tip text
                  Text(
                    tip,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.55,
                      letterSpacing: 0.1,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Smart dot indicator (shows 5 dots max, scrolling window around current)
// ─────────────────────────────────────────────────────────────────────────────

class _TipsDotIndicator extends StatelessWidget {
  const _TipsDotIndicator({
    required this.total,
    required this.current,
    required this.palettes,
  });
  final int total;
  final int current;
  final List<List<Color>> palettes;

  @override
  Widget build(BuildContext context) {
    const visible = 5;
    // Compute visible window centred on current
    int start = (current - visible ~/ 2).clamp(0, math.max(0, total - visible));
    final end = (start + visible).clamp(0, total);
    start = (end - visible).clamp(0, total);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (start > 0) ...[
          _dot(false, const Color(0xFFD1D5DB), mini: true),
          const SizedBox(width: 4),
        ],
        for (int i = start; i < end; i++) ...[
          _dot(
            i == current,
            palettes[i % palettes.length][0],
          ),
          if (i < end - 1) const SizedBox(width: 5),
        ],
        if (end < total) ...[
          const SizedBox(width: 4),
          _dot(false, const Color(0xFFD1D5DB), mini: true),
        ],
      ],
    );
  }

  Widget _dot(bool active, Color color, {bool mini = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width:  mini ? 5 : (active ? 26 : 8),
      height: mini ? 5 : 8,
      decoration: BoxDecoration(
        color: active ? color : (mini ? color : DesignTokens.border),
        borderRadius: BorderRadius.circular(99),
        boxShadow: active
            ? [BoxShadow(color: color.withValues(alpha: 0.50), blurRadius: 8, offset: const Offset(0, 2))]
            : [],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ✨ Ultra-Premium Articles Strip — large immersive cards with glassmorphism
// ─────────────────────────────────────────────────────────────────────────────

class _ArticlesStrip extends StatelessWidget {
  const _ArticlesStrip({required this.articles});
  final List<Article> articles;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 232,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: articles.length,
        itemBuilder: (ctx, i) =>
            _ArticleCard(article: articles[i], index: i),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article, required this.index});
  final Article article;
  final int     index;

  // ── Article palettes — 10 categories, each a distinct hue family
  // Chosen so adjacent cards in the scroll never share a colour family
  static const _catPalettes = {
    // Warm green-teal — Nutrition
    'nutrition':   [Color(0xFF00BFA5), Color(0xFF008775), Color(0xFF004F45)],
    // Rich royal blue — Fitness
    'fitness':     [Color(0xFF1565C0), Color(0xFF0D47A1), Color(0xFF082980)],
    // Deep violet — Mental Health
    'mental':      [Color(0xFF6A1B9A), Color(0xFF4A148C), Color(0xFF2D0A5A)],
    // Vivid crimson — Disease
    'disease':     [Color(0xFFC62828), Color(0xFFB71C1C), Color(0xFF7F0000)],
    // Warm amber-gold — Lifestyle
    'lifestyle':   [Color(0xFFE65100), Color(0xFFBF360C), Color(0xFF7F2400)],
    // Safety orange-red — First Aid
    'first aid':   [Color(0xFFD84315), Color(0xFFBF360C), Color(0xFF7F2400)],
    // Vibrant pink-fuchsia — Child
    'child':       [Color(0xFFAD1457), Color(0xFF880E4F), Color(0xFF560027)],
    // Cool sky-cyan — Vaccination
    'vaccination': [Color(0xFF00838F), Color(0xFF006064), Color(0xFF003F48)],
    // Forest green — Hygiene
    'hygiene':     [Color(0xFF2E7D32), Color(0xFF1B5E20), Color(0xFF0A3B0D)],
    // Warm rose-mauve — Maternal
    'maternal':    [Color(0xFFC2185B), Color(0xFF880E4F), Color(0xFF560027)],
  };

  // ── Category icons — precise, recognisable symbols
  static const _catIcons = <String, IconData>{
    'nutrition':   Icons.restaurant_menu_rounded,
    'fitness':     Icons.directions_run_rounded,
    'mental':      Icons.self_improvement_rounded,
    'disease':     Icons.health_and_safety_rounded,
    'lifestyle':   Icons.wb_sunny_rounded,
    'first aid':   Icons.local_hospital_rounded,
    'child':       Icons.child_care_rounded,
    'vaccination': Icons.vaccines_rounded,
    'hygiene':     Icons.clean_hands_rounded,
    'maternal':    Icons.favorite_rounded,
  };

  List<Color> _palette(String cat) {
    final key = _catPalettes.keys.firstWhere(
        (k) => cat.toLowerCase().contains(k),
        orElse: () => 'nutrition');
    return _catPalettes[key]!;
  }

  IconData _icon(String cat) {
    final key = _catIcons.keys.firstWhere(
        (k) => cat.toLowerCase().contains(k),
        orElse: () => 'nutrition');
    return _catIcons[key]!;
  }

  @override
  Widget build(BuildContext context) {
    final pal  = _palette(article.category);
    final icon = _icon(article.category);

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(RouteNames.healthEducation),
      child: Container(
        width: 218,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: DesignTokens.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: pal[0].withValues(alpha: 0.18),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: pal[1].withValues(alpha: 0.10),
              blurRadius: 40,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Immersive gradient header (taller, richer) ──────────────
            SizedBox(
              height: 138,
              child: Stack(
                children: [
                  // Background gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: pal,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  // Large decorative orb — bottom right
                  Positioned(
                    right: -30, bottom: -30,
                    child: Container(
                      width: 110, height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                  ),
                  // Small orb — top left
                  Positioned(
                    left: -14, top: -14,
                    child: Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  // Category pill — top left
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.30),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        article.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  // Read time — top right
                  Positioned(
                    top: 12, right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.schedule_rounded,
                            color: Colors.white, size: 10),
                        const SizedBox(width: 3),
                        Text(article.readTime,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                  // Large decorative icon — centre bottom
                  Positioned(
                    bottom: 10, right: 14,
                    child: Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                  ),
                  // "Read →" chip — bottom left
                  Positioned(
                    bottom: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(99),
                        boxShadow: [
                          BoxShadow(
                            color: pal[0].withValues(alpha: 0.30),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('Read',
                            style: TextStyle(
                                color: pal[1],
                                fontSize: 10,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(width: 3),
                        Icon(Icons.arrow_forward_rounded,
                            size: 10, color: pal[1]),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            // ── Title area ───────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: DesignTokens.textStrong,
                        height: 1.4,
                        letterSpacing: -0.1,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Accent bar matching card colour
                    Container(
                      height: 3,
                      width: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [pal[0], pal[1]]),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: 580 + index * 80))
          .fadeIn(duration: 380.ms)
          .slideX(begin: 0.10, end: 0, curve: Curves.easeOutCubic),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Skeleton Loader
// ─────────────────────────────────────────────────────────────────────────────

class _PremiumSkeletonLoader extends StatefulWidget {
  const _PremiumSkeletonLoader({super.key});

  @override
  State<_PremiumSkeletonLoader> createState() =>
      _PremiumSkeletonLoaderState();
}

class _PremiumSkeletonLoaderState extends State<_PremiumSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  Widget _bone({
    double? width,
    required double height,
    double radius = 14,
    EdgeInsets? margin,
  }) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) => Container(
        width: width ?? double.infinity,
        height: height,
        margin: margin ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment(-1.5 + _shimmer.value * 3, 0),
            end:   Alignment(-0.5 + _shimmer.value * 3, 0),
            colors: const [
              Color(0xFFEEE8FF),
              Color(0xFFDDD4FF),
              Color(0xFFEEE8FF),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero header bone
          _bone(height: 220, radius: 30,
              margin: const EdgeInsets.fromLTRB(16, 14, 16, 0)),

          // Section label
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
            child: Row(children: [
              _bone(width: 34, height: 34, radius: 10,
                  margin: EdgeInsets.zero),
              const SizedBox(width: 10),
              _bone(width: 130, height: 18, radius: 8,
                  margin: EdgeInsets.zero),
            ]),
          ),

          // Quick action grid skeleton (2×3)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.55,
              ),
              itemBuilder: (_, i) => AnimatedBuilder(
                animation: _shimmer,
                builder: (_, __) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment(-1.5 + _shimmer.value * 3, 0),
                      end:   Alignment(-0.5 + _shimmer.value * 3, 0),
                      colors: const [
                        Color(0xFFEEE8FF),
                        Color(0xFFDDD4FF),
                        Color(0xFFEEE8FF),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Emergency card bone
          _bone(height: 88, radius: 22,
              margin: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 4)),

          // Tips section label
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
            child: _bone(width: 160, height: 18, radius: 8,
                margin: EdgeInsets.zero),
          ),

          // Tips card bone
          _bone(height: 148, radius: 26,
              margin: const EdgeInsets.symmetric(horizontal: 22)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error view
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({super.key, this.message, required this.onRetry});
  final String?      message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: DesignTokens.dangerContainer,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.danger.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                  child:
                      Text('⚠️', style: TextStyle(fontSize: 42))),
            )
                .animate()
                .scale(
                    begin: const Offset(0.7, 0.7),
                    duration: 500.ms,
                    curve: Curves.elasticOut),
            const SizedBox(height: 24),
            const Text(
              'Could not load dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textStrong,
                letterSpacing: -0.3,
              ),
            ).animate(delay: 100.ms).fadeIn(duration: 350.ms),
            const SizedBox(height: 8),
            Text(
              message ?? 'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: DesignTokens.textMuted,
                  fontSize: 14,
                  height: 1.55),
            ).animate(delay: 150.ms).fadeIn(duration: 350.ms),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                backgroundColor: DesignTokens.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(180, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15),
              ),
            )
                .animate(delay: 200.ms)
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}
