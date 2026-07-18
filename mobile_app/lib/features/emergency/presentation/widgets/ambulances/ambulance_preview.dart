import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../../../shared/utils/phone_call_service.dart';
import '../../../domain/entities/ambulance.dart';

/// Compact 2-item ambulance preview used on EmergencyHomePage.
/// Each row has a live Call button; falls back to 102 when list is empty.
class AmbulancePreview extends StatelessWidget {
  final List<Ambulance> ambulances;
  const AmbulancePreview({super.key, required this.ambulances});

  @override
  Widget build(BuildContext context) {
    if (ambulances.isEmpty) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.heavyImpact();
          PhoneCallService.call(context, '102', label: 'Ambulance');
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: DesignTokens.dangerContainer,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: DesignTokens.danger.withValues(alpha: 0.3)),
          ),
          child: const Row(children: [
            Text('🚑', style: TextStyle(fontSize: 18)),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('No ambulances found nearby',
                    style: TextStyle(
                        color: DesignTokens.danger,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                Text('Tap to call 102 directly',
                    style: TextStyle(
                        color: DesignTokens.danger, fontSize: 11)),
              ]),
            ),
            Icon(Icons.call_rounded, color: DesignTokens.danger, size: 20),
          ]),
        ),
      );
    }

    return Column(
      children: ambulances
          .take(2)
          .map((a) => _AmbulanceTile(ambulance: a))
          .toList(),
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
      child: Row(children: [
        // Icon
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: DesignTokens.dangerContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
              child: Text('🚑', style: TextStyle(fontSize: 20))),
        ),
        const SizedBox(width: 10),

        // Details
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
            const SizedBox(height: 3),
            Row(children: [
              Text(
                '⏱️ ${ambulance.etaMinutes} min  •  '
                '${ambulance.distanceKm.toStringAsFixed(1)} km',
                style: const TextStyle(
                    color: DesignTokens.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
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
            ]),
          ]),
        ),

        // Call button
        const SizedBox(width: 6),
        Material(
          color: ambulance.available
              ? DesignTokens.danger
              : DesignTokens.border,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: ambulance.available
                ? () {
                    HapticFeedback.mediumImpact();
                    PhoneCallService.call(context, ambulance.phoneNumber,
                        label: ambulance.providerName);
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(Icons.call_rounded,
                  size: 18,
                  color: ambulance.available
                      ? Colors.white
                      : DesignTokens.textMuted),
            ),
          ),
        ),
      ]),
    );
  }
}
