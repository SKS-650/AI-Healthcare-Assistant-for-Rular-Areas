import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../shared/widgets/chart_card.dart';
import '../../shared/widgets/data_table_card.dart';
import '../../shared/widgets/stat_card.dart';
import 'dashboard_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final s = state.stats;
    final fmt = NumberFormat.compact();

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Page header ──────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dashboard Overview',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w700))
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: -0.05),
                    Text(
                      'Welcome back! Here\'s what\'s happening today.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.lightTextMuted),
                    ).animate().fadeIn(delay: 100.ms),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () =>
                    ref.read(dashboardProvider.notifier).load(),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Refresh'),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary),
              ).animate().fadeIn(delay: 200.ms),
            ],
          ),
          const SizedBox(height: 24),

          // ── Stat cards row ───────────────────────────────────────────────
          LayoutBuilder(builder: (context, cst) {
            final cols = cst.maxWidth > 1100
                ? 4
                : cst.maxWidth > 700
                    ? 3
                    : 2;
            return GridView.count(
              crossAxisCount: cols,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.6,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                StatCard(
                  title: 'Total Users',
                  value: fmt.format(s.totalUsers),
                  subtitle: '+${s.newUsersToday} today',
                  icon: Icons.people_rounded,
                  color: AppColors.primary,
                  trend: '+${s.newUsersThisWeek} this week',
                  trendUp: true,
                  animDelay: 0,
                ),
                StatCard(
                  title: 'Active Users',
                  value: fmt.format(s.activeUsers),
                  subtitle:
                      '${s.totalUsers > 0 ? (s.activeUsers / s.totalUsers * 100).toStringAsFixed(0) : 0}% of total',
                  icon: Icons.person_rounded,
                  color: AppColors.success,
                  animDelay: 80,
                ),
                StatCard(
                  title: 'Chatbot Sessions',
                  value: fmt.format(s.totalChatbotConversations),
                  subtitle: '+${s.chatbotConversationsToday} today',
                  icon: Icons.chat_bubble_rounded,
                  color: AppColors.accent,
                  animDelay: 160,
                ),
                StatCard(
                  title: 'Emergency Cases',
                  value: fmt.format(s.totalEmergencyAssessments),
                  subtitle: '${s.highRiskEmergencies} high risk',
                  icon: Icons.emergency_rounded,
                  color: AppColors.error,
                  trend:
                      '+${s.emergencyAssessmentsToday} today',
                  trendUp: false,
                  animDelay: 240,
                ),
                StatCard(
                  title: 'Health Articles',
                  value: fmt.format(s.totalHealthArticles),
                  subtitle: '${s.publishedArticles} published',
                  icon: Icons.menu_book_rounded,
                  color: AppColors.warning,
                  animDelay: 320,
                ),
                StatCard(
                  title: 'SOS Alerts',
                  value: fmt.format(s.totalSosEvents),
                  subtitle: 'Total triggered',
                  icon: Icons.sos_rounded,
                  color: AppColors.riskCritical,
                  animDelay: 400,
                ),
                StatCard(
                  title: 'Symptom Checks',
                  value: fmt.format(s.totalSymptomChecks),
                  subtitle: 'AI assessments',
                  icon: Icons.healing_rounded,
                  color: AppColors.info,
                  animDelay: 480,
                ),
                StatCard(
                  title: 'New Today',
                  value: fmt.format(s.newUsersToday),
                  subtitle: 'User registrations',
                  icon: Icons.person_add_rounded,
                  color: AppColors.primaryLight,
                  animDelay: 560,
                ),
              ],
            );
          }),

          const SizedBox(height: 24),

          // ── Charts row ───────────────────────────────────────────────────
          LayoutBuilder(builder: (context, cst) {
            final wide = cst.maxWidth > 900;
            return wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: LineChartCard(
                          title: 'User Growth',
                          subtitle: 'Daily new registrations (last 30 days)',
                          series: [
                            ChartSeries.fromMapList(
                              state.userGrowth,
                              'count',
                              'date',
                              'New Users',
                              AppColors.primary,
                            ),
                          ],
                          animDelay: 200,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: DonutChartCard(
                          title: 'Emergency Risk Distribution',
                          slices: _buildRiskSlices(state.emergencyTrend),
                          animDelay: 300,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      LineChartCard(
                        title: 'User Growth',
                        series: [
                          ChartSeries.fromMapList(
                            state.userGrowth,
                            'count',
                            'date',
                            'New Users',
                            AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DonutChartCard(
                        title: 'Emergency Risk Distribution',
                        slices: _buildRiskSlices(state.emergencyTrend),
                      ),
                    ],
                  );
          }),

          const SizedBox(height: 24),

          // ── Chatbot trend + Emergency trend ──────────────────────────────
          LayoutBuilder(builder: (context, cst) {
            final wide = cst.maxWidth > 900;
            final chatCard = LineChartCard(
              title: 'Chatbot Activity',
              subtitle: 'Daily conversations (last 14 days)',
              series: [
                ChartSeries.fromMapList(
                  state.chatbotTrend,
                  'count',
                  'date',
                  'Conversations',
                  AppColors.accent,
                ),
              ],
              animDelay: 400,
            );
            final emergencyCard = LineChartCard(
              title: 'Emergency Trend',
              subtitle: 'Daily assessments (last 14 days)',
              series: [
                ChartSeries.fromMapList(
                  state.emergencyTrend,
                  'total',
                  'date',
                  'Total',
                  AppColors.error,
                ),
                ChartSeries.fromMapList(
                  state.emergencyTrend,
                  'high_risk',
                  'date',
                  'High Risk',
                  AppColors.riskCritical,
                ),
              ],
              animDelay: 450,
            );
            return wide
                ? Row(
                    children: [
                      Expanded(child: chatCard),
                      const SizedBox(width: 16),
                      Expanded(child: emergencyCard),
                    ],
                  )
                : Column(children: [
                    chatCard,
                    const SizedBox(height: 16),
                    emergencyCard
                  ]);
          }),

          const SizedBox(height: 24),

          // ── Recent users + recent emergencies ────────────────────────────
          LayoutBuilder(builder: (context, cst) {
            final wide = cst.maxWidth > 900;
            final usersCard = _RecentUsersCard(
                users: state.recentUsers);
            final emergCard = _RecentEmergenciesCard(
                emergencies: state.recentEmergencies);
            return wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: usersCard),
                      const SizedBox(width: 16),
                      Expanded(child: emergCard),
                    ],
                  )
                : Column(children: [
                    usersCard,
                    const SizedBox(height: 16),
                    emergCard
                  ]);
          }),
        ],
      ),
    );
  }

  List<PieSlice> _buildRiskSlices(
      List<Map<String, dynamic>> trend) {
    // count high_risk vs normal from trend data
    int high = 0, total = 0;
    for (final d in trend) {
      total += (d['total'] as num?)?.toInt() ?? 0;
      high += (d['high_risk'] as num?)?.toInt() ?? 0;
    }
    final low = (total - high).clamp(0, total);
    return [
      PieSlice(
          label: 'Low/Medium',
          value: low,
          color: AppColors.success),
      PieSlice(
          label: 'High/Critical',
          value: high,
          color: AppColors.error),
    ];
  }
}

