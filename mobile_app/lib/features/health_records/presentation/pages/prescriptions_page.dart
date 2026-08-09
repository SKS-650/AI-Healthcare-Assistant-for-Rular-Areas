import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/prescription.dart';
import '../providers/health_records_provider.dart';

class PrescriptionsPage extends ConsumerWidget {
  const PrescriptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptions = ref.watch(
      healthRecordsControllerProvider.select((s) => s.prescriptions),
    );

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Row(children: [
          Text('💊', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Text('Prescriptions',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: DesignTokens.textStrong)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file_rounded,
                color: DesignTokens.primary),
            tooltip: 'Upload prescription',
            onPressed: () =>
                _showUploadSheet(context),
          ),
        ],
      ),
      body: prescriptions.isEmpty
          ? _EmptyPrescriptions(onUpload: () => _showUploadSheet(context))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: prescriptions.length,
              itemBuilder: (_, i) => _PrescriptionCard(
                prescription: prescriptions[i],
              )
                  .animate(delay: (i * 70).ms)
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.1),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadSheet(context),
        backgroundColor: DesignTokens.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_rounded),
        label: const Text('Upload',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _showUploadSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _UploadPrescriptionSheet(),
    );
  }
}

// ─── Prescription card ────────────────────────────────────────────────────────

class _PrescriptionCard extends StatelessWidget {
  final Prescription prescription;
  const _PrescriptionCard({required this.prescription});

  @override
  Widget build(BuildContext context) {
    final isExpired = prescription.validUntil != null &&
        prescription.validUntil!.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpired
              ? DesignTokens.textSubtle.withValues(alpha: 0.3)
              : DesignTokens.green.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.green.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: (isExpired ? DesignTokens.textSubtle : DesignTokens.green)
                  .withValues(alpha: 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (isExpired
                          ? DesignTokens.textSubtle
                          : DesignTokens.green)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                    child:
                        Text('💊', style: TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prescription.diagnosis.isEmpty
                          ? 'Prescription'
                          : prescription.diagnosis,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: DesignTokens.textStrong,
                          letterSpacing: -0.2),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${prescription.doctor.name} • ${prescription.doctor.hospital}',
                      style: const TextStyle(
                          fontSize: 12, color: DesignTokens.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _StatusBadge(
                  isExpired ? 'Expired' : 'Active',
                  isExpired ? DesignTokens.textMuted : DesignTokens.green),
            ]),
          ),

          // Dates
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(children: [
              _DateChip(
                Icons.calendar_today_rounded,
                DateFormat('d MMM yyyy').format(prescription.prescribedAt),
                'Prescribed',
              ),
              if (prescription.validUntil != null) ...[
                const SizedBox(width: 12),
                _DateChip(
                  Icons.event_available_rounded,
                  DateFormat('d MMM yyyy').format(prescription.validUntil!),
                  'Valid until',
                ),
              ],
            ]),
          ),

          // Medicines
          if (prescription.medicines.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Text('Medicines',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: DesignTokens.textMuted,
                      letterSpacing: 0.5)),
            ),
            ...prescription.medicines.map((med) => _MedicineTile(med)),
          ],

          // Instructions
          if (prescription.instructions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DesignTokens.yellowContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📝 ',
                        style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Text(
                        prescription.instructions,
                        style: const TextStyle(
                            fontSize: 12,
                            color: DesignTokens.textStrong,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              _ActionBtn(
                Icons.share_rounded,
                'Share',
                DesignTokens.blue,
                () => _shareText(context, prescription),
              ),
              const SizedBox(width: 8),
              _ActionBtn(
                Icons.copy_rounded,
                'Copy',
                DesignTokens.primary,
                () => _copyText(context, prescription),
              ),
              if (prescription.fileUrl != null) ...[
                const SizedBox(width: 8),
                _ActionBtn(
                  Icons.download_rounded,
                  'Download',
                  DesignTokens.green,
                  () {},
                ),
              ],
            ]),
          ),
        ],
      ),
    );
  }

  void _shareText(BuildContext context, Prescription rx) {
    final text = _buildText(rx);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prescription copied to clipboard (share)'),
        backgroundColor: DesignTokens.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Clipboard.setData(ClipboardData(text: text));
  }

  void _copyText(BuildContext context, Prescription rx) {
    Clipboard.setData(ClipboardData(text: _buildText(rx)));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prescription copied to clipboard'),
        backgroundColor: DesignTokens.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _buildText(Prescription rx) {
    final buf = StringBuffer();
    buf.writeln('PRESCRIPTION');
    buf.writeln('Diagnosis: ${rx.diagnosis}');
    buf.writeln('Doctor: ${rx.doctor.name}');
    buf.writeln(
        'Date: ${DateFormat('d MMM yyyy').format(rx.prescribedAt)}');
    buf.writeln('\nMedicines:');
    for (final m in rx.medicines) {
      buf.writeln('  • ${m.name} ${m.dose} — ${m.frequency} for ${m.duration}');
    }
    if (rx.instructions.isNotEmpty) {
      buf.writeln('\nInstructions: ${rx.instructions}');
    }
    return buf.toString();
  }
}

