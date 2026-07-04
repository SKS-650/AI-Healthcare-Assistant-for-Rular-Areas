import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../routing/route_names.dart';
import '../../../../shared/design_system/design_tokens.dart';
import '../../../authentication/presentation/providers/authentication_provider.dart';
import '../controller/dashboard_state.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/app_bar/dashboard_app_bar.dart';
import '../widgets/articles/article_card.dart';
import '../widgets/bottom_navigation/home_bottom_navigation.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/common/section_title.dart';
import '../widgets/emergency/emergency_card.dart';
import '../widgets/guest/guest_banner.dart';
import '../widgets/health_score/health_score_card.dart';
import '../widgets/health_tips/tips_slider.dart';
import '../widgets/hospitals/hospital_card.dart';
import '../widgets/predictions/recent_prediction_card.dart';
import '../widgets/quick_actions/quick_action_grid.dart';
import '../widgets/weather/weather_card.dart';

class HomeDashboardPage extends ConsumerWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardControllerProvider);

    return Scaffold(
      appBar: const DashboardAppBar(),
      bottomNavigationBar: const HomeBottomNavigation(),
      backgroundColor: DesignTokens.background,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _buildBody(context, ref, state),
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, WidgetRef ref, DashboardState state) {
    if (state.status == DashboardStatus.loading ||
        state.status == DashboardStatus.initial) {
      return const DashboardSkeletonLoader(key: ValueKey('loading'));
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

    return RefreshIndicator(
      key: const ValueKey('loaded'),
      color: DesignTokens.primary,
      onRefresh: () =>
          ref.read(dashboardControllerProvider.notifier).loadDashboardData(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                    maxWidth: DesignTokens.maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),

                    // ── Guest call-to-action banner ──────────────────────
                    if (isGuest) const GuestBanner(),

                    if (state.weather != null)
                      WeatherCard(weather: state.weather!),

                    if (state.healthScore != null)
                      HealthScoreCard(healthScore: state.healthScore!),

                    const SizedBox(height: 4),

                    const SectionTitle(title: 'Quick Actions', emoji: '⚡'),
                    QuickActionGrid(actions: state.quickActions),

                    const SizedBox(height: 16),
                    const EmergencyCard(),

                    if (state.recentPredictions.isNotEmpty) ...[
                      SectionTitle(
                        title: 'Recent Predictions',
                        emoji: '🧬',
                        onSeeAll: () => Navigator.of(context)
                            .pushNamed(RouteNames.history),
                      ),
                      RecentPredictionsList(
                          predictions: state.recentPredictions),
                    ],

                    if (state.healthTips.isNotEmpty) ...[
                      const SectionTitle(title: 'Health Tips', emoji: '💡'),
                      TipsSlider(tips: state.healthTips),
                    ],

                    if (state.nearbyHospitals.isNotEmpty) ...[
                      SectionTitle(
                        title: 'Nearby Hospitals',
                        emoji: '🏥',
                        onSeeAll: () => Navigator.of(context)
                            .pushNamed(RouteNames.nearbyHealthcare),
                      ),
                      NearbyHospitalsList(
                          hospitals: state.nearbyHospitals),
                    ],

                    if (state.latestArticles.isNotEmpty) ...[
                      const SectionTitle(
                          title: 'Health Articles', emoji: '📚'),
                      LatestArticlesList(articles: state.latestArticles),
                    ],

                    const SizedBox(height: 32),
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

class _ErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const _ErrorView(
      {super.key, this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: DesignTokens.dangerContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                  child: Text('⚠️', style: TextStyle(fontSize: 36))),
            ),
            const SizedBox(height: 20),
            const Text(
              'Could not load dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textStrong,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? 'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: DesignTokens.textMuted, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: FilledButton.styleFrom(
                backgroundColor: DesignTokens.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(160, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
