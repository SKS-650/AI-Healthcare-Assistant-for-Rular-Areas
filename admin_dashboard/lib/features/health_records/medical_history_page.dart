import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../shared/widgets/data_table_card.dart';
import '../../shared/widgets/stat_card.dart';
import 'medical_history_provider.dart';

class MedicalHistoryPage extends ConsumerStatefulWidget {
  const MedicalHistoryPage({super.key});

  @override
  ConsumerState<MedicalHistoryPage> createState() => _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends ConsumerState<MedicalHistoryPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicalHistoryProvider);
    final notifier = ref.read(medicalHistoryProvider.notifier);
    final s = state.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Medical History',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700))
                .animate().fadeIn(duration: 400.ms),
            Text('All users\' medical conditions, diagnoses and history entries',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.lightTextMuted))
                .animate().fadeIn(delay: 100.ms),
          ])),
          OutlinedButton.icon(
            onPressed: () => _showExportDialog(context),
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Export'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => notifier.load(),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Refresh'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ]).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 20),
        LayoutBuilder(builder: (context, cst) {
          final cols = cst.maxWidth > 900 ? 4 : cst.maxWidth > 600 ? 2 : 1;
          return GridView.count(
            crossAxisCount: cols, crossAxisSpacing: 12, mainAxisSpacing: 12,
            childAspectRatio: 1.6, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              StatCard(title: 'Total Entries', value: '${s.total}',
                  icon: Icons.history_edu_rounded, color: AppColors.primary, animDelay: 0),
              StatCard(title: 'Active Conditions', value: '${s.active}',
                  icon: Icons.warning_amber_rounded, color: AppColors.error, animDelay: 60),
              StatCard(title: 'Resolved', value: '${s.resolved}',
                  icon: Icons.check_circle_rounded, color: AppColors.success, animDelay: 120),
              StatCard(title: 'Managed', value: '${s.managed}',
                  icon: Icons.manage_accounts_rounded, color: AppColors.info, animDelay: 180),
            ],
          );
        }),
        const SizedBox(height: 20),
        Wrap(spacing: 10, runSpacing: 8, children: [
          _statChip(context, 'Current', s.current, AppColors.primary),
          _statChip(context, 'Past', s.past, AppColors.accent),
          _statChip(context, 'Surgery', s.surgery, AppColors.warning),
          _statChip(context, 'Chronic', s.chronic, AppColors.error),
          _statChip(context, 'Family', s.family, AppColors.info),
        ]).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 20),
        DataTableCard(
          title: 'All Medical History Entries',
          isLoading: state.isLoading,
          totalRows: state.total,
          currentPage: state.page,
          pageSize: state.pageSize,
          onPageChanged: notifier.goToPage,
          searchBar: SearchField(
            controller: _searchCtrl,
            hint: 'Search by disease name or patient...',
            onChanged: (v) { if (v.isEmpty || v.length >= 2) notifier.setSearch(v); },
          ),
          filters: [
            _categoryDropdown(state.categoryFilter, notifier.setCategoryFilter),
            _statusDropdown(state.statusFilter, notifier.setStatusFilter),
          ],
          columns: const [
            DataColumn(label: Text('Patient')),
            DataColumn(label: Text('Disease/Condition')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Diagnosis Date')),
            DataColumn(label: Text('Doctor')),
            DataColumn(label: Text('Hospital')),
            DataColumn(label: Text('Actions')),
          ],
          rows: state.entries.map((e) => DataRow(cells: [
            DataCell(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(e.userName ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                if (e.userEmail != null)
                  Text(e.userEmail!, style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: AppColors.lightTextMuted)),
              ],
            )),
            DataCell(Text(e.diseaseName, style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w500))),
            DataCell(_CategoryBadge(category: e.category)),
            DataCell(_StatusChip(status: e.status)),
            DataCell(Text(
              e.diagnosisDate != null ? _fmtDate(e.diagnosisDate!) : '—',
              style: Theme.of(context).textTheme.bodySmall,
            )),
            DataCell(Text(e.doctorName ?? '—', style: Theme.of(context).textTheme.bodySmall)),
            DataCell(Text(e.hospitalName ?? '—', style: Theme.of(context).textTheme.bodySmall)),
            DataCell(IconButton(
              icon: const Icon(Icons.visibility_rounded, size: 16, color: AppColors.primary),
              onPressed: () => _showDetail(context, e),
            )),
          ])).toList(),
        ).animate().fadeIn(delay: 250.ms),
      ]),
    );
  }

  String _fmtDate(String iso) {
    final dt = DateTime.tryParse(iso)?.toLocal();
    return dt != null ? DateFormat('MMM d, y').format(dt) : iso;
  }

  Widget _statChip(BuildContext context, String label, int value, Color color) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('$value', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: color)),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
        ]),
      );

  Widget _categoryDropdown(String? value, ValueChanged<String?> onChanged) =>
      SizedBox(
        height: 40,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: value,
            hint: const Text('All categories', style: TextStyle(fontSize: 13)),
            items: [
              const DropdownMenuItem(value: null, child: Text('All categories')),
              ...['current', 'past', 'surgery', 'allergy', 'chronic', 'family'].map((c) =>
                  DropdownMenuItem(value: c,
                      child: Text(c.toUpperCase(), style: const TextStyle(fontSize: 13)))),
            ],
            onChanged: onChanged,
            isDense: true,
          ),
        ),
      );

  Widget _statusDropdown(String? value, ValueChanged<String?> onChanged) =>
      SizedBox(
        height: 40,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: value,
            hint: const Text('All status', style: TextStyle(fontSize: 13)),
            items: [
              const DropdownMenuItem(value: null, child: Text('All status')),
              ...['active', 'resolved', 'managed'].map((s) =>
                  DropdownMenuItem(value: s,
                      child: Text(s.toUpperCase(), style: const TextStyle(fontSize: 13)))),
            ],
            onChanged: onChanged,
            isDense: true,
          ),
        ),
      );

  void _showDetail(BuildContext context, MedicalHistoryEntry e) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Medical History Entry',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              _dRow(context, 'Patient', e.userName ?? '—'),
              _dRow(context, 'Disease', e.diseaseName),
              _dRow(context, 'Category', e.category.toUpperCase()),
              _dRow(context, 'Status', e.status.toUpperCase()),
              _dRow(context, 'Diagnosis Date',
                  e.diagnosisDate != null ? _fmtDate(e.diagnosisDate!) : '—'),
              _dRow(context, 'Doctor', e.doctorName ?? '—'),
              _dRow(context, 'Hospital', e.hospitalName ?? '—'),
              _dRow(context, 'Notes', e.notes ?? '—'),
              _dRow(context, 'Recorded', _fmtDate(e.createdAt)),
              const SizedBox(height: 16),
              Align(alignment: Alignment.centerRight,
                  child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'))),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _dRow(BuildContext context, String label, String value) =>
      Padding(padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 130, child: Text(label,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.lightTextMuted, fontWeight: FontWeight.w600))),
            Expanded(child: Text(value, style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w500))),
          ]));

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Medical History'),
        content: const Text('Export medical history data as CSV. All fields will be included.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton.icon(
            icon: const Icon(Icons.file_download_rounded, size: 16),
            label: const Text('Export CSV'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = switch (category.toLowerCase()) {
      'current' => AppColors.error,
      'chronic' => AppColors.warning,
      'past' => AppColors.info,
      'surgery' => AppColors.accent,
      'family' => AppColors.primary,
      _ => AppColors.lightTextMuted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(category.toUpperCase(),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status.toLowerCase()) {
      'active' => AppColors.error,
      'resolved' => AppColors.success,
      'managed' => AppColors.info,
      _ => AppColors.lightTextMuted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(status.toUpperCase(),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
