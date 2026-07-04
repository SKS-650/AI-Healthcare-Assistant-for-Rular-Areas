import 'package:flutter/material.dart';

import '../../../domain/entities/lab_report.dart';
import '../../widgets/records/record_status_badge.dart';

class ReportCard extends StatelessWidget {
  final LabReport report;
  final VoidCallback? onTap;

  const ReportCard({super.key, required this.report, this.onTap});

  String _format(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.science_outlined),
        title: Text(report.testName),
        subtitle: Text('${report.labName} • ${_format(report.testedAt)}'),
        trailing: RecordStatusBadge(status: report.status),
      ),
    );
  }
}
