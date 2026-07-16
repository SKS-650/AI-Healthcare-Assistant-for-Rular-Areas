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
  });
  final String        title;
  final String        emoji;
  final int           delay;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            // Emoji bubble
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DesignTokens.primary.withValues(alpha: 0.18),
                    DesignTokens.primary.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                  child: Text(emoji,
                      style: const TextStyle(fontSize: 17))),
            ),
            const SizedBox(width: 10),
            Text(title,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: DesignTokens.textStrong)),
          ]),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF926EFF), Color(0xFF6B47E8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: DesignTokens.primary.withValues(alpha: 0.30),
                      blurRadius: 10,
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
// Health Tips — auto-scrolling page view with dot indicators
// ─────────────────────────────────────────────────────────────────────────────

class _TipsStrip extends StatefulWidget {
  const _TipsStrip({required this.tips});
  final List<String> tips;

  @override
  State<_TipsStrip> createState() => _TipsStripState();
}

class _TipsStripState extends State<_TipsStrip> {
  int _current = 0;
  late final PageController _pageCtrl;

  static const _tipColors = [
    [Color(0xFF10B981), Color(0xFF065F46)],
    [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    [Color(0xFFF59E0B), Color(0xFFB45309)],
    [Color(0xFFEC4899), Color(0xFF9D174D)],
    [Color(0xFF9B5DE5), Color(0xFF6B21A8)],
    [Color(0xFF06B6D4), Color(0xFF0E7490)],
  ];

  static const _tipEmojis = ['💡', '🥗', '🏃', '😴', '💊', '🧘'];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 148,
        child: PageView.builder(
          controller: _pageCtrl,
          itemCount: widget.tips.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (ctx, i) => _TipCard(
            tip:      widget.tips[i],
            gradient: _tipColors[i % _tipColors.length],
            emoji:    _tipEmojis[i % _tipEmojis.length],
            index:    i,
          ),
        ),
      ),
      const SizedBox(height: 12),
      // Animated indicator dots
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          math.min(widget.tips.length, 6),
          (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == _current ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == _current
                  ? DesignTokens.primary
                  : DesignTokens.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    ]);
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.tip,
    required this.gradient,
    required this.emoji,
    required this.index,
  });
  final String      tip;
  final List<Color> gradient;
  final String      emoji;
  final int         index;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
              color: gradient[0].withValues(alpha: 0.32),
              blurRadius: 20,
              offset: const Offset(0, 7)),
        ],
      ),
      child: Stack(children: [
        Positioned(
          right: -10, top: -10,
          child: Text(emoji, style: const TextStyle(fontSize: 68, height: 1)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(8)),
              child: Text('Tip ${index + 1}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 8),
            Text(tip,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.96),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.50),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Articles strip
// ─────────────────────────────────────────────────────────────────────────────

class _ArticlesStrip extends StatelessWidget {
  const _ArticlesStrip({required this.articles});
  final List<Article> articles;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
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

  static const _catGrads = {
    'nutrition':  [Color(0xFF10B981), Color(0xFF065F46)],
    'fitness':    [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    'mental':     [Color(0xFF9B5DE5), Color(0xFF6B21A8)],
    'disease':    [Color(0xFFF43F5E), Color(0xFFBE123C)],
    'lifestyle':  [Color(0xFFF59E0B), Color(0xFFB45309)],
    'first aid':  [Color(0xFFF97316), Color(0xFFC2410C)],
    'child':      [Color(0xFFEC4899), Color(0xFF9D174D)],
    'vaccination':[Color(0xFF06B6D4), Color(0xFF0E7490)],
    'hygiene':    [Color(0xFF10B981), Color(0xFF065F46)],
    'maternal':   [Color(0xFFEC4899), Color(0xFF9D174D)],
  };

  List<Color> _grad(String cat) {
    final key = _catGrads.keys.firstWhere(
        (k) => cat.toLowerCase().contains(k),
        orElse: () => 'nutrition');
    return _catGrads[key]!;
  }

  @override
  Widget build(BuildContext context) {
    final grad = _grad(article.category);

    return GestureDetector(
      onTap: () =>
          Navigator.of(context).pushNamed(RouteNames.healthEducation),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: DesignTokens.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: DesignTokens.border),
          boxShadow: [
            BoxShadow(
              color: grad[0].withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient image header
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: grad,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
              ),
              child: Stack(children: [
                Positioned(right: -18, bottom: -18,
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    )),
                // Category badge
                Positioned(top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(article.category,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    )),
                // Read-time badge
                Positioned(bottom: 10, right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(10)),
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
                    )),
              ]),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Text(article.title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: DesignTokens.textStrong,
                    height: 1.35,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: 580 + index * 70))
          .fadeIn(duration: 320.ms)
          .slideX(begin: 0.08, end: 0),
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
