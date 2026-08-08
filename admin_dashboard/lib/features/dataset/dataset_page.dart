import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../shared/widgets/data_table_card.dart';
import '../../shared/widgets/stat_card.dart';
import 'dataset_provider.dart';

class DatasetPage extends ConsumerWidget {
  const DatasetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(datasetProvider);
    final notifier = ref.read(datasetProvider.notifier);
    final statsData = state.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Dataset Management',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700))
                .animate().fadeIn(duration: 400.ms),
            Text('Version control for AI training datasets',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.lightTextMuted))
                .animate().fadeIn(delay: 100.ms),
          ])),
          OutlinedButton.icon(
            onPressed: () => _showCreateDialog(context, notifier),
            icon: const Icon(Icons.upload_rounded, size: 16),
            label: const Text('Register Dataset'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () { notifier.loadDatasets(); notifier.loadStats(); },
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Refresh'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ]).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 24),

        // Stats
        if (statsData != null)
          LayoutBuilder(builder: (context, cst) {
            final cols = cst.maxWidth > 700 ? 3 : 2;
            return GridView.count(
              crossAxisCount: cols, crossAxisSpacing: 16,
              mainAxisSpacing: 16, childAspectRatio: 1.7,
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              children: [
                StatCard(title: 'Total Datasets', value: '${statsData['total_datasets'] ?? 0}',
                    icon: Icons.dataset_rounded, color: AppColors.primary, animDelay: 0),
                StatCard(title: 'Active', value: '${statsData['active_datasets'] ?? 0}',
                    icon: Icons.check_circle_rounded, color: AppColors.success, animDelay: 80),
                StatCard(title: 'Types', value: '${(statsData['type_counts'] as Map? ?? {}).length}',
                    subtitle: 'Distinct dataset types',
                    icon: Icons.category_rounded, color: AppColors.accent, animDelay: 160),
              ],
            );
          }).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 24),

        // Type breakdown
        if (statsData != null && (statsData['type_counts'] as Map? ?? {}).isNotEmpty)
          _TypeBreakdownCard(byType: Map<String, int>.from(statsData['type_counts'] as Map))
              .animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 24),

        // Dataset table
        DataTableCard(
          title: 'Dataset Versions',
          isLoading: state.isLoading,
          totalRows: state.total,
          currentPage: state.page,
          pageSize: state.pageSize,
          onPageChanged: (p) => notifier.goToPage(p),
          filters: [
            _TypeFilter(value: state.typeFilter, onChanged: notifier.setTypeFilter),
          ],
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Version')),
            DataColumn(label: Text('Records')),
            DataColumn(label: Text('Size')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Created')),
            DataColumn(label: Text('Actions')),
          ],
          rows: state.datasets.map((d) => DataRow(
            color: WidgetStateProperty.resolveWith((_) =>
                d.isActive ? AppColors.success.withValues(alpha: 0.04) : null),
            cells: [
              DataCell(Text(d.name, style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600))),
              DataCell(_TypeChip(type: d.datasetType)),
              DataCell(Text('v${d.version}',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(fontFamily: 'monospace'))),
              DataCell(Text(d.recordCount != null ? '${d.recordCount}' : '—',
                  style: Theme.of(context).textTheme.bodySmall)),
              DataCell(Text(d.fileSizeKb != null ? '${d.fileSizeKb} KB' : '—',
                  style: Theme.of(context).textTheme.bodySmall)),
              DataCell(d.isActive
                  ? _ActiveChip()
                  : StatusBadge(active: false, inactiveLabel: 'Inactive')),
              DataCell(Text(DateFormat('MMM d, y').format(d.createdAt),
                  style: Theme.of(context).textTheme.bodySmall)),
              DataCell(_DatasetActions(dataset: d, notifier: notifier)),
            ],
          )).toList(),
        ).animate().fadeIn(delay: 300.ms),
      ]),
    );
  }

  void _showCreateDialog(BuildContext context, DatasetNotifier notifier) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CreateDatasetDialog(notifier: notifier),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _TypeBreakdownCard extends StatelessWidget {
  final Map<String, int> byType;
  const _TypeBreakdownCard({required this.byType});
  @override
  Widget build(BuildContext context) {
    final types = byType.entries.toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('By Type', style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Wrap(spacing: 12, runSpacing: 10,
              children: types.asMap().entries.map((e) {
                final color = AppColors.chartPalette[e.key % AppColors.chartPalette.length];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 8, height: 8,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(e.value.key.toUpperCase(),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                    const SizedBox(width: 8),
                    Text('${e.value.value}', style: TextStyle(fontSize: 12, color: color)),
                  ]),
                );
              }).toList()),
        ]),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String type;
  const _TypeChip({required this.type});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(type.toUpperCase(),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                color: AppColors.primary)),
      );
}

