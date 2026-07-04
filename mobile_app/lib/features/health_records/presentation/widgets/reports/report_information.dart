import 'package:flutter/material.dart';

class ReportInformation extends StatelessWidget {
  final Map<String, String> values;

  const ReportInformation({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: values.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(child: Text(entry.key)),
              Text(
                entry.value,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
