/// Ultra-premium Home Dashboard — AI Healthcare Assistant
///
/// Design language:
///   • Glassmorphism hero with purple→blue gradient
///   • Staggered flutter_animate entry animations
///   • Animated health-score arc ring
///   • Horizontal scrolling cards for tips, hospitals, articles
///   • Soft frosted-glass section cards
///   • All existing sub-widgets preserved (AppBar, BottomNav, QuickActionGrid,
///     EmergencyCard, GuestBanner, OfflineStatusBanner)
library;

import 'dart:math' as math;
import 'dart:ui';

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
import '../../domain/entities/hospital.dart';
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
        if (u == null || (u.isGuest)) return null;
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
                    // ── Hero gradient header ─────────────────────────────
                    _HeroHeader(
                      weather: state.weather,
                      healthScore: state.healthScore,
                      userName: userName,
                      isGuest: isGuest,
                    ),

                    // ── Guest CTA ────────────────────────────────────────
                    if (isGuest) const GuestBanner(),

                    // ── Quick actions ────────────────────────────────────
                    const _SectionLabel(title: 'Quick Actions', emoji: '⚡',
                        delay: 200),
                    QuickActionGrid(actions: state.quickActions)
                        .animate(delay: 220.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.08, end: 0),

                    const SizedBox(height: 6),

                    // ── SOS emergency card ───────────────────────────────
                    const EmergencyCard()
                        .animate(delay: 300.ms)
                        .fadeIn(duration: 350.ms)
                        .slideY(begin: 0.06, end: 0),

                    // ── Recent predictions ───────────────────────────────
                    if (state.recentPredictions.isNotEmpty) ...[
                      _SectionLabel(
                        title: 'Recent Assessments',
                        emoji: '🧬',
                        delay: 350,
                        onSeeAll: () => Navigator.of(context)
                            .pushNamed(RouteNames.history),
                      ),
                      _PredictionsStrip(
                              predictions: state.recentPredictions)
                          .animate(delay: 370.ms)
                          .fadeIn(duration: 350.ms),
                    ],

                    // ── Health tips ──────────────────────────────────────
                    if (state.healthTips.isNotEmpty) ...[
                      const _SectionLabel(
                          title: 'Daily Health Tips', emoji: '💡',
                          delay: 420),
                      _TipsStrip(tips: state.healthTips)
                          .animate(delay: 440.ms)
                          .fadeIn(duration: 350.ms),
                    ],

                    // ── Nearby hospitals ─────────────────────────────────
                    if (state.nearbyHospitals.isNotEmpty) ...[
                      _SectionLabel(
                        title: 'Nearby Hospitals',
                        emoji: '🏥',
                        delay: 480,
                        onSeeAll: () => Navigator.of(context)
                            .pushNamed(RouteNames.nearbyHealthcare),
                      ),
                      _HospitalsStrip(hospitals: state.nearbyHospitals)
                          .animate(delay: 500.ms)
                          .fadeIn(duration: 350.ms),
                    ],

                    // ── Latest articles ──────────────────────────────────
                    if (state.latestArticles.isNotEmpty) ...[
                      _SectionLabel(
                        title: 'Health Articles',
                        emoji: '📚',
                        delay: 540,
                        onSeeAll: () => Navigator.of(context)
                            .pushNamed(RouteNames.healthEducation),
                      ),
                      _ArticlesStrip(articles: state.latestArticles)
                          .animate(delay: 560.ms)
                          .fadeIn(duration: 350.ms),
                    ],

                    const SizedBox(height: 36),
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
// Hero Header  (gradient + weather pill + health score ring)
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
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>    _scoreAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _scoreAnim = Tween<double>(begin: 0,
        end: (widget.healthScore?.score ?? 0) / 100.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 180), _ctrl.forward);
  }

  @override
  void dispose() {
    _ctrl.dispose();
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

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF6B47E8), Color(0xFF926EFF), Color(0xFF4F94FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B47E8).withValues(alpha: 0.38),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── Decorative orbs ──────────────────────────────────────────────
          Positioned(
            right: -24, top: -24,
            child: _Orb(size: 130, opacity: 0.08),
          ),
          Positioned(
            left: -18, bottom: -18,
            child: _Orb(size: 100, opacity: 0.06),
          ),
          Positioned(
            right: 60, bottom: 10,
            child: _Orb(size: 60, opacity: 0.05),
          ),

          // ── Content ──────────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting row + weather pill
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _greeting(),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.80),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                                  .animate(delay: 60.ms)
                                  .fadeIn(duration: 500.ms),
                              const SizedBox(height: 3),
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                                  .animate(delay: 90.ms)
                                  .fadeIn(duration: 500.ms)
                                  .slideX(begin: -0.06, end: 0),
                              const SizedBox(height: 10),
                              // Weather pill
                              if (widget.weather != null)
                                _WeatherPill(weather: widget.weather!)
                                    .animate(delay: 140.ms)
                                    .fadeIn(duration: 450.ms)
                                    .slideY(begin: 0.15, end: 0),
                            ],
                          ),
                        ),
                        // Health score ring
                        if (widget.healthScore != null)
                          AnimatedBuilder(
                            animation: _scoreAnim,
                            builder: (_, __) => _ScoreRing(
                              animatedValue: _scoreAnim.value,
                              score: widget.healthScore!.score,
                              status: widget.healthScore!.status,
                            ),
                          ).animate(delay: 100.ms).fadeIn(duration: 500.ms),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Stats row ─────────────────────────────────────────
                    Row(
                      children: [
                        _HeroStat(emoji: '❤️', label: 'Health Score',
                            value: '${widget.healthScore?.score ?? "--"}/100')
                            .animate(delay: 200.ms).fadeIn(duration: 400.ms),
                        _vDivider(),
                        _HeroStat(emoji: '🌡️', label: 'Temperature',
                            value: widget.weather != null
                                ? '${widget.weather!.temperature.toStringAsFixed(0)}°C'
                                : '--°C')
                            .animate(delay: 240.ms).fadeIn(duration: 400.ms),
                        _vDivider(),
                        _HeroStat(emoji: '💧', label: 'Humidity',
                            value: widget.weather != null
                                ? '${widget.weather!.humidity}%'
                                : '--%')
                            .animate(delay: 280.ms).fadeIn(duration: 400.ms),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 50.ms)
        .slideY(begin: -0.05, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 28,
        color: Colors.white.withValues(alpha: 0.20),
        margin: const EdgeInsets.symmetric(horizontal: 14),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.opacity});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      );
}