class _MedicineTile extends StatelessWidget {
  final MedicineDosage med;
  const _MedicineTile(this.med);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: DesignTokens.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                      fontSize: 13, color: DesignTokens.textStrong),
                  children: [
                    TextSpan(
                        text: med.name,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(
                        text: ' ${med.dose}',
                        style: const TextStyle(
                            color: DesignTokens.textMuted)),
                    TextSpan(
                        text: ' — ${med.frequency}',
                        style: const TextStyle(
                            color: DesignTokens.textMuted, fontSize: 12)),
                  ],
                ),
              ),
            ),
            Text(
              med.duration,
              style: const TextStyle(
                  fontSize: 11,
                  color: DesignTokens.textSubtle,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: color),
        ),
      );
}

class _DateChip extends StatelessWidget {
  final IconData icon;
  final String date;
  final String label;
  const _DateChip(this.icon, this.date, this.label);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: DesignTokens.textSubtle),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 10, color: DesignTokens.textSubtle)),
              Text(date,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.textStrong)),
            ],
          ),
        ],
      );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ],
          ),
        ),
      );
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyPrescriptions extends StatelessWidget {
  final VoidCallback onUpload;
  const _EmptyPrescriptions({required this.onUpload});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💊', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              const Text('No Prescriptions',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: DesignTokens.textStrong)),
              const SizedBox(height: 8),
              const Text(
                  'Upload your doctor prescriptions and medicine plans here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: DesignTokens.textMuted, height: 1.5)),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onUpload,
                icon: const Icon(Icons.upload_rounded),
                label: const Text('Upload Prescription'),
                style: FilledButton.styleFrom(
                    backgroundColor: DesignTokens.green,
                    foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
}

// ─── Add Prescription sheet ───────────────────────────────────────────────────
// Full form that saves to the backend via the health records controller.

class _UploadPrescriptionSheet extends ConsumerStatefulWidget {
  const _UploadPrescriptionSheet();

  @override
  ConsumerState<_UploadPrescriptionSheet> createState() =>
      _UploadPrescriptionSheetState();
}

class _UploadPrescriptionSheetState
    extends ConsumerState<_UploadPrescriptionSheet> {
  final _diagnosisCtrl  = TextEditingController();
  final _doctorCtrl     = TextEditingController();
  final _hospitalCtrl   = TextEditingController();
  final _instructionCtrl = TextEditingController();

  DateTime _prescribedAt = DateTime.now();
  DateTime? _validUntil;

  // Dynamic medicine list — each entry: {name, dose, frequency, duration}
  final List<Map<String, TextEditingController>> _medicines = [];

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _addMedicine(); // start with one medicine row
  }

  @override
  void dispose() {
    _diagnosisCtrl.dispose();
    _doctorCtrl.dispose();
    _hospitalCtrl.dispose();
    _instructionCtrl.dispose();
    for (final m in _medicines) {
      for (final c in m.values) {
        c.dispose();
      }
    }
    super.dispose();
  }

  void _addMedicine() {
    setState(() => _medicines.add({
          'name':      TextEditingController(),
          'dose':      TextEditingController(),
          'frequency': TextEditingController(),
          'duration':  TextEditingController(),
        }));
  }

  void _removeMedicine(int index) {
    final m = _medicines.removeAt(index);
    for (final c in m.values) {
      c.dispose();
    }
    setState(() {});
  }

  Future<void> _pickDate({required bool isValid}) async {
    final initial = isValid ? (_validUntil ?? _prescribedAt) : _prescribedAt;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: DesignTokens.green, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isValid) {
        _validUntil = picked;
      } else {
        _prescribedAt = picked;
      }
    });
  }

  Future<void> _save() async {
    final diagnosis = _diagnosisCtrl.text.trim();
    final doctorName = _doctorCtrl.text.trim();
    if (diagnosis.isEmpty && doctorName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Enter at least a diagnosis or doctor name.'),
        backgroundColor: DesignTokens.danger,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _saving = true);

    final medicines = _medicines
        .map((m) => MedicineDosage(
              name:      m['name']!.text.trim(),
              dose:      m['dose']!.text.trim(),
              frequency: m['frequency']!.text.trim(),
              duration:  m['duration']!.text.trim(),
            ))
        .where((m) => m.name.isNotEmpty)
        .toList();

    final prescription = Prescription(
      id:           '',
      diagnosis:    diagnosis,
      doctor: Doctor(
        id:            '',
        name:          doctorName.isEmpty ? 'Unknown' : doctorName,
        specialty:     '',
        hospital:      _hospitalCtrl.text.trim(),
        contactNumber: '',
      ),
      prescribedAt:  _prescribedAt,
      validUntil:    _validUntil,
      medicines:     medicines,
      instructions:  _instructionCtrl.text.trim(),
    );

    final ok = await ref
        .read(healthRecordsControllerProvider.notifier)
        .createPrescription(prescription);

    if (mounted) {
      setState(() => _saving = false);
      if (ok) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Prescription saved'),
          backgroundColor: DesignTokens.green,
          behavior: SnackBarBehavior.floating,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to save prescription. Try again.'),
          backgroundColor: DesignTokens.danger,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: DesignTokens.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text('💊 Add Prescription',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.textStrong)),
            const SizedBox(height: 20),

            // Diagnosis
            _field(_diagnosisCtrl, 'Diagnosis / Condition',
                Icons.medical_information_rounded),
            const SizedBox(height: 12),

            // Doctor & Hospital
            Row(children: [
              Expanded(
                  child: _field(_doctorCtrl, 'Doctor Name',
                      Icons.person_outline_rounded)),
              const SizedBox(width: 10),
              Expanded(
                  child: _field(_hospitalCtrl, 'Hospital / Clinic',
                      Icons.local_hospital_outlined)),
            ]),
            const SizedBox(height: 12),

            // Dates
            Row(children: [
              Expanded(child: _dateField(
                icon: Icons.calendar_today_rounded,
                label: 'Prescribed on',
                date: _prescribedAt,
                onTap: () => _pickDate(isValid: false),
              )),
              const SizedBox(width: 10),
              Expanded(child: _dateField(
                icon: Icons.event_available_rounded,
                label: 'Valid until (opt.)',
                date: _validUntil,
                onTap: () => _pickDate(isValid: true),
              )),
            ]),
            const SizedBox(height: 16),

            // Medicines
            Row(children: [
              const Text('Medicines',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: DesignTokens.textStrong)),
              const Spacer(),
              TextButton.icon(
                onPressed: _addMedicine,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                    foregroundColor: DesignTokens.green,
                    padding: EdgeInsets.zero),
              ),
            ]),
            const SizedBox(height: 6),
            ...List.generate(_medicines.length, (i) => _MedicineRow(
              controllers: _medicines[i],
              index: i,
              onRemove: _medicines.length > 1 ? () => _removeMedicine(i) : null,
            )),
            const SizedBox(height: 12),

            // Instructions
            _field(_instructionCtrl, 'Instructions (optional)',
                Icons.notes_rounded, maxLines: 3),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: DesignTokens.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Save Prescription',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {int maxLines = 1}) =>
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18, color: DesignTokens.green),
          filled: true,
          fillColor: DesignTokens.surfaceMuted,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );

  Widget _dateField({
    required IconData icon,
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: DesignTokens.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            Icon(icon, size: 16, color: DesignTokens.green),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11, color: DesignTokens.textSubtle)),
                  Text(
                    date != null
                        ? DateFormat('d MMM yyyy').format(date)
                        : 'Not set',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: date != null
                            ? DesignTokens.textStrong
                            : DesignTokens.textMuted),
                  ),
                ],
              ),
            ),
          ]),
        ),
      );
}

// ─── Single medicine row ──────────────────────────────────────────────────────

class _MedicineRow extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final int index;
  final VoidCallback? onRemove;
  const _MedicineRow(
      {required this.controllers,
      required this.index,
      required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: DesignTokens.green.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DesignTokens.green.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Row(children: [
            Text('Medicine ${index + 1}',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: DesignTokens.green)),
            const Spacer(),
            if (onRemove != null)
              GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.remove_circle_outline_rounded,
                    size: 18, color: DesignTokens.danger),
              ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(flex: 3, child: _mini(controllers['name']!, 'Name *')),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: _mini(controllers['dose']!, 'Dose')),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: _mini(controllers['frequency']!, 'Frequency')),
            const SizedBox(width: 8),
            Expanded(child: _mini(controllers['duration']!, 'Duration')),
          ]),
        ],
      ),
    );
  }

  Widget _mini(TextEditingController ctrl, String hint) => TextField(
        controller: ctrl,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: DesignTokens.textMuted),
          filled: true,
          fillColor: DesignTokens.surface,
          isDense: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
      );
}
