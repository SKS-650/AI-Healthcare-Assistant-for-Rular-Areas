import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../../../shared/utils/phone_call_service.dart';
import '../../../domain/entities/hospital.dart';

/// Compact 2-item preview used on the EmergencyHomePage.
/// Each row has a live Call + Route button.
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
        child: const Row(children: [
          Text('🏥', style: TextStyle(fontSize: 18)),
          SizedBox(width: 10),
          Text('No nearby hospitals found',
              style: TextStyle(color: DesignTokens.textMuted, fontSize: 13)),
        ]),
      );
    }

    return Column(
      children:
          hospitals.take(2).map((h) => _HospitalTile(hospital: h)).toList(),
    );
  }
}

class _HospitalTile extends StatelessWidget {
  final Hospital hospital;
  const _HospitalTile({required this.hospital});

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
            color: DesignTokens.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
              child: Text('🏥', style: TextStyle(fontSize: 20))),
        ),
        const SizedBox(width: 10),

        // Name + address
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
            const SizedBox(height: 3),
            Text(
              '📍 ${hospital.distanceKm.toStringAsFixed(1)} km  •  '
              '${hospital.emergencyAvailable ? "✅ Emergency open" : "⛔ Closed"}',
              style: TextStyle(
                  color: hospital.emergencyAvailable
                      ? DesignTokens.success
                      : DesignTokens.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700),
            ),
          ]),
        ),

        // Call + map buttons
        const SizedBox(width: 6),
        Column(children: [
          _IconBtn(
            icon: Icons.call_rounded,
            color: DesignTokens.success,
            onTap: () {
              HapticFeedback.mediumImpact();
              PhoneCallService.call(context, hospital.phoneNumber,
                  label: hospital.name);
            },
          ),
          const SizedBox(height: 6),
          _IconBtn(
            icon: Icons.map_rounded,
            color: DesignTokens.secondary,
            onTap: () => PhoneCallService.openMap(context, hospital.address),
          ),
        ]),
      ]),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}
