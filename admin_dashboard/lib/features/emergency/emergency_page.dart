import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models.dart';
import '../../core/theme.dart';
import '../../shared/widgets/data_table_card.dart';
import '../../shared/widgets/stat_card.dart';
import 'emergency_provider.dart';

class EmergencyPage extends ConsumerWidget {
  const EmergencyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(emergencyProvider);
    final notifier = ref.read(emergencyProvider.notifier);
    final s = state.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Emergency Monitoring',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w700))
                        .animate().fadeIn(duration: 400.ms),
                    Text('Real-time emergency assessment monitoring',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: AppColors.lightTextMuted))
                        .animate().fadeIn(delay: 100.ms),
                  ],
                ),
              ),
              if (s.todayCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.errorSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: AppColors.error, size: 16),
                      const SizedBox(width: 6),
                      Text('${s.todayCount} today',
                          style: const TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms),
            ],
          ),
          const SizedBox(height: 24),

          // Stats grid
          LayoutBuilder(builder: (context, cst) {
            final cols = cst.maxWidth > 900 ? 4 : cst.maxWidth > 600 ? 3 : 2;
            return GridView.count(
              crossAxisCount: cols,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.6,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                StatCard(title: 'Total Cases', value: '${s.total}',
                    icon: Icons.emergency_rounded, color: AppColors.info, animDelay: 0),
                StatCard(title: 'Critical', value: '${s.critical}',
                    subtitle: 'Immediate attention', icon: Icons.crisis_alert_rounded,
                    color: AppColors.riskCritical, animDelay: 80),
                StatCard(title: 'High Risk', value: '${s.high}',
                    icon: Icons.warning_rounded, color: AppColors.riskHigh, animDelay: 160),
                StatCard(title: 'SOS Triggered', value: '${s.sosTriggered}',
                    icon: Icons.sos_rounded, color: AppColors.error, animDelay: 240),
              ],
            );
          }),
          const SizedBox(height: 24),

          // Filter row
          Row(
            children: [
              _RiskFilter(value: state.riskFilter, onChanged: notifier.setRiskFilter),
              const SizedBox(width: 12),
              _EmergencyOnlyFilter(value: state.isEmergencyFilter, onChanged: notifier.setEmergencyFilter),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => notifier.load(),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Refresh'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),

          // Table
          DataTableCard(
            title: 'Emergency Assessments',
            isLoading: state.isLoading,
            totalRows: state.total,
            currentPage: state.page,
            pageSize: state.pageSize,
            onPageChanged: notifier.goToPage,
            columns: const [
              DataColumn(label: Text('Patient')),
              DataColumn(label: Text('Risk Level')),
              DataColumn(label: Text('Score')),
              DataColumn(label: Text('Possible Emergency')),
              DataColumn(label: Text('Symptoms')),
              DataColumn(label: Text('SOS')),
              DataColumn(label: Text('Date')),
            ],
            rows: state.items.map((e) => DataRow(
              color: WidgetStateProperty.resolveWith((_) =>
                  e.riskLevel == 'CRITICAL'
                      ? AppColors.riskCritical.withOpacity(0.04)
                      : e.riskLevel == 'HIGH'
                          ? AppColors.riskHigh.withOpacity(0.03)
                          : null),
              cells: [
                DataCell(_PatientCell(item: e)),
                DataCell(RiskBadge(level: e.riskLevel)),
                DataCell(_ScoreBar(score: e.riskScore)),
                DataCell(SizedBox(
                  width: 180,
                  child: Text(e.possibleEmergency ?? '—',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis),
                )),
                DataCell(SizedBox(
                  width: 200,
                  child: Text(e.symptoms.take(3).join(', ') +
                      (e.symptoms.length > 3 ? '...' : ''),
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis),
                )),
                DataCell(e.sosRequired
                    ? const Icon(Icons.sos_rounded, color: AppColors.error, size: 20)
                    : const Icon(Icons.check_circle_outline_rounded,
                        color: AppColors.success, size: 20)),
                DataCell(Text(DateFormat('MMM d, HH:mm').format(e.createdAt),
                    style: Theme.of(context).textTheme.bodySmall)),
              ],
            )).toList(),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}

class _PatientCell extends StatelessWidget {
  final EmergencyItem item;
  const _PatientCell({required this.item});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(item.userName ?? 'Anonymous',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
      if (item.age != null || item.gender != null)
        Text('${item.age ?? '?'}y / ${item.gender ?? '?'}',
            style: Theme.of(context).textTheme.labelSmall),
    ],
  );
}

class _ScoreBar extends StatelessWidget {
  final int score;
  const _ScoreBar({required this.score});
  Color get _color => score >= 85 ? AppColors.riskCritical
      : score >= 70 ? AppColors.riskHigh
      : score >= 50 ? AppColors.riskMedium
      : AppColors.riskLow;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: 60,
        height: 6,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: _color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation(_color),
          ),
        ),
      ),
      const SizedBox(width: 6),
      Text('$score%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _color)),
    ],
  );
}

class _RiskFilter extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const _RiskFilter({this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => DropdownButtonHideUnderline(
    child: DropdownButton<String?>(
      value: value,
      hint: const Text('All risks', style: TextStyle(fontSize: 13)),
      items: [
        const DropdownMenuItem(value: null, child: Text('All risks')),
        ...['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'].map(
          (r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13))),
        ),
      ],
      onChanged: onChanged, isDense: true,
    ),
  );
}

class _EmergencyOnlyFilter extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?> onChanged;
  const _EmergencyOnlyFilter({this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => DropdownButtonHideUnderline(
    child: DropdownButton<bool?>(
      value: value,
      hint: const Text('All types', style: TextStyle(fontSize: 13)),
      items: const [
        DropdownMenuItem(value: null, child: Text('All types')),
        DropdownMenuItem(value: true, child: Text('Emergency only')),
        DropdownMenuItem(value: false, child: Text('Non-emergency')),
      ],
      onChanged: onChanged, isDense: true,
    ),
  );
}
