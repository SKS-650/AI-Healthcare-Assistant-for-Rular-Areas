import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../controllers/health_records_state.dart';
import '../providers/health_records_provider.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/common/section_title.dart';
import '../widgets/dashboard/health_summary_card.dart';
import '../widgets/dashboard/quick_action_grid.dart';
import '../widgets/records/medical_record_card.dart';
import 'lab_reports_page.dart';
import 'medical_records_page.dart';
import 'medical_timeline_page.dart';
import 'prescriptions_page.dart';
import 'report_detail_page.dart';
import 'search_records_page.dart';
import 'upload_report_page.dart';

class HealthRecordsHomePage extends ConsumerWidget {
  const HealthRecordsHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(healthRecordsControllerProvider);

    if (state.status == HealthRecordsStatus.loading ||
        state.status == HealthRecordsStatus.initial) {
      return const Scaffold(
        backgroundColor: DesignTokens.background,
        body: LoadingWidget(),
      );
    }

    if (state.status == HealthRecordsStatus.failure) {
      return Scaffold(
        backgroundColor: DesignTokens.background,
        appBar: AppBar(
          title: const Text('ðŸ“‹ Health Records'),
          backgroundColor: DesignTokens.background,
          foregroundColor: const Color(0xFF1A1035),
        ),
        body: EmptyState(
          title: 'Unable to load records',
          message: state.errorMessage ?? 'Please try again.',
          icon: Icons.error_outline,
        ),
      );
    }

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        foregroundColor: const Color(0xFF1A1035),
        title: const Row(
          children: [
            Text('ðŸ“‹', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text('Health Records'),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: DesignTokens.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: DesignTokens.border),
            ),
            child: IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.search_rounded, size: 20),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchRecordsPage()),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: DesignTokens.primary,
        onRefresh: () =>
            ref.read(healthRecordsControllerProvider.notifier).loadRecords(),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            // Summary header
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF97316), Color(0xFFEF4444)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF97316).withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Health Records',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _StatPill(
                              value: '${state.records.length}',
                              label: 'Records',
                            ),
                            const SizedBox(width: 8),
                            _StatPill(
                              value: '${state.labReports.length}',
                              label: 'Reports',
                            ),
                            const SizedBox(width: 8),
                            _StatPill(
                              value: '${state.prescriptions.length}',
                              label: 'Rx',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Text('ðŸ“Š', style: TextStyle(fontSize: 48)),
                ],
              ),
            ),

            HealthSummaryCard(
              records: state.records.length,
              prescriptions: state.prescriptions.length,
              labReports: state.labReports.length,
            ),

            // Quick actions grid
            const SectionTitle(title: 'âš¡ Quick Actions'),
            HealthRecordsQuickActionGrid(
              onTimeline: () => _push(context, const MedicalTimelinePage()),
              onRecords: () => _push(context, const MedicalRecordsPage()),
              onPrescriptions: () => _push(context, const PrescriptionsPage()),
              onLabReports: () => _push(context, const LabReportsPage()),
              onUpload: () => _push(context, const UploadReportPage()),
              onSearch: () => _push(context, const SearchRecordsPage()),
            ),

            // Recent records
            SectionTitle(
              title: 'ðŸ—‚ï¸ Recent Records',
              onSeeAll: () => _push(context, const MedicalRecordsPage()),
            ),
            ...state.records.take(3).map(
              (record) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: MedicalRecordCard(
                  record: record,
                  onTap: () => _push(context, ReportDetailPage(item: record)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class _StatPill extends StatelessWidget {
  final String value;
  final String label;

  const _StatPill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$value ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            TextSpan(
              text: label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
