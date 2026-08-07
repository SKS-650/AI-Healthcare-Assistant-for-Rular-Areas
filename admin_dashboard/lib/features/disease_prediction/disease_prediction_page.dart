import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../shared/widgets/data_table_card.dart';
import '../../shared/widgets/stat_card.dart';
import 'disease_prediction_provider.dart';

class DiseasePredictionPage extends ConsumerWidget {
  const DiseasePredictionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(diseasePredictionProvider);
    final notifier = ref.read(diseasePredictionProvider.notifier);
    final stats = state.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Disease Prediction & Symptom Checker',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700))
                .animate().fadeIn(duration: 400.ms),
            Text('AI model management, prediction history & analytics',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.lightTextMuted))
                .animate().fadeIn(delay: 100.ms),
          ])),
          if (stats != null)
            _ModelStatusBadge(loaded: stats.modelLoaded),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: () async {
              final ok = await notifier.reloadModel();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? 'Model reloaded successfully' : 'Failed to reload model'),
                  backgroundColor: ok ? AppColors.success : AppColors.error,
                ));
              }
            },
            icon: const Icon(Icons.memory_rounded, size: 16),
            label: const Text('Reload Model'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.info),
          ),
        ]).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 24),

        // Stats
        if (stats != null)
          LayoutBuilder(builder: (context, cst) {
            final cols = cst.maxWidth > 900 ? 4 : cst.maxWidth > 600 ? 3 : 2;
            return GridView.count(
              crossAxisCount: cols, crossAxisSpacing: 16,
              mainAxisSpacing: 16, childAspectRatio: 1.6,
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              children: [
                StatCard(title: 'Total Predictions', value: '${stats.totalPredictions}',
                    icon: Icons.analytics_rounded, color: AppColors.primary, animDelay: 0),
                StatCard(title: 'Emergency Flags', value: '${stats.emergencyFlags}',
                    subtitle: 'Detected as urgent',
                    icon: Icons.warning_rounded, color: AppColors.error, animDelay: 80),
                StatCard(title: 'Symptoms Available', value: '${stats.availableSymptoms}',
                    icon: Icons.medical_information_rounded,
                    color: AppColors.info, animDelay: 160),
                StatCard(title: 'Diseases Recognized', value: '${stats.availableDiseases}',
                    icon: Icons.local_hospital_rounded,
                    color: AppColors.accent, animDelay: 240),
              ],
            );
          }).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 24),

        // Model info & top diseases row
        if (stats != null)
          LayoutBuilder(builder: (context, cst) {
            final wide = cst.maxWidth > 800;
            return wide
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(flex: 2, child: _ModelInfoCard(stats: stats)),
                    const SizedBox(width: 16),
                    Expanded(flex: 3, child: _TopDiseasesCard(diseases: stats.topDiseases)),
                  ])
                : Column(children: [
                    _ModelInfoCard(stats: stats),
                    const SizedBox(height: 16),
                    _TopDiseasesCard(diseases: stats.topDiseases),
                  ]);
          }).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 24),

        // History table
        DataTableCard(
          title: 'Prediction History',
          isLoading: state.isLoading,
          totalRows: state.total,
          currentPage: state.page,
          pageSize: state.pageSize,
          onPageChanged: (p) => notifier.goToPage(p),
          filters: [
            _RiskFilter(value: state.riskFilter, onChanged: notifier.setRiskFilter),
            _EmergencyFilter(value: state.isEmergencyFilter, onChanged: notifier.setEmergencyFilter),
          ],
          columns: const [
            DataColumn(label: Text('Patient')),
            DataColumn(label: Text('Symptoms')),
            DataColumn(label: Text('Predicted Disease')),
            DataColumn(label: Text('Confidence')),
            DataColumn(label: Text('Risk')),
            DataColumn(label: Text('Emergency')),
            DataColumn(label: Text('Date')),
          ],
          rows: state.predictions.map((p) => DataRow(cells: [
            DataCell(_PatientCell(record: p)),
            DataCell(SizedBox(width: 180,
                child: Text(p.symptoms.take(3).join(', ') + (p.symptoms.length > 3 ? '...' : ''),
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis))),
            DataCell(Text(p.predictedDisease ?? '—',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
            DataCell(_ConfidenceBar(value: p.confidence ?? 0)),
            DataCell(p.riskLevel != null
                ? _RiskBadge(level: p.riskLevel!)
                : const Text('—')),
            DataCell(p.isEmergency
                ? const Icon(Icons.warning_rounded, color: AppColors.error, size: 18)
                : const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 18)),
            DataCell(Text(DateFormat('MMM d, HH:mm').format(p.createdAt),
                style: Theme.of(context).textTheme.bodySmall)),
          ])).toList(),
        ).animate().fadeIn(delay: 300.ms),
      ]),
    );
  }
}

