import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../../../shared/utils/phone_call_service.dart';
import '../../domain/entities/hospital.dart';
import '../providers/emergency_provider.dart';

class NearbyHospitalsPage extends ConsumerWidget {
  const NearbyHospitalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(emergencyControllerProvider);

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: DesignTokens.textStrong, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(children: [
          Text('🏥', style: TextStyle(fontSize: 18)),
          SizedBox(width: 8),
          Text('Nearby Hospitals',
              style: TextStyle(color: DesignTokens.textStrong)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                size: 20, color: DesignTokens.textStrong),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(emergencyControllerProvider.notifier).refreshHospitals(),
          ),
        ],
      ),
      body: state.hospitals.isEmpty
          ? const _EmptyHospitals()
          : RefreshIndicator(
              color: DesignTokens.primary,
              onRefresh: () =>
                  ref.read(emergencyControllerProvider.notifier).refreshHospitals(),
              child: Column(children: [
                // Summary banner
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF0D9488)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(children: [
                    const Text('📍', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const Text('Hospitals near you',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14)),
                        Text(
                          '${state.hospitals.length} facilities found  •  Tap to call or navigate',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11),
                        ),
                      ]),
                    ),
                  ]),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemCount: state.hospitals.length,
                    itemBuilder: (ctx, i) =>
                        _HospitalCard(hospital: state.hospitals[i], isFirst: i == 0),
                  ),
                ),
              ]),
            ),
    );
  }
}

// ─── Hospital card ────────────────────────────────────────────────────────────
class _HospitalCard extends StatelessWidget {
  final Hospital hospital;
  final bool isFirst;

  const _HospitalCard({required this.hospital, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    const blueAccent  = Color(0xFF2563EB);
    const greenAccent = Color(0xFF059669);
    final borderColor = isFirst
        ? blueAccent.withValues(alpha: 0.35)
        : DesignTokens.border;
    final bgColor = isFirst ? const Color(0xFFEFF6FF) : DesignTokens.surface;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: isFirst
            ? [
                BoxShadow(
                  color: blueAccent.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Row(children: [
        // Icon
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isFirst
                ? blueAccent.withValues(alpha: 0.12)
                : DesignTokens.secondaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              hospital.emergencyAvailable ? '🏥' : '🏛️',
              style: const TextStyle(fontSize: 26),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(hospital.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: DesignTokens.textStrong)),
                ),
                if (isFirst)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: blueAccent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Nearest',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700)),
                  ),
              ]),
              const SizedBox(height: 3),
              Row(children: [
                const Icon(Icons.location_on_rounded,
                    size: 11, color: DesignTokens.textMuted),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(hospital.address,
                      style: const TextStyle(
                          color: DesignTokens.textMuted, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
              const SizedBox(height: 5),
              Row(children: [
                // Emergency status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: hospital.emergencyAvailable
                        ? greenAccent.withValues(alpha: 0.12)
                        : DesignTokens.surfaceMuted,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    hospital.emergencyAvailable
                        ? '✅ Emergency Open'
                        : '⛔ Closed',
                    style: TextStyle(
                      color: hospital.emergencyAvailable
                          ? greenAccent
                          : DesignTokens.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${hospital.distanceKm.toStringAsFixed(1)} km',
                  style: const TextStyle(
                      color: DesignTokens.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ]),
            ],
          ),
        ),

        // Action buttons column
        const SizedBox(width: 8),
        Column(children: [
          _HospitalActionBtn(
            icon: Icons.call_rounded,
            label: 'Call',
            color: greenAccent,
            bg: greenAccent.withValues(alpha: 0.1),
            onTap: () {
              HapticFeedback.mediumImpact();
              PhoneCallService.call(context, hospital.phoneNumber,
                  label: hospital.name);
            },
          ),
          const SizedBox(height: 6),
          _HospitalActionBtn(
            icon: Icons.map_rounded,
            label: 'Route',
            color: blueAccent,
            bg: blueAccent.withValues(alpha: 0.1),
            onTap: () {
              HapticFeedback.lightImpact();
              PhoneCallService.openMap(context, hospital.address);
            },
          ),
        ]),
      ]),
    );
  }
}

class _HospitalActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, bg;
  final VoidCallback onTap;

  const _HospitalActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Column(children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyHospitals extends StatelessWidget {
  const _EmptyHospitals();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('🏥', style: TextStyle(fontSize: 50)),
        SizedBox(height: 16),
        Text('No hospitals found nearby',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: DesignTokens.textStrong)),
        SizedBox(height: 6),
        Text(
          'Enable location access to find nearby hospitals.\n'
          'For emergencies call 102 directly.',
          textAlign: TextAlign.center,
          style: TextStyle(color: DesignTokens.textMuted, fontSize: 13, height: 1.5),
        ),
      ]),
    );
  }
}
