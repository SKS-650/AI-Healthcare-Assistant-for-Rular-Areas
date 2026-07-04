import 'package:flutter/material.dart';

class EmergencyStatusCard extends StatelessWidget {
  final String status;
  final String subtitle;

  const EmergencyStatusCard({
    super.key,
    required this.status,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.monitor_heart_outlined),
        title: Text(status),
        subtitle: Text(subtitle),
      ),
    );
  }
}