class _WeatherPill extends StatelessWidget {
  const _WeatherPill({required this.weather});
  final Weather weather;

  String _weatherEmoji(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('sun') || c.contains('clear')) return '☀️';
    if (c.contains('cloud')) return '⛅';
    if (c.contains('rain')) return '🌧️';
    if (c.contains('storm') || c.contains('thunder')) return '⛈️';
    if (c.contains('fog') || c.contains('mist')) return '🌫️';
    if (c.contains('snow')) return '❄️';
    if (c.contains('wind')) return '🌬️';
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_weatherEmoji(weather.condition),
              style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            '${weather.condition}  •  ${weather.location}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: aqiColor.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'AQI ${weather.aqi}',
              style: TextStyle(
                color: aqiColor,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
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
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.20), width: 1.5),
      ),
      child: CustomPaint(
        painter: _ArcPainter(value: animatedValue, colors: cols),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
              Text(
                status.split(' ').first,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.value, required this.colors});
  final double       value;
  final List<Color>  colors;

  @override
  void paint(Canvas canvas, Size size) {
    final cx    = size.width / 2;
    final cy    = size.height / 2;
    final radius = (size.width / 2) - 7;
    final rect   = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // Background arc
    final bgPaint = Paint()
      ..color  = Colors.white.withValues(alpha: 0.18)
      ..style  = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap   = StrokeCap.round;
    canvas.drawArc(rect, -math.pi * 0.75, math.pi * 1.5, false, bgPaint);

    if (value <= 0) return;

    // Gradient arc
    final gradPaint = Paint()
      ..shader = SweepGradient(
        colors: colors,
        startAngle: -math.pi * 0.75,
        endAngle:   -math.pi * 0.75 + math.pi * 1.5 * value,
      ).createShader(rect)
      ..style      = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap   = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi * 0.75,
      math.pi * 1.5 * value,
      false,
      gradPaint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.value != value;
}

