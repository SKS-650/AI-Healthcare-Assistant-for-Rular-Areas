import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../shared/widgets/chart_card.dart';
import '../../shared/widgets/stat_card.dart';
import 'analytics_provider.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});
  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analyticsProvider);
    final notifier = ref.read(analyticsProvider.notifier);

    return Column(children: [
      // Header + tabs
      Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Analytics & Insights',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700))
                  .animate().fadeIn(duration: 400.ms),
              Text('Symptom patterns, emergency trends & user engagement',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.lightTextMuted))
                  .animate().fadeIn(delay: 100.ms),
            ])),
            FilledButton.icon(
              onPressed: () {
                notifier.loadSymptomAnalytics();
                notifier.loadReports();
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Refresh'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ]),
          const SizedBox(height: 16),
          TabBar(
            controller: _tab,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.lightTextMuted,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Symptom Analytics'),
              Tab(text: 'User & Engagement'),
              Tab(text: 'Reports'),
            ],
          ),
        ]),
      ),

      Expanded(child: TabBarView(
        controller: _tab,
        children: [
          _SymptomTab(state: state),
          _EngagementTab(state: state, notifier: notifier),
          _ReportsTab(state: state, notifier: notifier),
        ],
      )),
    ]);
  }
}

// ── Tab 1: Symptom Analytics ──────────────────────────────────────────────────

class _SymptomTab extends StatelessWidget {
  final AnalyticsState state;
  const _SymptomTab({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingSymptoms) {
      return const Center(child: CircularProgressIndicator());
    }

    final stats = state.symptomStats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Stats from symptomStats
        if (stats != null)
          LayoutBuilder(builder: (context, cst) {
            final cols = cst.maxWidth > 900 ? 4 : cst.maxWidth > 600 ? 2 : 1;
            return GridView.count(
              crossAxisCount: cols, crossAxisSpacing: 16,
              mainAxisSpacing: 16, childAspectRatio: 1.6,
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              children: [
                StatCard(title: 'Total Assessments',
                    value: '${stats['total_assessments'] ?? 0}',
                    icon: Icons.analytics_rounded, color: AppColors.primary, animDelay: 0),
                StatCard(title: 'Emergency Detected',
                    value: '${stats['emergency_cases'] ?? 0}',
                    icon: Icons.warning_rounded, color: AppColors.error, animDelay: 80),
                StatCard(title: 'Avg Risk Score',
                    value: '${((stats['avg_risk_score'] ?? 0) as num).toStringAsFixed(1)}',
                    icon: Icons.speed_rounded, color: AppColors.warning, animDelay: 160),
                StatCard(title: 'Unique Patients',
                    value: '${stats['unique_users'] ?? 0}',
                    icon: Icons.people_rounded, color: AppColors.accent, animDelay: 240),
              ],
            );
          }).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 24),

        LayoutBuilder(builder: (context, cst) {
          final wide = cst.maxWidth > 800;
          final freqCard = _SymptomFrequencyCard(items: state.symptomFrequency);
          final riskCard = DonutChartCard(
            title: 'Risk Distribution',
            slices: state.riskDistribution.asMap().entries.map((e) {
              final level = e.value['risk_level'] as String? ?? '';
              final count = (e.value['count'] as num?)?.toInt() ?? 0;
              return PieSlice(
                label: level,
                value: count,
                color: switch (level.toUpperCase()) {
                  'CRITICAL' => AppColors.riskCritical,
                  'HIGH' => AppColors.riskHigh,
                  'MEDIUM' => AppColors.riskMedium,
                  _ => AppColors.riskLow,
                },
              );
            }).toList(),
            animDelay: 200,
          );
          return wide
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 3, child: freqCard),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: riskCard),
                ])
              : Column(children: [freqCard, const SizedBox(height: 16), riskCard]);
        }).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 24),

        // Gender + Age distribution
        LayoutBuilder(builder: (context, cst) {
          final wide = cst.maxWidth > 800;
          final genderCard = DonutChartCard(
            title: 'Gender Distribution',
            slices: state.genderDistribution.asMap().entries.map((e) {
              final gender = e.value['gender'] as String? ?? 'unknown';
              final count = (e.value['count'] as num?)?.toInt() ?? 0;
              return PieSlice(
                label: gender,
                value: count,
                color: AppColors.chartPalette[e.key % AppColors.chartPalette.length],
              );
            }).toList(),
            animDelay: 300,
          );
          final ageCard = BarChartCard(
            title: 'Age Group Distribution',
            groups: state.ageDistribution.map((d) => BarGroup(
              label: d['age_group'] as String? ?? '?',
              value: (d['count'] as num?)?.toInt() ?? 0,
            )).toList(),
            animDelay: 400,
          );
          return wide
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: genderCard),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: ageCard),
                ])
              : Column(children: [genderCard, const SizedBox(height: 16), ageCard]);
        }).animate().fadeIn(delay: 300.ms),

        // Assessment trend
        if (state.assessmentTrend.isNotEmpty) ...[
          const SizedBox(height: 24),
          LineChartCard(
            title: 'Assessment Trend (30 days)',
            series: [
              ChartSeries.fromMapList(
                state.assessmentTrend, 'total', 'date',
                'Assessments', AppColors.primary),
            ],
            animDelay: 400,
          ).animate().fadeIn(delay: 400.ms),
        ],

        // Top emergency types
        if (state.emergencyTypes.isNotEmpty) ...[
          const SizedBox(height: 24),
          _EmergencyTypesCard(types: state.emergencyTypes)
              .animate().fadeIn(delay: 500.ms),
        ],
      ]),
    );
  }
}

