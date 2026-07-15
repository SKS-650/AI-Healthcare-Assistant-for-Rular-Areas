import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/medical_history_entry.dart';
import '../providers/health_records_provider.dart';

class MedicalHistoryPage extends ConsumerWidget {
  const MedicalHistoryPage({super.key});

  static const _categories = [
    ('all',     'All',       '📋'),
    ('current', 'Current',   '🩺'),
    ('chronic', 'Chronic',   '💊'),
    ('past',    'Past',      '📂'),
    ('surgery', 'Surgery',   '🏥'),
    ('allergy', 'Allergy',   '⚠️'),
    ('family',  'Family',    '👨‍👩‍👧'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(healthRecordsControllerProvider);
    final ctrl  = ref.read(healthRecordsControllerProvider.notifier);
    final items = state.filteredHistory;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Row(children: [
          Text('🩺', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Text('Medical History',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: DesignTokens.textStrong)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, color: DesignTokens.primary),
            tooltip: 'Add entry',
            onPressed: () => _showAddEditSheet(context, ref, null),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final isActive = i == 0
                    ? state.activeHistoryCategory == null
                    : state.activeHistoryCategory == cat.$1;
                return FilterChip(
                  label: Text('${cat.$3} ${cat.$2}'),
                  selected: isActive,
                  onSelected: (_) =>
                      ctrl.setHistoryFilter(i == 0 ? null : cat.$1),
                  selectedColor: DesignTokens.primary.withValues(alpha: 0.15),
                  checkmarkColor: DesignTokens.primary,
                  labelStyle: TextStyle(
                    color: isActive ? DesignTokens.primary : DesignTokens.textMuted,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: isActive
                        ? DesignTokens.primary.withValues(alpha: 0.4)
                        : DesignTokens.border,
                  ),
                  backgroundColor: DesignTokens.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  showCheckmark: false,
                );
              },
            ),
          ),

          // Content
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: DesignTokens.primary))
                : items.isEmpty
                    ? _EmptyHistory(
                        onAdd: () => _showAddEditSheet(context, ref, null))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: items.length,
                        itemBuilder: (ctx, i) => _HistoryCard(
                          entry: items[i],
                          onEdit: () =>
                              _showAddEditSheet(context, ref, items[i]),
                          onDelete: () =>
                              _confirmDelete(context, ref, items[i]),
                        )
                            .animate(delay: (i * 60).ms)
                            .fadeIn(duration: 300.ms)
                            .slideX(begin: 0.08),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditSheet(context, ref, null),
        backgroundColor: DesignTokens.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Entry',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ── Bottom sheet: add / edit ────────────────────────────────────────────

  void _showAddEditSheet(
      BuildContext ctx, WidgetRef ref, MedicalHistoryEntry? existing) {
    showModalBottomSheet<void>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HistoryFormSheet(existing: existing, ref: ref),
    );
  }

  // ── Delete confirmation ─────────────────────────────────────────────────

  void _confirmDelete(
      BuildContext ctx, WidgetRef ref, MedicalHistoryEntry entry) {
    showDialog<void>(
      context: ctx,
      builder: (dctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text(
            'Remove "${entry.diseaseName}" from your medical history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: DesignTokens.danger,
                foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(dctx);
              ref
                  .read(healthRecordsControllerProvider.notifier)
                  .removeHistoryEntry(entry.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─── History card ─────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final MedicalHistoryEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HistoryCard(
      {required this.entry, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(entry.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Icon badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(entry.categoryEmoji,
                        style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.diseaseName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: DesignTokens.textStrong,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(children: [
                        _InfoChip(entry.categoryLabel, color),
                        const SizedBox(width: 6),
                        _StatusChip(entry.status),
                      ]),
                      if (entry.doctorName != null) ...[
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.person_outline_rounded,
                              size: 12, color: DesignTokens.textSubtle),
                          const SizedBox(width: 4),
                          Text(entry.doctorName!,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: DesignTokens.textMuted)),
                        ]),
                      ],
                      if (entry.diagnosisDate != null) ...[
                        const SizedBox(height: 2),
                        Row(children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 11, color: DesignTokens.textSubtle),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('d MMM yyyy')
                                .format(entry.diagnosisDate!),
                            style: const TextStyle(
                                fontSize: 11,
                                color: DesignTokens.textSubtle),
                          ),
                        ]),
                      ],
                    ],
                  ),
                ),
                // Actions
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded,
                      size: 20, color: DesignTokens.textMuted),
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('✏️  Edit')),
                    PopupMenuItem(
                        value: 'delete',
                        child: Text('🗑  Delete',
                            style: TextStyle(color: DesignTokens.danger))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _colorFor(String category) {
    const map = {
      'current':  DesignTokens.primary,
      'chronic':  DesignTokens.orange,
      'past':     DesignTokens.textMuted,
      'surgery':  DesignTokens.blue,
      'allergy':  DesignTokens.danger,
      'family':   DesignTokens.pink,
    };
    return map[category] ?? DesignTokens.primary;
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  const _InfoChip(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color)),
      );
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      'active'   => (DesignTokens.green,   'Active'),
      'resolved' => (DesignTokens.textMuted, 'Resolved'),
      'managed'  => (DesignTokens.blue,    'Managed'),
      _          => (DesignTokens.textMuted, status),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyHistory extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyHistory({required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🩺', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              const Text('No Medical History',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: DesignTokens.textStrong)),
              const SizedBox(height: 8),
              const Text(
                  'Add your diseases, surgeries, allergies and family history here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: DesignTokens.textMuted, height: 1.5)),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Entry'),
                style: FilledButton.styleFrom(
                    backgroundColor: DesignTokens.primary,
                    foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
}

// ─── Add / Edit bottom sheet ──────────────────────────────────────────────────

class _HistoryFormSheet extends ConsumerStatefulWidget {
  final MedicalHistoryEntry? existing;
  final WidgetRef ref;
  const _HistoryFormSheet({required this.existing, required this.ref});

  @override
  ConsumerState<_HistoryFormSheet> createState() => _HistoryFormSheetState();
}

class _HistoryFormSheetState extends ConsumerState<_HistoryFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _doctorCtrl;
  late final TextEditingController _hospitalCtrl;
  late final TextEditingController _notesCtrl;
  late String _category;
  late String _status;
  DateTime? _diagnosisDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl     = TextEditingController(text: e?.diseaseName ?? '');
    _doctorCtrl   = TextEditingController(text: e?.doctorName ?? '');
    _hospitalCtrl = TextEditingController(text: e?.hospitalName ?? '');
    _notesCtrl    = TextEditingController(text: e?.notes ?? '');
    _category     = e?.category ?? 'current';
    _status       = e?.status   ?? 'active';
    _diagnosisDate = e?.diagnosisDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doctorCtrl.dispose();
    _hospitalCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: EdgeInsets.only(bottom: bottom),
      decoration: const BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: DesignTokens.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              widget.existing == null ? '🩺 Add History Entry' : '✏️ Edit Entry',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.textStrong),
            ),
            const SizedBox(height: 20),
            _field(_nameCtrl, 'Condition / Disease *',
                Icons.medical_information_rounded),
            const SizedBox(height: 12),
            _dropdown(
              label: 'Category',
              value: _category,
              items: const [
                ('current', '🩺 Current Condition'),
                ('chronic', '💊 Chronic Condition'),
                ('past',    '📂 Past Condition'),
                ('surgery', '🏥 Surgery'),
                ('allergy', '⚠️ Allergy'),
                ('family',  '👨‍👩‍👧 Family History'),
              ],
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 12),
            _dropdown(
              label: 'Status',
              value: _status,
              items: const [
                ('active',   '🟢 Active'),
                ('managed',  '🔵 Managed'),
                ('resolved', '⚫ Resolved'),
              ],
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 12),
            _dateField(context),
            const SizedBox(height: 12),
            _field(_doctorCtrl, 'Doctor Name', Icons.person_outline_rounded),
            const SizedBox(height: 12),
            _field(_hospitalCtrl, 'Hospital / Clinic',
                Icons.local_hospital_outlined),
            const SizedBox(height: 12),
            _field(_notesCtrl, 'Notes', Icons.notes_rounded, maxLines: 3),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: DesignTokens.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(
                        widget.existing == null ? 'Add Entry' : 'Save Changes',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: DesignTokens.primary),
        filled: true,
        fillColor: DesignTokens.surfaceMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<(String, String)> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: DesignTokens.surfaceMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: items
          .map((i) =>
              DropdownMenuItem(value: i.$1, child: Text(i.$2)))
          .toList(),
    );
  }

  Widget _dateField(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _diagnosisDate ?? DateTime.now(),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(
                  primary: DesignTokens.primary,
                  onPrimary: Colors.white),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _diagnosisDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: DesignTokens.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_rounded,
              size: 18, color: DesignTokens.primary),
          const SizedBox(width: 12),
          Text(
            _diagnosisDate != null
                ? DateFormat('d MMMM yyyy').format(_diagnosisDate!)
                : 'Diagnosis Date (optional)',
            style: TextStyle(
              color: _diagnosisDate != null
                  ? DesignTokens.textStrong
                  : DesignTokens.textMuted,
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);

    final entry = MedicalHistoryEntry(
      id:            widget.existing?.id ?? '',
      userId:        'local',
      diseaseName:   name,
      category:      _category,
      diagnosisDate: _diagnosisDate,
      status:        _status,
      doctorName:    _doctorCtrl.text.trim().isEmpty ? null : _doctorCtrl.text.trim(),
      hospitalName:  _hospitalCtrl.text.trim().isEmpty ? null : _hospitalCtrl.text.trim(),
      notes:         _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt:     widget.existing?.createdAt ?? DateTime.now(),
      updatedAt:     DateTime.now(),
    );

    final ctrl = ref.read(healthRecordsControllerProvider.notifier);
    final ok = widget.existing == null
        ? await ctrl.addHistoryEntry(entry)
        : await ctrl.editHistoryEntry(entry);

    if (mounted) {
      setState(() => _saving = false);
      if (ok) Navigator.of(context).pop();
    }
  }
}
