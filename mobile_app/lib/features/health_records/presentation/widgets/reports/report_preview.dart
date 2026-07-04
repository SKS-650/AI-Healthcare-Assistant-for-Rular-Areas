import 'package:flutter/material.dart';

class ReportPreview extends StatelessWidget {
  final String title;
  final String summary;

  const ReportPreview({super.key, required this.title, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf_outlined, size: 40),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(summary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