class _ModelStatusBadge extends StatelessWidget {
  final bool loaded;
  const _ModelStatusBadge({required this.loaded});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: loaded ? AppColors.successSurface : AppColors.errorSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: loaded ? AppColors.success : AppColors.error, width: 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(loaded ? Icons.circle : Icons.circle_outlined,
              size: 8,
              color: loaded ? AppColors.success : AppColors.error),
          const SizedBox(width: 6),
          Text(loaded ? 'Model Online' : 'Model Offline',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: loaded ? AppColors.success : AppColors.error)),
        ]),
      );
}

class _ModelInfoCard extends StatelessWidget {
  final DiseasePredictionStats stats;
  const _ModelInfoCard({required this.stats});
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Model Information',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _row(context, 'Status', stats.modelLoaded ? 'Loaded' : 'Not Loaded'),
            _row(context, 'Version', stats.modelVersion ?? 'Unknown'),
            _row(context, 'Features', '${stats.availableSymptoms} symptoms'),
            _row(context, 'Classes', '${stats.availableDiseases} diseases'),
            _row(context, 'Emergency Rate',
                stats.totalPredictions > 0
                    ? '${(stats.emergencyFlags / stats.totalPredictions * 100).toStringAsFixed(1)}%'
                    : '—'),
          ]),
        ),
      );

  Widget _row(BuildContext context, String label, String value) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          SizedBox(width: 110,
              child: Text(label, style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.lightTextMuted))),
          Text(value, style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(fontWeight: FontWeight.w600)),
        ]),
      );
}

class _TopDiseasesCard extends StatelessWidget {
  final List<Map<String, dynamic>> diseases;
  const _TopDiseasesCard({required this.diseases});
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Top Predicted Diseases',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            if (diseases.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(24),
                  child: Text('No prediction data yet')))
            else
              ...diseases.asMap().entries.map((e) {
                final disease = e.value['disease'] as String? ?? '';
                final count = e.value['count'] as int? ?? 0;
                final maxCount = diseases.map((d) => d['count'] as int? ?? 0).reduce((a, b) => a > b ? a : b);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.chartPalette[e.key % AppColors.chartPalette.length].withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(child: Text('${e.key + 1}',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                              color: AppColors.chartPalette[e.key % AppColors.chartPalette.length]))),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(disease, style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: maxCount > 0 ? count / maxCount : 0,
                          minHeight: 4,
                          backgroundColor: AppColors.lightBorder,
                          valueColor: AlwaysStoppedAnimation(
                              AppColors.chartPalette[e.key % AppColors.chartPalette.length]),
                        ),
                      ),
                    ])),
                    const SizedBox(width: 8),
                    Text('$count', style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                  ]),
                );
              }),
          ]),
        ),
      );
}

class _PatientCell extends StatelessWidget {
  final PredictionRecord record;
  const _PatientCell({required this.record});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(record.userName ?? 'Anonymous',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
          if (record.age != null || record.gender != null)
            Text('${record.age ?? '?'}y / ${record.gender ?? '?'}',
                style: Theme.of(context).textTheme.labelSmall),
        ],
      );
}

class _ConfidenceBar extends StatelessWidget {
  final double value;
  const _ConfidenceBar({required this.value});
  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).clamp(0, 100).toStringAsFixed(0);
    final color = value >= 0.8 ? AppColors.success
        : value >= 0.6 ? AppColors.warning : AppColors.error;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(width: 56, height: 5,
          child: ClipRRect(borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(value: value.clamp(0.0, 1.0),
                  backgroundColor: color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation(color)))),
      const SizedBox(width: 6),
      Text('$pct%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    ]);
  }
}

class _RiskBadge extends StatelessWidget {
  final String level;
  const _RiskBadge({required this.level});
  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (level.toUpperCase()) {
      'CRITICAL' => (const Color(0xFFF3E8FF), AppColors.riskCritical),
      'HIGH' => (AppColors.errorSurface, AppColors.riskHigh),
      'MEDIUM' => (AppColors.warningSurface, AppColors.riskMedium),
      _ => (AppColors.successSurface, AppColors.riskLow),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(level, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
    );
  }
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
            ...['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'].map((r) =>
                DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13)))),
          ],
          onChanged: onChanged, isDense: true,
        ),
      );
}

class _EmergencyFilter extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?> onChanged;
  const _EmergencyFilter({this.value, required this.onChanged});
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
