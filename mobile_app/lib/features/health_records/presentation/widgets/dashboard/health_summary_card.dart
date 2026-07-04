import 'package:flutter/material.dart';

class HealthSummaryCard extends StatelessWidget {
  final int records;
  final int prescriptions;
  final int labReports;

  const HealthSummaryCard({
    super.key,
    required this.records,
    required this.prescriptions,
    required this.labReports,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blue.shade50,
              child: const Icon(Icons.health_and_safety_outlined, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Health records vault',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$records records, $prescriptions prescriptions, $labReports lab reports',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