// ── Recent users mini-table ───────────────────────────────────────────────────
class _RecentUsersCard extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  const _RecentUsersCard({required this.users});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Registrations',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            if (users.isEmpty)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No users yet')))
            else
              ...users.map((u) => _UserTile(user: u)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms);
  }
}

class _UserTile extends StatelessWidget {
  final Map<String, dynamic> user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user['full_name'] as String? ?? 'Unknown';
    final email = user['email'] as String? ?? '';
    final role = user['role'] as String? ?? 'patient';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(initials,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis),
                Text(email,
                    style: Theme.of(context).textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.accentSurface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(role.toUpperCase(),
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

// ── Recent emergencies mini-list ──────────────────────────────────────────────
class _RecentEmergenciesCard extends StatelessWidget {
  final List<Map<String, dynamic>> emergencies;
  const _RecentEmergenciesCard({required this.emergencies});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Emergencies',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            if (emergencies.isEmpty)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No emergencies yet')))
            else
              ...emergencies.map((e) => _EmergencyTile(data: e)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 400.ms);
  }
}

class _EmergencyTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const _EmergencyTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final risk = data['risk_level'] as String? ?? 'LOW';
    final name = data['user_name'] as String? ?? 'Anonymous';
    final possible = data['possible_emergency'] as String? ?? 'Unknown';
    final score = data['risk_score'] as int? ?? 0;

    final riskColor = switch (risk.toUpperCase()) {
      'CRITICAL' => AppColors.riskCritical,
      'HIGH' => AppColors.riskHigh,
      'MEDIUM' => AppColors.riskMedium,
      _ => AppColors.riskLow,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(Icons.warning_rounded, color: riskColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis),
                Text(possible,
                    style: Theme.of(context).textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          RiskBadge(level: risk),
          const SizedBox(width: 8),
          Text('$score%',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: riskColor)),
        ],
      ),
    );
  }
}