class _HeroStat extends StatelessWidget {
  const _HeroStat(
      {required this.emoji, required this.label, required this.value});
  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label  (reuses DesignTokens, replaces old SectionTitle inline)
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
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: DesignTokens.textStrong,
              ),
            ),
          ]),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF926EFF), Color(0xFF6B47E8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: DesignTokens.primary.withValues(alpha: 0.28),
                      blurRadius: 8, offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text('See all →',
                    style: TextStyle(
                        color: Colors.white, fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 350.ms)
        .slideX(begin: -0.04, end: 0);
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
      height: 116,
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
    [Color(0xFF926EFF), Color(0xFF6B47E8)],
    [Color(0xFF4F94FF), Color(0xFF2563EB)],
    [Color(0xFF2ECC8B), Color(0xFF16A34A)],
    [Color(0xFFFF7B3D), Color(0xFFE55A1A)],
    [Color(0xFFFF5E9E), Color(0xFFE11D68)],
  ];

  @override
  Widget build(BuildContext context) {
    final grad = _gradients[index % _gradients.length];
    final pct  = (prediction.confidence * 100).toStringAsFixed(0);

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(RouteNames.history),
      child: Container(
        width: 168,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: grad.map((c) => c.withValues(alpha: 0.10)).toList(),
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: grad[0].withValues(alpha: 0.28), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: grad[0].withValues(alpha: 0.10),
              blurRadius: 10, offset: const Offset(0, 4),
            ),
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
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.biotech_rounded,
                    color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DateFormat('MMM d').format(prediction.date),
                  style: TextStyle(
                    fontSize: 11,
                    color: grad[0],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ]),
            Text(
              prediction.diseaseName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textStrong,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
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
          .animate(delay: Duration(milliseconds: 380 + index * 60))
          .fadeIn(duration: 300.ms)
          .slideX(begin: 0.1, end: 0),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Health Tips strip  (horizontal scrolling pill cards)
// ─────────────────────────────────────────────────────────────────────────────

class _TipsStrip extends StatefulWidget {
  const _TipsStrip({required this.tips});
  final List<String> tips;

  @override
  State<_TipsStrip> createState() => _TipsStripState();
}

class _TipsStripState extends State<_TipsStrip> {
  int _current = 0;

  static const _tipColors = [
    [Color(0xFF2ECC8B), Color(0xFF16A34A)],
    [Color(0xFF4F94FF), Color(0xFF2563EB)],
    [Color(0xFFFFB829), Color(0xFFD98E00)],
    [Color(0xFFFF5E9E), Color(0xFFE11D68)],
    [Color(0xFF926EFF), Color(0xFF6B47E8)],
    [Color(0xFF18C8C8), Color(0xFF0B9B9B)],
  ];

  static const _tipEmojis = ['💡', '🥗', '🏃', '😴', '💊', '🧘'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.88),
            itemCount: widget.tips.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (ctx, i) {
              final grad = _tipColors[i % _tipColors.length];
              final emoji = _tipEmojis[i % _tipEmojis.length];
              return _TipCard(
                tip: widget.tips[i],
                gradient: grad,
                emoji: emoji,
                index: i,
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Page indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            math.min(widget.tips.length, 6),
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _current ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == _current
                    ? DesignTokens.primary
                    : DesignTokens.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard(
      {required this.tip,
      required this.gradient,
      required this.emoji,
      required this.index});
  final String       tip;
  final List<Color>  gradient;
  final String       emoji;
  final int          index;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.30),
            blurRadius: 18, offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12, top: -12,
            child: Text(emoji,
                style: const TextStyle(fontSize: 64, height: 1)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Tip ${index + 1}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 8),
              Text(
                tip,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.96),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nearby Hospitals strip
// ─────────────────────────────────────────────────────────────────────────────

class _HospitalsStrip extends StatelessWidget {
  const _HospitalsStrip({required this.hospitals});
  final List<Hospital> hospitals;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: hospitals.length,
        itemBuilder: (ctx, i) =>
            _HospitalCard(hospital: hospitals[i], index: i),
      ),
    );
  }
}

class _HospitalCard extends StatelessWidget {
  const _HospitalCard({required this.hospital, required this.index});
  final Hospital hospital;
  final int      index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.of(context).pushNamed(RouteNames.nearbyHealthcare),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: DesignTokens.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: DesignTokens.border),
          boxShadow: [
            BoxShadow(
              color: DesignTokens.primary.withValues(alpha: 0.06),
              blurRadius: 10, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2ECC8B), Color(0xFF16A34A)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_hospital_rounded,
                    color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: DesignTokens.greenContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${hospital.distance.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: DesignTokens.green,
                  ),
                ),
              ),
            ]),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hospital.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.textStrong,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  hospital.address,
                  style: const TextStyle(
                    fontSize: 11,
                    color: DesignTokens.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: 500 + index * 60))
          .fadeIn(duration: 300.ms)
          .slideX(begin: 0.08, end: 0),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Articles strip  (horizontal scrolling cards with frosted image placeholder)
