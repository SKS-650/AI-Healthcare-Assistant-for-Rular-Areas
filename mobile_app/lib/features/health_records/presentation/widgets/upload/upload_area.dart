import 'package:flutter/material.dart';

class UploadArea extends StatelessWidget {
  final String label;

  const UploadArea({super.key, this.label = 'Tap to choose a report file'});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueGrey.shade100),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 42,
              color: Colors.blue.shade700,
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Dummy upload creates a local sample record.'),
          ],
        ),
      ),
    );
  }
}