// ── Tab 2: User & Engagement ──────────────────────────────────────────────────

class _EngagementTab extends StatelessWidget {
  final AnalyticsState state;
  final AnalyticsNotifier notifier;
  const _EngagementTab({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingReports) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          const Text('Period: ', style: TextStyle(fontSize: 13)),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 7, label: Text('7d')),
              ButtonSegment(value: 30, label: Text('30d')),
              ButtonSegment(value: 90, label: Text('90d')),
            ],
            selected: {state.reportsDays},
            onSelectionChanged: (s) => notifier.changeReportDays(s.first),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) =>
                  states.contains(WidgetState.selected) ? AppColors.primary : null),
              foregroundColor: WidgetStateProperty.resolveWith((states) =>
                  states.contains(WidgetState.selected) ? Colors.white : null),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        LineChartCard(
          title: 'User Registrations',
          series: [ChartSeries.fromMapList(
              state.userRegistrationTrend, 'count', 'date', 'New Users', AppColors.primary)],
          animDelay: 100,
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 16),
        LineChartCard(
          title: 'Chatbot Daily Usage',
          series: [ChartSeries.fromMapList(
              state.chatbotDailyUsage, 'count', 'date', 'Conversations', AppColors.accent)],
          animDelay: 200,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 16),
        BarChartCard(
          title: 'Emergency Cases (Weekly)',
          groups: state.emergencyWeekly.map((d) => BarGroup(
            label: (d['date'] as String? ?? '').substring(5),
            value: (d['total'] as num?)?.toInt() ?? 0,
          )).toList(),
          animDelay: 300,
        ).animate().fadeIn(delay: 300.ms),
      ]),
    );
  }
}

// ── Tab 3: Reports ────────────────────────────────────────────────────────────

class _ReportsTab extends StatelessWidget {
  final AnalyticsState state;
  final AnalyticsNotifier notifier;
  const _ReportsTab({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        DonutChartCard(
          title: 'Health Education Engagement',
          slices: state.educationEngagement.asMap().entries.take(8).map((e) {
            final cat = e.value['category'] as String? ?? 'Unknown';
            final views = (e.value['views'] as num?)?.toInt() ?? 0;
            return PieSlice(
              label: cat,
              value: views,
              color: AppColors.chartPalette[e.key % AppColors.chartPalette.length],
            );
          }).toList(),
          animDelay: 100,
        ).animate().fadeIn(delay: 100.ms),
      ]),
    );
  }
}

// ── Symptom Frequency Card ────────────────────────────────────────────────────

class _SymptomFrequencyCard extends StatelessWidget {
  final List<SymptomFreqItem> items;
  const _SymptomFrequencyCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final maxCount = items.isEmpty ? 1
        : items.map((i) => i.count).reduce((a, b) => a > b ? a : b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Top Symptoms', style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(24),
                child: Text('No data yet')))
          else
            ...items.take(15).toList().asMap().entries.map((e) {
              final color = AppColors.chartPalette[e.key % AppColors.chartPalette.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(e.value.symptom,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w500))),
                    Text('${e.value.count}', style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: maxCount > 0 ? e.value.count / maxCount : 0,
                      minHeight: 6,
                      backgroundColor: color.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ]),
              );
            }),
        ]),
      ),
    );
  }
}

class _EmergencyTypesCard extends StatelessWidget {
  final List<Map<String, dynamic>> types;
  const _EmergencyTypesCard({required this.types});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Top Emergency Types',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...types.asMap().entries.map((e) {
              final type = e.value['type'] as String? ?? e.value['emergency_type'] as String? ?? 'Unknown';
              final count = e.value['count'] as int? ?? 0;
              final color = AppColors.chartPalette[e.key % AppColors.chartPalette.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  Container(width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: Text('${e.key + 1}',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)))),
                  const SizedBox(width: 10),
                  Expanded(child: Text(type, style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w500))),
                  Text('$count cases', style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
                ]),
              );
            }),
          ]),
        ),
      );
}