// ─────────────────────────────────────────────────────────────────────────────

class _ArticlesStrip extends StatelessWidget {
  const _ArticlesStrip({required this.articles});
  final List<Article> articles;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
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

  static const _catColors = {
    'nutrition':    [Color(0xFF2ECC8B), Color(0xFF16A34A)],
    'fitness':      [Color(0xFF4F94FF), Color(0xFF2563EB)],
    'mental':       [Color(0xFF926EFF), Color(0xFF6B47E8)],
    'disease':      [Color(0xFFFF4757), Color(0xFFCC2233)],
    'lifestyle':    [Color(0xFFFFB829), Color(0xFFD98E00)],
    'first aid':    [Color(0xFFFF7B3D), Color(0xFFE55A1A)],
    'child':        [Color(0xFFFF5E9E), Color(0xFFE11D68)],
  };

  List<Color> _categoryGrad(String cat) {
    final key = _catColors.keys.firstWhere(
      (k) => cat.toLowerCase().contains(k),
      orElse: () => 'nutrition',
    );
    return _catColors[key]!;
  }

  @override
  Widget build(BuildContext context) {
    final grad = _categoryGrad(article.category);

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
              color: grad[0].withValues(alpha: 0.10),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / gradient placeholder
            Container(
              height: 96,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: grad,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Decorative orb
                  Positioned(
                    right: -16, bottom: -16,
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  // Category badge
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        article.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  // Read time badge
                  Positioned(
                    bottom: 10, right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule_rounded,
                              color: Colors.white, size: 10),
                          const SizedBox(width: 3),
                          Text(
                            article.readTime,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Text(
                article.title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: DesignTokens.textStrong,
                  height: 1.35,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: 560 + index * 70))
          .fadeIn(duration: 320.ms)
          .slideX(begin: 0.08, end: 0),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Skeleton Loader  (replaces the plain grey boxes)
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
      builder: (_, __) {
        return Container(
          width: width ?? double.infinity,
          height: height,
          margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
        );
      },
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
          _bone(height: 210, radius: 28,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0)),

          // Section label bone
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
            child: Row(children: [
              _bone(width: 22, height: 22, radius: 6, margin: EdgeInsets.zero),
              const SizedBox(width: 8),
              _bone(width: 130, height: 16, radius: 8, margin: EdgeInsets.zero),
            ]),
          ),

          // Quick action grid bones
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 8,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 108,
              ),
              itemBuilder: (_, i) => AnimatedBuilder(
                animation: _shimmer,
                builder: (_, __) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
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

          const SizedBox(height: 12),

          // Emergency card bone
          _bone(height: 82, radius: 20,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4)),

          // Tips section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
            child: _bone(width: 160, height: 16, radius: 8, margin: EdgeInsets.zero),
          ),
          _bone(height: 140, radius: 24,
              margin: const EdgeInsets.symmetric(horizontal: 16)),

          // Hospitals
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
            child: _bone(width: 140, height: 16, radius: 8, margin: EdgeInsets.zero),
          ),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (_, i) => AnimatedBuilder(
                animation: _shimmer,
                builder: (_, __) => Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment(-1.5 + _shimmer.value * 3, 0),
                      end:   Alignment(-0.5 + _shimmer.value * 3, 0),
                      colors: const [
                        Color(0xFFEEE8FF), Color(0xFFDDD4FF), Color(0xFFEEE8FF)
                      ],
                    ),
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
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: DesignTokens.dangerContainer,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.danger.withValues(alpha: 0.18),
                    blurRadius: 20, offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                  child: Text('⚠️', style: TextStyle(fontSize: 42))),
            )
                .animate()
                .scale(begin: const Offset(0.7, 0.7),
                    duration: 500.ms, curve: Curves.elasticOut),
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
                  color: DesignTokens.textMuted, fontSize: 14, height: 1.55),
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
