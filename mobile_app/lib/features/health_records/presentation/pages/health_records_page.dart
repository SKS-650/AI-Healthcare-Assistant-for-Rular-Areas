import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class HealthRecordsPage extends StatefulWidget {
  const HealthRecordsPage({super.key});

  @override
  State<HealthRecordsPage> createState() => _HealthRecordsPageState();
}

class _HealthRecordsPageState extends State<HealthRecordsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() => _selectedTab = _tabCtrl.index);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          children: [
            Text('📋', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              'Health Records',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textStrong,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: DesignTokens.primary),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          labelColor: DesignTokens.primary,
          unselectedLabelColor: DesignTokens.textMuted,
          indicatorColor: DesignTokens.primary,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 12),
          tabs: const [
            Tab(text: '📄 Reports'),
            Tab(text: '💉 Vaccinations'),
            Tab(text: '💊 Medicines'),
            Tab(text: '📅 Appointments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _ReportsList(records: _medicalReports),
          _VaccinationList(records: _vaccinations),
          _MedicinesList(records: _medicines),
          _AppointmentsList(records: _appointments),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: DesignTokens.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Record',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _ReportsList extends StatelessWidget {
  final List<_MedicalRecord> records;
  const _ReportsList({required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const _EmptyRecords(
          emoji: '📄', title: 'No Medical Reports', message: 'Upload your reports to keep them safe');
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _RecordCard(record: records[i]),
    );
  }
}

class _VaccinationList extends StatelessWidget {
  final List<_MedicalRecord> records;
  const _VaccinationList({required this.records});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _RecordCard(record: records[i]),
    );
  }
}

class _MedicinesList extends StatelessWidget {
  final List<_MedicalRecord> records;
  const _MedicinesList({required this.records});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _RecordCard(record: records[i]),
    );
  }
}

class _AppointmentsList extends StatelessWidget {
  final List<_MedicalRecord> records;
  const _AppointmentsList({required this.records});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _RecordCard(record: records[i]),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final _MedicalRecord record;
  const _RecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: record.color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: record.color.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: record.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                      child: Text(record.emoji,
                          style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: DesignTokens.textStrong,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        record.subtitle,
                        style: const TextStyle(
                          color: DesignTokens.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 11, color: DesignTokens.textSubtle),
                          const SizedBox(width: 4),
                          Text(record.date,
                              style: const TextStyle(
                                  color: DesignTokens.textSubtle,
                                  fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: record.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        record.tag,
                        style: TextStyle(
                          color: record.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Icon(Icons.chevron_right_rounded,
                        size: 18, color: DesignTokens.textSubtle),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyRecords extends StatelessWidget {
  final String emoji, title, message;
  const _EmptyRecords(
      {required this.emoji, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textStrong,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                  color: DesignTokens.textMuted, fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Record'),
              style: FilledButton.styleFrom(
                backgroundColor: DesignTokens.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(160, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicalRecord {
  final String emoji, title, subtitle, date, tag;
  final Color color;
  const _MedicalRecord({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.tag,
    required this.color,
  });
}

const _medicalReports = [
  _MedicalRecord(
    emoji: '🩸',
    title: 'Blood Test Report',
    subtitle: 'Hemoglobin, WBC, RBC, Platelets',
    date: 'Jan 15, 2025',
    tag: 'Normal',
    color: Color(0xFF2ECC8B),
  ),
  _MedicalRecord(
    emoji: '📡',
    title: 'X-Ray Chest',
    subtitle: 'PA View — No abnormality detected',
    date: 'Dec 20, 2024',
    tag: 'Clear',
    color: Color(0xFF4F94FF),
  ),
  _MedicalRecord(
    emoji: '💊',
    title: 'Prescription',
    subtitle: 'Dr. Sharma — Fever treatment',
    date: 'Feb 3, 2025',
    tag: 'Active',
    color: Color(0xFF926EFF),
  ),
];

const _vaccinations = [
  _MedicalRecord(
    emoji: '💉',
    title: 'COVID-19 Vaccine',
    subtitle: 'Covishield — 2nd Dose',
    date: 'Sep 10, 2022',
    tag: 'Complete',
    color: Color(0xFF2ECC8B),
  ),
  _MedicalRecord(
    emoji: '💉',
    title: 'Influenza Vaccine',
    subtitle: 'Annual Flu Shot 2024',
    date: 'Oct 5, 2024',
    tag: 'Done',
    color: Color(0xFF4F94FF),
  ),
  _MedicalRecord(
    emoji: '💉',
    title: 'Hepatitis B',
    subtitle: 'Booster Dose',
    date: 'Mar 22, 2023',
    tag: 'Complete',
    color: Color(0xFFFF7B3D),
  ),
];

const _medicines = [
  _MedicalRecord(
    emoji: '💊',
    title: 'Metformin 500mg',
    subtitle: 'Diabetes control — Twice daily',
    date: 'Ongoing',
    tag: 'Active',
    color: Color(0xFF4F94FF),
  ),
  _MedicalRecord(
    emoji: '💊',
    title: 'Amlodipine 5mg',
    subtitle: 'Blood pressure — Once daily',
    date: 'Ongoing',
    tag: 'Active',
    color: Color(0xFFFF5E9E),
  ),
  _MedicalRecord(
    emoji: '💊',
    title: 'Vitamin D3 60K',
    subtitle: 'Weekly supplement',
    date: 'Until Apr 2025',
    tag: 'Ongoing',
    color: Color(0xFFFFB829),
  ),
];

const _appointments = [
  _MedicalRecord(
    emoji: '👨‍⚕️',
    title: 'Dr. Sharma Checkup',
    subtitle: 'General checkup — Primary Health Center',
    date: 'Mar 25, 2025',
    tag: 'Upcoming',
    color: Color(0xFF4F94FF),
  ),
  _MedicalRecord(
    emoji: '🦷',
    title: 'Dental Checkup',
    subtitle: 'Community Dental Clinic',
    date: 'Apr 12, 2025',
    tag: 'Scheduled',
    color: Color(0xFF18C8C8),
  ),
  _MedicalRecord(
    emoji: '🩺',
    title: 'Blood Pressure Review',
    subtitle: 'Follow-up — Dr. Gupta',
    date: 'Feb 18, 2025 ✓',
    tag: 'Completed',
    color: Color(0xFF2ECC8B),
  ),
];
