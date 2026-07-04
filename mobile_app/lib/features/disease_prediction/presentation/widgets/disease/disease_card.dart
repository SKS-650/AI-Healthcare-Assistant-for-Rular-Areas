import 'package:flutter/material.dart';

import '../../../domain/entities/disease.dart';
import '../common/dashboard_card.dart';

class DiseaseCard extends StatelessWidget {
  final Disease disease;
  final VoidCallback? onTap;

  const DiseaseCard({super.key, required this.disease, this.onTap});

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      onTap: onTap,
      child: Row(
        children: [
          const Icon(Icons.health_and_safety_outlined, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  disease.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  disease.shortDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
