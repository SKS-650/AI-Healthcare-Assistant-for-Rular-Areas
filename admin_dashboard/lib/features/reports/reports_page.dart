import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../core/theme.dart';
import '../../shared/widgets/chart_card.dart';

class _ReportsState {
  final bool isLoading; final String? error;
  final Map<String, dynamic> data;
  const _ReportsState({this.isLoading = false, this.error, this.data = const {}});
}

class _ReportsNotifier extends StateNotifier<_ReportsState> {
  _ReportsNotifier() : super(const _ReportsState()) { load(); }
  Future<void> load({int days = 30}) async {
    state = const _ReportsState(isLoading: true);
    try {
      final resp = await ApiClient.instance.get('/admin/reports', queryParameters: {'days': days});
      state = _ReportsState(data: resp.data as Map<String, dynamic>);
    } catch (e) {
      state = _ReportsState(error: ApiResult.fromError(e).error);
    }
  }
}

final _reportsProvider = StateNotifierProvider<_ReportsNotifier, _ReportsState>((ref) => _ReportsNotifier());

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_reportsProvider);
    final notifier = ref.read(_reportsProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Reports & Analytics', style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700)).animate().fadeIn(duration: 400.ms),
            Text('Comprehensive system analytics and reports',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.lightTextMuted))
                .animate().fadeIn(delay: 100.ms),
          ])),
          // Period selector
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 7, label: Text('7d')),
              ButtonSegment(value: 30, label: Text('30d')),
              ButtonSegment(value: 90, label: Text('90d')),
            ],
            selected: const {30},
            onSelectionChanged: (s) => notifier.load(days: s.first),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) =>
                  states.contains(WidgetState.selected) ? AppColors.primary : null),
              foregroundColor: WidgetStateProperty.resolveWith((states) =>
                  states.contains(WidgetState.selected) ? Colors.white : null),
            ),
          ),
        ]),
        const SizedBox(height: 24),

        if (state.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (state.error != null)
          Center(child: Column(children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(state.error!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 12),
            FilledButton(onPressed: notifier.load, child: const Text('Retry')),
          ]))
        else ...[
          // User registration trend
          LineChartCard(
            title: 'User Registration Trend',
            subtitle: 'Daily new user registrations',
            series: [
              ChartSeries.fromMapList(
                (state.data['user_registration_trend'] as List? ?? []).cast<Map<String, dynamic>>(),
                'count', 'date', 'Registrations', AppColors.primary,
              ),
            ],
            animDelay: 100,
          ),
          const SizedBox(height: 16),

          LayoutBuilder(builder: (ctx, cst) {
            final wide = cst.maxWidth > 900;
            final riskDist = (state.data['risk_distribution'] as List? ?? []).cast<Map<String, dynamic>>();
            final chatUsage = (state.data['chatbot_daily_usage'] as List? ?? []).cast<Map<String, dynamic>>();

            final riskCard = DonutChartCard(
              title: 'Risk Distribution',
              slices: riskDist.asMap().entries.map((e) {
                final level = e.value['risk_level'] as String? ?? '';
                final count = e.value['count'] as int? ?? 0;
                return PieSlice(
                  label: '$level (${e.value['percentage']}%)',
                  value: count,
                  color: switch (level) {
                    'CRITICAL' => AppColors.riskCritical,
                    'HIGH' => AppColors.riskHigh,
                    'MEDIUM' => AppColors.riskMedium,
                    _ => AppColors.riskLow,
                  },
                );
              }).toList(),
              animDelay: 200,
            );

            final chatCard = LineChartCard(
              title: 'Chatbot Daily Usage',
              subtitle: 'Conversations per day',
              series: [
                ChartSeries.fromMapList(chatUsage, 'count', 'date', 'Conversations', AppColors.accent),
              ],
              animDelay: 300,
            );

            return wide
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(flex: 2, child: riskCard),
                    const SizedBox(width: 16),
                    Expanded(flex: 3, child: chatCard),
                  ])
                : Column(children: [riskCard, const SizedBox(height: 16), chatCard]);
          }),
          const SizedBox(height: 16),

          // Emergency weekly
          BarChartCard(
            title: 'Emergency Cases (Last 7 Days)',
            groups: ((state.data['emergency_weekly'] as List? ?? [])
                .cast<Map<String, dynamic>>()
                .map((d) {
                  final date = d['date'] as String? ?? '';
                  final label = date.length >= 5 ? date.substring(5) : date;
                  return BarGroup(label: label, value: (d['total'] as num?)?.toInt() ?? 0);
                })
                .toList()),
            animDelay: 400,
          ),
        ],
      ]),
    );
  }
}
