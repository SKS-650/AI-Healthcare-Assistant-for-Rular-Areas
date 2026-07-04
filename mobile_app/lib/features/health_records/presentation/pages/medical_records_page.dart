import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/health_records_state.dart';
import '../providers/health_records_provider.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/records/medical_record_card.dart';
import 'report_detail_page.dart';

class MedicalRecordsPage extends ConsumerWidget {
  const MedicalRecordsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(healthRecordsControllerProvider);
    if (state.status == HealthRecordsStatus.loading) {
      return const Scaffold(body: LoadingWidget());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Medical Records')),
      body: state.records.isEmpty
          ? const EmptyState(
              title: 'No records',
              message: 'Uploaded and saved medical records will appear here.',
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: state.records.length,
              itemBuilder: (context, index) {
                final record = state.records[index];
                return MedicalRecordCard(
                  record: record,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ReportDetailPage(item: record),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
