import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../shared/design_system/design_tokens.dart';
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

// ─── Upload sheet (placeholder) ───────────────────────────────────────────────

class _UploadPrescriptionSheet extends StatelessWidget {
  const _UploadPrescriptionSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      decoration: const BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
                color: DesignTokens.border,
                borderRadius: BorderRadius.circular(2)),
          ),
          const Text('💊 Upload Prescription',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.textStrong)),
          const SizedBox(height: 20),
          const _UploadTile(Icons.picture_as_pdf_rounded, 'Upload PDF',
              'Prescription or lab report in PDF format', DesignTokens.danger),
          const SizedBox(height: 10),
          const _UploadTile(Icons.photo_camera_rounded, 'Take a Photo',
              'Capture paper prescription with camera', DesignTokens.blue),
          const SizedBox(height: 10),
          const _UploadTile(Icons.folder_open_rounded, 'Choose from Files',
              'Select image or document from storage', DesignTokens.primary),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: DesignTokens.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  const _UploadTile(this.icon, this.title, this.subtitle, this.color);

  @override
  Widget build(BuildContext context) => Material(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: DesignTokens.textStrong)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12,
                            color: DesignTokens.textMuted)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: color, size: 20),
            ]),
          ),
        ),
      );
}
