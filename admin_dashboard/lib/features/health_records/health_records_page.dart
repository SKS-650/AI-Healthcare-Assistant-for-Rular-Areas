import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../shared/widgets/data_table_card.dart';
import '../../shared/widgets/stat_card.dart';
import 'health_records_provider.dart';

class HealthRecordsPage extends ConsumerStatefulWidget {
  const HealthRecordsPage({super.key});
  @override
  ConsumerState<HealthRecordsPage> createState() => _HealthRecordsPageState();
}

class _HealthRecordsPageState extends ConsumerState<HealthRecordsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _profileSearchCtrl = TextEditingController();
  final _prescriptionSearchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _profileSearchCtrl.dispose();
    _prescriptionSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(healthRecordsProvider);
    final notifier = ref.read(healthRecordsProvider.notifier);
    final s = state.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Health Records',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700))
                .animate().fadeIn(duration: 400.ms),
            Text('Medical profiles, prescriptions, images and timeline',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.lightTextMuted))
                .animate().fadeIn(delay: 100.ms),
          ])),
          FilledButton.icon(
            onPressed: () { notifier.loadStats(); notifier.loadProfiles(); },
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Refresh'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ]).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 20),
        LayoutBuilder(builder: (context, cst) {
          final cols = cst.maxWidth > 900 ? 5 : cst.maxWidth > 600 ? 3 : 2;
          return GridView.count(
            crossAxisCount: cols, crossAxisSpacing: 12, mainAxisSpacing: 12,
            childAspectRatio: 1.5, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              StatCard(title: 'Medical Profiles', value: '${s.totalMedicalProfiles}',
                  icon: Icons.person_rounded, color: AppColors.primary, animDelay: 0),
              StatCard(title: 'History Entries', value: '${s.totalMedicalHistoryEntries}',
                  icon: Icons.history_rounded, color: AppColors.accent, animDelay: 60),
              StatCard(title: 'Prescriptions', value: '${s.totalPrescriptions}',
                  icon: Icons.receipt_long_rounded, color: AppColors.success, animDelay: 120),
              StatCard(title: 'Medical Images', value: '${s.totalMedicalImages}',
                  icon: Icons.image_rounded, color: AppColors.info, animDelay: 180),
              StatCard(title: 'Timeline Events', value: '${s.totalTimelineEvents}',
                  icon: Icons.timeline_rounded, color: AppColors.warning, animDelay: 240),
            ],
          );
        }),
        const SizedBox(height: 24),
        Card(child: Column(children: [
          TabBar(
            controller: _tab,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Overview'), Tab(text: 'Medical Profiles'),
              Tab(text: 'Prescriptions'), Tab(text: 'Medical Images'),
              Tab(text: 'Timeline'),
            ],
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
          ),
          SizedBox(
            height: 620,
            child: TabBarView(controller: _tab, children: [
              _OverviewTab(stats: s),
              _ProfilesTab(state: state, notifier: notifier, searchCtrl: _profileSearchCtrl),
              _PrescriptionsTab(state: state, notifier: notifier, searchCtrl: _prescriptionSearchCtrl),
              _ImagesTab(state: state, notifier: notifier),
              _TimelineTab(state: state, notifier: notifier),
            ]),
          ),
        ])).animate().fadeIn(delay: 300.ms),
      ]),
    );
  }
}

// ── Overview Tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final HealthRecordsStats stats;
  const _OverviewTab({required this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Module Summary', style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        _infoRow(context, 'Medical Profiles', '${stats.totalMedicalProfiles}',
            Icons.person_rounded, AppColors.primary),
        _infoRow(context, 'Medical History Entries', '${stats.totalMedicalHistoryEntries}',
            Icons.history_rounded, AppColors.accent),
        _infoRow(context, 'Prescriptions Uploaded', '${stats.totalPrescriptions}',
            Icons.receipt_long_rounded, AppColors.success),
        _infoRow(context, 'Medical Images Stored', '${stats.totalMedicalImages}',
            Icons.image_rounded, AppColors.info),
        _infoRow(context, 'Timeline Events', '${stats.totalTimelineEvents}',
            Icons.timeline_rounded, AppColors.warning),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.infoSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: Row(children: [
            const Icon(Icons.shield_rounded, color: AppColors.info, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(
              'Individual health records are encrypted and accessible only to users and '
              'authorized healthcare providers. This dashboard shows aggregated data only.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.info),
            )),
          ]),
        ),
      ]),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value,
      IconData icon, Color color) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label,
              style: Theme.of(context).textTheme.bodyMedium)),
          Text(value, style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700, color: color)),
        ]),
      );
}