class _ActiveChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.successSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.circle, size: 6, color: AppColors.success),
          SizedBox(width: 5),
          Text('Active', style: TextStyle(fontSize: 11,
              fontWeight: FontWeight.w700, color: AppColors.success)),
        ]),
      );
}

class _DatasetActions extends StatelessWidget {
  final DatasetVersionItem dataset;
  final DatasetNotifier notifier;
  const _DatasetActions({required this.dataset, required this.notifier});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        if (!dataset.isActive)
          Tooltip(
            message: 'Activate this version',
            child: IconButton(
              icon: const Icon(Icons.check_circle_outline_rounded,
                  size: 16, color: AppColors.success),
              onPressed: () => _activate(context),
            ),
          ),
        Tooltip(
          message: 'Delete dataset',
          child: IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                size: 16, color: AppColors.error),
            onPressed: () => _confirmDelete(context),
          ),
        ),
      ]);

  Future<void> _activate(BuildContext ctx) async {
    final ok = await notifier.activateDataset(dataset.id);
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(ok ? '${dataset.name} activated' : 'Failed to activate'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ));
    }
  }

  Future<void> _confirmDelete(BuildContext ctx) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dlg) => AlertDialog(
        title: const Text('Delete Dataset'),
        content: Text('Delete "${dataset.name} v${dataset.version}"? Cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dlg, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(dlg, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await notifier.deleteDataset(dataset.id);
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(ok ? 'Dataset deleted' : 'Failed to delete'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ));
    }
  }
}

class _TypeFilter extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const _TypeFilter({this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 40,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: value, isDense: true,
            hint: const Text('All types', style: TextStyle(fontSize: 13)),
            items: [
              const DropdownMenuItem(value: null, child: Text('All types')),
              ...['symptom', 'chatbot', 'disease', 'faq'].map((t) =>
                  DropdownMenuItem(value: t, child: Text(t.toUpperCase(),
                      style: const TextStyle(fontSize: 13)))),
            ],
            onChanged: onChanged,
          ),
        ),
      );
}

class _CreateDatasetDialog extends StatefulWidget {
  final DatasetNotifier notifier;
  const _CreateDatasetDialog({required this.notifier});
  @override
  State<_CreateDatasetDialog> createState() => _CreateDatasetDialogState();
}

class _CreateDatasetDialogState extends State<_CreateDatasetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _version = TextEditingController(text: '1.0.0');
  final _desc = TextEditingController();
  String _type = 'symptom';
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose(); _version.dispose(); _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Register New Dataset',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                if (_error != null) ...[
                  Container(padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.errorSurface,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(_error!, style: const TextStyle(color: AppColors.error))),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Dataset Name *'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ['symptom', 'chatbot', 'disease', 'faq']
                      .map((t) => DropdownMenuItem(value: t,
                          child: Text(t.toUpperCase())))
                      .toList(),
                  onChanged: (v) => setState(() => _type = v!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _version,
                  decoration: const InputDecoration(labelText: 'Version'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _desc,
                  decoration: const InputDecoration(labelText: 'Description (optional)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(child: OutlinedButton(
                      onPressed: _loading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'))),
                  const SizedBox(width: 12),
                  Expanded(child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Register'),
                  )),
                ]),
              ]),
            ),
          ),
        ),
      );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final ok = await widget.notifier.createDataset(
      name: _name.text.trim(),
      datasetType: _type,
      version: _version.text.trim(),
      description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() { _loading = false; _error = 'Failed to register dataset.'; });
    }
  }
}
