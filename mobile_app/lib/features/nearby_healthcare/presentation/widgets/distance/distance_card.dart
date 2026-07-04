import 'package:flutter/material.dart';

class DistanceCard extends StatelessWidget {
  final double distanceKm;
  final int minutes;

  const DistanceCard({
    super.key,
    required this.distanceKm,
    required this.minutes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.teal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.route_outlined, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${distanceKm.toStringAsFixed(1)} km away',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Text('$minutes min'),
        ],
      ),
    );
  }
}
