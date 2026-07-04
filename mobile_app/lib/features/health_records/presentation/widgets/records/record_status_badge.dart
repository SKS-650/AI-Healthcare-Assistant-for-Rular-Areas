import 'package:flutter/material.dart';

class RecordStatusBadge extends StatelessWidget {
  final String status;

  const RecordStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isAttention = status == 'Attention' || status == 'Follow-up';
    final color = isAttention ? Colors.orange : Colors.green;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          status,
          style: TextStyle(
            color: color.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