// ── Profiles Tab ──────────────────────────────────────────────────────────────

class _ProfilesTab extends StatelessWidget {
  final HealthRecordsState state;
  final HealthRecordsNotifier notifier;
  final TextEditingController searchCtrl;
  const _ProfilesTab({required this.state, required this.notifier, required this.searchCtrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: DataTableCard(
        title: 'Medical Profiles',
        isLoading: state.isLoading,
        totalRows: state.profilesTotal,
        currentPage: state.profilesPage,
        pageSize: state.pageSize,
        onPageChanged: (p) => notifier.loadProfiles(page: p),
        searchBar: SearchField(
          controller: searchCtrl,
          hint: 'Search by patient name...',
          onChanged: (v) { if (v.isEmpty || v.length >= 2) notifier.setProfileSearch(v); },
        ),
        columns: const [
          DataColumn(label: Text('Patient')),
          DataColumn(label: Text('Blood Group')),
          DataColumn(label: Text('Height')),
          DataColumn(label: Text('Weight')),
          DataColumn(label: Text('BMI')),
          DataColumn(label: Text('Allergies')),
          DataColumn(label: Text('Chronic Diseases')),
          DataColumn(label: Text('Actions')),
        ],
        rows: state.profiles.map((p) => DataRow(cells: [
          DataCell(_patientCell(context, p.userName, p.userEmail)),
          DataCell(Text(p.bloodGroup ?? '—', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(p.heightCm != null ? '${p.heightCm!.toStringAsFixed(1)} cm' : '—',
              style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(p.weightKg != null ? '${p.weightKg!.toStringAsFixed(1)} kg' : '—',
              style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(p.bmi != null ? p.bmi!.toStringAsFixed(1) : '—',
              style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text('${p.allergies.length}', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text('${p.chronicDiseases.length}', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(IconButton(
            icon: const Icon(Icons.visibility_rounded, size: 16, color: AppColors.primary),
            onPressed: () => _showProfileDetail(context, p),
          )),
        ])).toList(),
      ),
    );
  }

  Widget _patientCell(BuildContext context, String? name, String? email) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        if (email != null)
          Text(email, style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: AppColors.lightTextMuted)),
      ]);

  void _showProfileDetail(BuildContext context, AdminMedicalProfile p) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Medical Profile — ${p.userName ?? 'Unknown'}',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                _dRow(context, 'Blood Group', p.bloodGroup ?? '—'),
                _dRow(context, 'Height', p.heightCm != null ? '${p.heightCm} cm' : '—'),
                _dRow(context, 'Weight', p.weightKg != null ? '${p.weightKg} kg' : '—'),
                _dRow(context, 'BMI', p.bmi != null ? '${p.bmi!.toStringAsFixed(1)}' : '—'),
                _dRow(context, 'Smoking', p.smokingStatus ?? '—'),
                _dRow(context, 'Alcohol', p.alcoholStatus ?? '—'),
                _dRow(context, 'Activity', p.activityLevel ?? '—'),
                _dRow(context, 'Allergies', p.allergies.join(', ').isEmpty ? 'None' : p.allergies.join(', ')),
                _dRow(context, 'Chronic Diseases', p.chronicDiseases.join(', ').isEmpty ? 'None' : p.chronicDiseases.join(', ')),
                _dRow(context, 'Medications', p.currentMedications.join(', ').isEmpty ? 'None' : p.currentMedications.join(', ')),
                _dRow(context, 'Family History', p.familyHistory.join(', ').isEmpty ? 'None' : p.familyHistory.join(', ')),
                const SizedBox(height: 16),
                Align(alignment: Alignment.centerRight,
                    child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'))),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dRow(BuildContext context, String label, String value) =>
      Padding(padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 140, child: Text(label,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.lightTextMuted, fontWeight: FontWeight.w600))),
            Expanded(child: Text(value, style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w500))),
          ]));
}

