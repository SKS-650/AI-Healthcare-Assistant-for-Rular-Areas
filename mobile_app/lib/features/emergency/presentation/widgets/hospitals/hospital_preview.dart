import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../domain/entities/hospital.dart';

class HospitalPreview extends StatelessWidget {
  final List<Hospital> hospitals;
  const HospitalPreview({super.key, required this.hospitals});

  @override
  Widget build(BuildContext context) {
    if (hospitals.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: DesignTokens.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: DesignTokens.border),
        ),
        child: const Row(
          children: [
            Text('🏥', style: TextStyle(fontSize: 18)),
            SizedBox(width: 10),
            Text('No nearby hospitals found',
                style: TextStyle(color: DesignTokens.textMuted, fontSize: 13)),
          ],
        ),
      );
    }

    return Column(
      children: hospitals.take(2).map((h) => _PreviewTile(hospital: h)).toList(),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  final Hospital hospital;
  const _PreviewTile({required this.hospital});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DesignTokens.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: DesignTokens.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('🏥', style: TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hospital.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: DesignTokens.textStrong),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(hospital.address,
                    style: const TextStyle(
                        color: DesignTokens.textMuted, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '📍 ${hospital.distanceKm.toStringAsFixed(1)} km',
                style: const TextStyle(
                    color: DesignTokens.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: hospital.emergencyAvailable
                      ? DesignTokens.successContainer
                      : DesignTokens.surfaceMuted,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  hospital.emergencyAvailable ? '✅ Open' : '⛔ Closed',
                  style: TextStyle(
                    color: hospital.emergencyAvailable
                        ? DesignTokens.success
                        : DesignTokens.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
