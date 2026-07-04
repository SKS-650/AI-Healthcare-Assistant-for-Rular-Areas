import 'package:flutter/material.dart';

import '../../domain/entities/lab_report.dart';
import '../../domain/entities/medical_record.dart';
import '../widgets/common/section_title.dart';
import '../widgets/reports/report_attachment.dart';
import '../widgets/reports/report_information.dart';
import '../widgets/reports/report_preview.dart';

class ReportDetailPage extends StatelessWidget {
  final Object item;

  const ReportDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    if (item is LabReport) {
      final report = item as LabReport;
      return Scaffold(
        appBar: AppBar(title: Text(report.testName)),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            ReportPreview(
              title: report.testName,
              summary: report.resultSummary,
            ),
            const SectionTitle(title: 'Report values'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ReportInformation(values: report.values),
              ),
            ),
            const SectionTitle(title: 'Attachments'),
            ...report.attachments.map((file) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ReportAttachment(fileName: file),
              );
            }),
          ],
        ),
      );
    }

    final record = item as MedicalRecord;
    return Scaffold(
      appBar: AppBar(title: Text(record.title)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          ReportPreview(title: record.title, summary: record.summary),
          const SectionTitle(title: 'Record information'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category: ${record.category}'),
                  const SizedBox(height: 8),
                  Text('Doctor: ${record.doctor.name}'),
                  const SizedBox(height: 8),
                  Text('Status: ${record.status}'),
                ],
              ),
            ),
          ),
          const SectionTitle(title: 'Attachments'),
          ...record.attachments.map((file) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ReportAttachment(fileName: file),
            );
          }),
        ],
      ),
    );
  }
}
