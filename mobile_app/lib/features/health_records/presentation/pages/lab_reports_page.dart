import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/health_records_provider.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/reports/report_card.dart';
import 'report_detail_page.dart';

class LabReportsPage extends ConsumerWidget {
  const LabReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(
      healthRecordsControllerProvider.select((state) => state.labReports),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Lab Reports')),
      body: reports.isEmpty
          ? const EmptyState(
              title: 'No lab reports',
              message: 'Diagnostic reports and lab results will appear here.',
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return ReportCard(
                  report: report,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ReportDetailPage(item: report),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
