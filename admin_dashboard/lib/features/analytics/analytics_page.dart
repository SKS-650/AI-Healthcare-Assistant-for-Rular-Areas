import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../shared/widgets/chart_card.dart';
import '../../shared/widgets/stat_card.dart';
import 'analytics_provider.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(analyticsProvider);
    final notifier = ref.read(analyticsProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Symptom Analytics',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w700))
                        .animate()
                        .fadeIn(duration: 400.ms),
                    Text('Disease prediction & symptom pattern insights',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.lightTextMuted))
                        .animate()
                        .fadeIn(delay: 100.ms),
                  ],
                ),
              ),
              // Period selector
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 7,  label: Text('7d')),
                  ButtonSegment(value: 30, label: Text('30d')),
                  ButtonSegment(value: 90, label: Text('90d')),
                ],
                selected: {state.days},
                onSelectionChanged: (s) => notifier.setDays(s.first),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((st) =>
                      st.contains(WidgetState.selected)
                          ? AppColors.primary
                          : null),
                  foregroundColor: WidgetStateProperty.resolveWith((st) =>
                      st.contains(WidgetState.selected)
                          ? Colors.white
                          : null),
                ),
              ).animate().fadeIn(delay: 200.ms),
            ],
          ),
          const SizedBox(height: 24),

          // ── Error / loading ─────────────────────────────────────────────
          if (state.error != null)
            _ErrorPanel(error: state.error!, onRetry: notifier.load)
          else ...[
            // ── KPI cards ─────────────────────────────────────────────────
            LayoutBuilder(builder: (ctx, cst) {
              final cols = cst.maxWidth > 900
                  ? 5
                  : cst.maxWidth > 700
                      ? 3
                      : 2;
              return GridView.count(
                crossAxisCount: cols,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.55,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StatCard(
                    title: 'Total Assessments',
                    value: state.isLoading ? '—' : '${state.totalAssessments}',
                    icon: Icons.monitor_heart_rounded,
                    color: AppColors.primary,
                    animDelay: 0,
                  ),
                  StatCard(
                    title: 'Today',
                    value: state.isLoading ? '—' : '${state.todayAssessments}',
                    icon: Icons.today_rounded,
                    color: AppColors.accent,
                    animDelay: 60,
                  ),
                  StatCard(
                    title: 'This Week',
                    value: state.isLoading ? '—' : '${state.weekAssessments}',
                    icon: Icons.date_range_rounded,
                    color: AppColors.info,
                    animDelay: 120,
                  ),
                  StatCard(
                    title: 'Emergency Cases',
                    value: state.isLoading ? '—' : '${state.emergencyCases}',
                    icon: Icons.crisis_alert_rounded,
                    color: AppColors.error,
                    animDelay: 180,
                  ),
                  StatCard(
                    title: 'Avg Risk Score',
                    value: state.isLoading
                        ? '—'
                        : '${state.avgRiskScore.toStringAsFixed(1)}%',
                    icon: Icons.speed_rounded,
                    color: AppColors.warning,
                    animDelay: 240,
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),

            // ── Assessment trend line chart ────────────────────────────────
            if (state.isLoading)
              const _ChartSkeleton()
            else
              LineChartCard(
                title: 'Assessment Trend',
                subtitle:
                    'Total assessments vs emergency cases over ${state.days} days',
                series: [
                  ChartSeries.fromMapList(
                    state.trend,
                    'total',
                    'date',
                    'Total Assessments',
                    AppColors.primary,
                  ),
                  ChartSeries.fromMapList(
                    state.trend,
                    'emergency',
                    'date',
                    'Emergency Cases',
                    AppColors.error,
                  ),
                ],
                animDelay: 100,
              ),
            const SizedBox(height: 16),

            // ── Top symptoms + risk distribution row ──────────────────────
            LayoutBuilder(builder: (ctx, cst) {
              final wide = cst.maxWidth > 900;

              final symptomsCard = _TopSymptomsCard(
                symptoms: state.symptomFrequency,
                isLoading: state.isLoading,
              );
              final riskCard = DonutChartCard(
                title: 'Risk Distribution',
                slices: state.riskDistribution.map((d) {
                  final level = d['risk_level'] as String? ?? '';
                  final count = d['count'] as int? ?? 0;
                  return PieSlice(
                    label:
                        '$level (${(d['percentage'] as num?)?.toStringAsFixed(1) ?? 0}%)',
                    value: count,
                    color: switch (level) {
                      'CRITICAL' => AppColors.riskCritical,
                      'HIGH'     => AppColors.riskHigh,
                      'MEDIUM'   => AppColors.riskMedium,
                      _          => AppColors.riskLow,
                    },
                  );
                }).toList(),
                animDelay: 200,
              );

              return wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: symptomsCard),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: riskCard),
                      ],
                    )
                  : Column(children: [
                      symptomsCard,
                      const SizedBox(height: 16),
                      riskCard,
                    ]);
            }),
            const SizedBox(height: 16),

            // ── Emergency types bar chart ─────────────────────────────────
            if (!state.isLoading && state.emergencyTypes.isNotEmpty)
              BarChartCard(
                title: 'Top Emergency Types',
                groups: state.emergencyTypes
                    .map((d) => BarGroup(
                          label: _shortLabel(
                              d['type'] as String? ?? 'Unknown'),
                          value: d['count'] as int? ?? 0,
                        ))
                    .toList(),
                animDelay: 300,
              ),
            const SizedBox(height: 16),

            // ── Gender + Age distribution row ─────────────────────────────
            LayoutBuilder(builder: (ctx, cst) {
              final wide = cst.maxWidth > 900;

              final genderCard = DonutChartCard(
                title: 'Gender Distribution',
                slices: state.genderDistribution.asMap().entries.map((e) {
                  final gender = e.value['gender'] as String? ?? 'Unknown';
                  final count  = e.value['count']  as int?    ?? 0;
                  return PieSlice(
                    label: '${_capitalise(gender)} ($count)',
                    value: count,
                    color: AppColors.chartPalette[
                        e.key % AppColors.chartPalette.length],
                  );
                }).toList(),
                animDelay: 350,
              );

              final ageCard = BarChartCard(
                title: 'Age Group Distribution',
                groups: state.ageDistribution
                    .map((d) => BarGroup(
                          label: d['age_group'] as String? ?? '',
                          value: d['count'] as int? ?? 0,
                          color: AppColors.accent,
                        ))
                    .toList(),
                animDelay: 400,
              );

              return wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: genderCard),
                        const SizedBox(width: 16),
                        Expanded(child: ageCard),
                      ],
                    )
                  : Column(children: [
                      genderCard,
                      const SizedBox(height: 16),
                      ageCard,
                    ]);
            }),
          ],
          const SizedBox(height: 16),

          // ── Refresh button ───────────────────────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: state.isLoading ? null : () => notifier.load(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Refresh'),
            ),
          ),
        ],
      ),
    );
  }

  static String _shortLabel(String label) =>
      label.length > 12 ? '${label.substring(0, 10)}…' : label;

  static String _capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ── Top Symptoms Card ─────────────────────────────────────────────────────────

class _TopSymptomsCard extends StatelessWidget {
  final List<Map<String, dynamic>> symptoms;
  final bool isLoading;
  const _TopSymptomsCard(
      {required this.symptoms, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final maxCount = symptoms.isEmpty
        ? 1
        : (symptoms.first['count'] as int? ?? 1).clamp(1, 999999);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top Reported Symptoms',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Most frequently reported symptom combinations',
                style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(
                  child: CircularProgressIndicator(strokeWidth: 2))
            else if (symptoms.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text('No symptom data yet',
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              )
            else
              ...symptoms.take(12).map((s) {
                final name  = s['symptom'] as String? ?? '';
                final count = s['count']   as int?    ?? 0;
                final pct   = count / maxCount;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('$count',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 6,
                          backgroundColor:
                              AppColors.primary.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation(
                              AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 150.ms, duration: 500.ms);
  }
}

// ── Chart skeleton ────────────────────────────────────────────────────────────

class _ChartSkeleton extends StatelessWidget {
  const _ChartSkeleton();
  @override
  Widget build(BuildContext context) => Card(
        child: SizedBox(
          height: 260,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
}

// ── Error panel ───────────────────────────────────────────────────────────────

class _ErrorPanel extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorPanel({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(error,
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
}
