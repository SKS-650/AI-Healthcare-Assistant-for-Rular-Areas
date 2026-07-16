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
    final state    = ref.watch(datasetProvider);
    final notifier = ref.read(datasetProvider.notifier);
    final s        = state.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dataset Management',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w700))
                        .animate()
                        .fadeIn(duration: 400.ms),
                    Text('Manage AI model training datasets and versions',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.lightTextMuted))
                        .animate()
                        .fadeIn(delay: 100.ms),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => _showCreateDialog(context, ref),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Register Dataset'),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary),
              ).animate().fadeIn(delay: 150.ms),
            ],
          ),
          const SizedBox(height: 24),

          // ── Stat cards ─────────────────────────────────────────────────
          LayoutBuilder(builder: (ctx, cst) {
            final cols = cst.maxWidth > 900 ? 4 : 2;
            return GridView.count(
              crossAxisCount: cols,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.6,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                StatCard(
                  title: 'Total Datasets',
                  value: '${s.total}',
                  icon: Icons.dataset_rounded,
                  color: AppColors.primary,
                  animDelay: 0,
                ),
                StatCard(
                  title: 'Active',
                  value: '${s.active}',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                  animDelay: 60,
                ),
                StatCard(
                  title: 'Inactive',
                  value: '${s.inactive}',
                  icon: Icons.pause_circle_rounded,
                  color: AppColors.warning,
                  animDelay: 120,
                ),
                StatCard(
                  title: 'Types Registered',
                  value: '${s.typeCounts.length}',
                  icon: Icons.category_rounded,
                  color: AppColors.accent,
                  animDelay: 180,
                ),
              ],
            );
          }),
          const SizedBox(height: 24),

          // ── Filter row ─────────────────────────────────────────────────
          Row(
            children: [
              _TypeFilter(
                  value: state.typeFilter,
                  onChanged: notifier.setTypeFilter),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => notifier.load(),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Refresh'),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),

          // ── Table ──────────────────────────────────────────────────────
          DataTableCard(
            title: 'Dataset Versions',
            isLoading: state.isLoading,
            totalRows: state.total,
            currentPage: state.page,
            pageSize: state.pageSize,
            onPageChanged: notifier.goToPage,
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Version')),
              DataColumn(label: Text('Records')),
              DataColumn(label: Text('Size')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Uploaded')),
              DataColumn(label: Text('Actions')),
            ],
            rows: state.items.map((d) => DataRow(
              color: WidgetStateProperty.resolveWith((_) => d.isActive
                  ? AppColors.success.withOpacity(0.03)
                  : null),
              cells: [
                DataCell(_NameCell(item: d)),
                DataCell(_TypeBadge(type: d.datasetType)),
                DataCell(Text(d.version,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600))),
                DataCell(Text(
                  d.recordCount != null ? '${d.recordCount}' : '—',
                  style: Theme.of(context).textTheme.bodySmall,
                )),
                DataCell(Text(
                  d.fileSizeKb != null ? '${d.fileSizeKb} KB' : '—',
                  style: Theme.of(context).textTheme.bodySmall,
                )),
                DataCell(StatusBadge(
                  active: d.isActive,
                  activeLabel: 'Active',
                  inactiveLabel: 'Inactive',
                )),
                DataCell(Text(
                  DateFormat('MMM d, yyyy').format(d.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                )),
                DataCell(_ActionButtons(
                  item: d,
                  onActivate: () => _confirmActivate(context, ref, d),
                  onDelete: () => _confirmDelete(context, ref, d),
                )),
              ],
            )).toList(),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _CreateDatasetDialog(
        onCreate: ({
          required name,
          required datasetType,
          required version,
          description,
        }) async {
          final notifier = ref.read(datasetProvider.notifier);
          return await notifier.createDataset(
            name: name,
            datasetType: datasetType,
            version: version,
            description: description,
          );
        },
      ),
    );
  }

  Future<void> _confirmActivate(
      BuildContext context, WidgetRef ref, DatasetItem d) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Activate Dataset'),
        content: Text(
            'Activate "${d.name}" v${d.version}?\n\n'
            'All other ${d.datasetType} datasets will be deactivated.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.success),
            child: const Text('Activate'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final err =
          await ref.read(datasetProvider.notifier).activateDataset(d.id);
      if (err != null && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(err)));
      }
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, DatasetItem d) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Dataset'),
        content: Text('Delete "${d.name}" v${d.version}? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final err =
          await ref.read(datasetProvider.notifier).deleteDataset(d.id);
      if (err != null && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(err)));
      }
    }
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _NameCell extends StatelessWidget {
  final DatasetItem item;
  const _NameCell({required this.item});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(item.name,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis),
          if (item.uploaderName != null)
            Text('by ${item.uploaderName}',
                style: Theme.of(context).textTheme.labelSmall),
        ],
      );
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});
  @override
  Widget build(BuildContext context) {
    final color = switch (type.toLowerCase()) {
      'symptom'  => AppColors.primary,
      'chatbot'  => AppColors.accent,
      'disease'  => AppColors.error,
      'faq'      => AppColors.info,
      _          => AppColors.warning,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20)),
      child: Text(type,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final DatasetItem item;
  final VoidCallback onActivate;
  final VoidCallback onDelete;
  const _ActionButtons(
      {required this.item,
      required this.onActivate,
      required this.onDelete});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!item.isActive)
            Tooltip(
              message: 'Activate',
              child: IconButton(
                icon: const Icon(Icons.check_circle_outline_rounded,
                    size: 18, color: AppColors.success),
                onPressed: onActivate,
              ),
            ),
          Tooltip(
            message: 'Delete',
            child: IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 18, color: AppColors.error),
              onPressed: onDelete,
            ),
          ),
        ],
      );
}

class _TypeFilter extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const _TypeFilter({this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          hint: const Text('All types', style: TextStyle(fontSize: 13)),
          isDense: true,
          items: [
            const DropdownMenuItem(value: null, child: Text('All types')),
            ...kDatasetTypes.map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t, style: const TextStyle(fontSize: 13)),
                )),
          ],
          onChanged: onChanged,
        ),
      );
}

// ── Create dataset dialog ─────────────────────────────────────────────────────

class _CreateDatasetDialog extends StatefulWidget {
  final Future<String?> Function({
    required String name,
    required String datasetType,
    required String version,
    String? description,
  }) onCreate;
  const _CreateDatasetDialog({required this.onCreate});

  @override
  State<_CreateDatasetDialog> createState() => _CreateDatasetDialogState();
}

class _CreateDatasetDialogState extends State<_CreateDatasetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _versionCtrl = TextEditingController(text: '1.0.0');
  final _descCtrl = TextEditingController();
  String _selectedType = kDatasetTypes.first;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _versionCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _error = null; });
    final err = await widget.onCreate(
      name: _nameCtrl.text.trim(),
      datasetType: _selectedType,
      version: _versionCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
    );
    if (!mounted) return;
    if (err != null) {
      setState(() { _saving = false; _error = err; });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Register Dataset Version'),
        content: SizedBox(
          width: 440,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!,
                        style: const TextStyle(color: AppColors.error)),
                  ),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Dataset Name *'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(labelText: 'Dataset Type *'),
                  items: kDatasetTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedType = v!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _versionCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Version *', hintText: '1.0.0'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Description (optional)'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _saving ? null : _submit,
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Register'),
          ),
        ],
      );
}