// ── Prescriptions Tab ─────────────────────────────────────────────────────────

class _PrescriptionsTab extends StatelessWidget {
  final HealthRecordsState state;
  final HealthRecordsNotifier notifier;
  final TextEditingController searchCtrl;
  const _PrescriptionsTab({required this.state, required this.notifier, required this.searchCtrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: DataTableCard(
        title: 'Prescriptions',
        isLoading: state.isLoading,
        totalRows: state.prescriptionsTotal,
        currentPage: state.prescriptionsPage,
        pageSize: state.pageSize,
        onPageChanged: (p) => notifier.loadPrescriptions(page: p),
        searchBar: SearchField(
          controller: searchCtrl,
          hint: 'Search by doctor/hospital/diagnosis...',
          onChanged: (v) { if (v.isEmpty || v.length >= 2) notifier.setPrescriptionSearch(v); },
        ),
        columns: const [
          DataColumn(label: Text('Patient')),
          DataColumn(label: Text('Doctor')),
          DataColumn(label: Text('Hospital')),
          DataColumn(label: Text('Diagnosis')),
          DataColumn(label: Text('Medicines')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Valid Until')),
          DataColumn(label: Text('Actions')),
        ],
        rows: state.prescriptions.map((p) => DataRow(cells: [
          DataCell(Text(p.userName ?? '—', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
          DataCell(Text(p.doctorName ?? '—', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(p.hospitalName ?? '—', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(SizedBox(width: 140,
              child: Text(p.diagnosis ?? '—', style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis))),
          DataCell(Text('${p.medicines.length} item(s)', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(p.prescriptionDate != null ? _fmtDate(p.prescriptionDate!) : '—',
              style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(p.validUntil != null ? _fmtDate(p.validUntil!) : '—',
              style: Theme.of(context).textTheme.bodySmall)),
          DataCell(IconButton(
            icon: const Icon(Icons.visibility_rounded, size: 16, color: AppColors.primary),
            onPressed: () => _showPrescriptionDetail(context, p),
          )),
        ])).toList(),
      ),
    );
  }

  String _fmtDate(String iso) {
    final dt = DateTime.tryParse(iso)?.toLocal();
    return dt != null ? DateFormat('MMM d, y').format(dt) : iso;
  }

  void _showPrescriptionDetail(BuildContext context, AdminPrescription p) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Prescription Details', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                _dRow(context, 'Patient', p.userName ?? '—'),
                _dRow(context, 'Doctor', p.doctorName ?? '—'),
                _dRow(context, 'Hospital', p.hospitalName ?? '—'),
                _dRow(context, 'Diagnosis', p.diagnosis ?? '—'),
                _dRow(context, 'Date', p.prescriptionDate != null ? _fmtDate(p.prescriptionDate!) : '—'),
                _dRow(context, 'Valid Until', p.validUntil != null ? _fmtDate(p.validUntil!) : '—'),
                _dRow(context, 'Instructions', p.instructions ?? '—'),
                _dRow(context, 'Notes', p.notes ?? '—'),
                const SizedBox(height: 12),
                Text('Medicines (${p.medicines.length})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ...p.medicines.map((m) {
                  final med = m is Map ? m : <String, dynamic>{};
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(children: [
                      const Icon(Icons.medication_rounded, size: 14, color: AppColors.success),
                      const SizedBox(width: 8),
                      Text('${med['name'] ?? 'Unknown'} — ${med['dose'] ?? ''} ${med['frequency'] ?? ''}',
                          style: Theme.of(context).textTheme.bodySmall),
                    ]),
                  );
                }),
                const SizedBox(height: 16),
                Align(alignment: Alignment.centerRight,
                    child: FilledButton(onPressed: () => Navigator.pop(context),
                        child: const Text('Close'))),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dRow(BuildContext context, String label, String value) =>
      Padding(padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 120, child: Text(label,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.lightTextMuted, fontWeight: FontWeight.w600))),
            Expanded(child: Text(value, style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w500))),
          ]));
}

// ── Images Tab ────────────────────────────────────────────────────────────────

class _ImagesTab extends StatelessWidget {
  final HealthRecordsState state;
  final HealthRecordsNotifier notifier;
  const _ImagesTab({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final imageTypes = [null, 'xray', 'mri', 'ct_scan', 'blood_report', 'ecg', 'skin', 'other'];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: DataTableCard(
        title: 'Medical Images',
        isLoading: state.isLoading,
        totalRows: state.imagesTotal,
        currentPage: state.imagesPage,
        pageSize: state.pageSize,
        onPageChanged: (p) => notifier.loadImages(page: p),
        filters: [
          SizedBox(
            height: 40,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: state.imageTypeFilter,
                hint: const Text('All types', style: TextStyle(fontSize: 13)),
                items: imageTypes.map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t == null ? 'All types' : t.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(fontSize: 13)),
                )).toList(),
                onChanged: notifier.setImageTypeFilter,
                isDense: true,
              ),
            ),
          ),
        ],
        columns: const [
          DataColumn(label: Text('Patient')),
          DataColumn(label: Text('Title')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Body Part')),
          DataColumn(label: Text('Doctor')),
          DataColumn(label: Text('Hospital')),
          DataColumn(label: Text('Scan Date')),
        ],
        rows: state.images.map((img) => DataRow(cells: [
          DataCell(Text(img.userName ?? '—', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
          DataCell(SizedBox(width: 120,
              child: Text(img.title, style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis))),
          DataCell(_ImageTypeBadge(type: img.imageType)),
          DataCell(Text(img.bodyPart ?? '—', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(img.doctorName ?? '—', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(img.hospitalName ?? '—', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(
            img.scanDate != null ? _fmtDate(img.scanDate!) : '—',
            style: Theme.of(context).textTheme.bodySmall,
          )),
        ])).toList(),
      ),
    );
  }

  String _fmtDate(String iso) {
    final dt = DateTime.tryParse(iso)?.toLocal();
    return dt != null ? DateFormat('MMM d, y').format(dt) : iso;
  }
}

class _ImageTypeBadge extends StatelessWidget {
  final String type;
  const _ImageTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final color = switch (type.toLowerCase()) {
      'xray' => AppColors.info,
      'mri' => AppColors.accent,
      'ct_scan' => AppColors.primary,
      'blood_report' => AppColors.error,
      'ecg' => AppColors.warning,
      'skin' => AppColors.success,
      _ => AppColors.lightTextMuted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(type.replaceAll('_', ' ').toUpperCase(),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ── Timeline Tab ──────────────────────────────────────────────────────────────

class _TimelineTab extends StatelessWidget {
  final HealthRecordsState state;
  final HealthRecordsNotifier notifier;
  const _TimelineTab({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: DataTableCard(
        title: 'Medical Timeline Events',
        isLoading: state.isLoading,
        totalRows: state.timelineTotal,
        currentPage: state.timelinePage,
        pageSize: state.pageSize,
        onPageChanged: (p) => notifier.loadTimeline(page: p),
        columns: const [
          DataColumn(label: Text('Patient')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Title')),
          DataColumn(label: Text('Description')),
          DataColumn(label: Text('Event Date')),
        ],
        rows: state.timeline.map((e) => DataRow(cells: [
          DataCell(Text(e.userName ?? '—', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
          DataCell(_EventTypeBadge(type: e.eventType)),
          DataCell(SizedBox(width: 160,
              child: Text('${e.iconEmoji ?? ''} ${e.title}',
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis))),
          DataCell(SizedBox(width: 200,
              child: Text(e.description ?? '—',
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis))),
          DataCell(Text(_fmtDate(e.eventDate), style: Theme.of(context).textTheme.bodySmall)),
        ])).toList(),
      ),
    );
  }

  String _fmtDate(String iso) {
    final dt = DateTime.tryParse(iso)?.toLocal();
    return dt != null ? DateFormat('MMM d, y').format(dt) : iso;
  }
}

class _EventTypeBadge extends StatelessWidget {
  final String type;
  const _EventTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final color = switch (type.toLowerCase()) {
      'prescription' => AppColors.success,
      'medical_image' => AppColors.info,
      'medical_history' => AppColors.accent,
      'symptom_assessment' => AppColors.warning,
      'emergency_assessment' => AppColors.error,
      _ => AppColors.lightTextMuted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(type.replaceAll('_', ' ').toUpperCase(),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
