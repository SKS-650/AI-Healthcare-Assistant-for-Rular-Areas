import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class DoctorVisitCard extends StatelessWidget {
  final bool shouldVisitDoctor;
  final String reason;

  const DoctorVisitCard({
    super.key,
    required this.shouldVisitDoctor,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    final color = shouldVisitDoctor ? DesignTokens.danger : DesignTokens.success;
    final gradColors = shouldVisitDoctor
        ? [const Color(0xFFFF4757), const Color(0xFFFF7B3D)]
        : [const Color(0xFF2ECC8B), const Color(0xFF16A34A)];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                shouldVisitDoctor ? '🩺' : '✅',
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shouldVisitDoctor
                      ? 'Doctor Visit Recommended'
                      : 'Self-Care May Be Sufficient',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
