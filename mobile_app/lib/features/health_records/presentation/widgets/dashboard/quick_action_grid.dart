import 'package:flutter/material.dart';

class HealthRecordsQuickActionGrid extends StatelessWidget {
  final VoidCallback onTimeline;
  final VoidCallback onRecords;
  final VoidCallback onPrescriptions;
  final VoidCallback onLabReports;
  final VoidCallback onUpload;
  final VoidCallback onSearch;

  const HealthRecordsQuickActionGrid({
    super.key,
    required this.onTimeline,
    required this.onRecords,
    required this.onPrescriptions,
    required this.onLabReports,
    required this.onUpload,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.timeline_outlined, 'Timeline', onTimeline),
      (Icons.folder_copy_outlined, 'Records', onRecords),
      (Icons.medication_outlined, 'Prescriptions', onPrescriptions),
      (Icons.science_outlined, 'Lab Reports', onLabReports),
      (Icons.upload_file_outlined, 'Upload', onUpload),
      (Icons.search, 'Search', onSearch),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.08,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return Card(
          child: InkWell(
            onTap: action.$3,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(action.$1, color: Colors.blue.shade700),
                const SizedBox(height: 8),
                Text(
                  action.$2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
