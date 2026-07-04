import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../domain/entities/ambulance.dart';

class AmbulancePreview extends StatelessWidget {
  final List<Ambulance> ambulances;
  const AmbulancePreview({super.key, required this.ambulances});

  @override
  Widget build(BuildContext context) {
    if (ambulances.isEmpty) {
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
            Text('🚑', style: TextStyle(fontSize: 18)),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('No ambulances found',
                      style: TextStyle(
                          color: DesignTokens.textMuted, fontSize: 13)),
                  Text('Call 102 for direct dispatch',
                      style: TextStyle(
                          color: DesignTokens.danger,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: ambulances.take(2).map((a) => _AmbulanceTile(ambulance: a)).toList(),
    );
  }
}

class _AmbulanceTile extends StatelessWidget {
  final Ambulance ambulance;
  const _AmbulanceTile({required this.ambulance});

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
              color: DesignTokens.dangerContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('🚑', style: TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ambulance.providerName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: DesignTokens.textStrong),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('📞 ${ambulance.phoneNumber}',
                    style: const TextStyle(
                        color: DesignTokens.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '⏱️ ${ambulance.etaMinutes} min',
                style: const TextStyle(
                    color: DesignTokens.danger,
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ambulance.available
                      ? DesignTokens.successContainer
                      : DesignTokens.surfaceMuted,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  ambulance.available ? '🟢 Free' : '🔴 Busy',
                  style: TextStyle(
                    color: ambulance.available
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
