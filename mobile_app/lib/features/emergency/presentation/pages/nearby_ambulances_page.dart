import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../../../shared/utils/phone_call_service.dart';
import '../../domain/entities/ambulance.dart';
import '../providers/emergency_provider.dart';

class NearbyAmbulancesPage extends ConsumerWidget {
  const NearbyAmbulancesPage({super.key});

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
          Text('🚑', style: TextStyle(fontSize: 18)),
          SizedBox(width: 8),
          Text('Nearby Ambulances',
              style: TextStyle(color: DesignTokens.textStrong)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                size: 20, color: DesignTokens.textStrong),
            onPressed: () => ref
                .read(emergencyControllerProvider.notifier)
                .refreshAmbulances(),
          ),
        ],
      ),
      body: Column(children: [
        // ── Tap-to-call 102 banner ─────────────────────────────────────
        GestureDetector(
          onTap: () {
            HapticFeedback.heavyImpact();
            PhoneCallService.call(context, '102', label: 'Ambulance');
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DesignTokens.danger, Color(0xFFB91C1C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.danger.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(children: [
              const Text('🚨', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Emergency? Tap to call 102',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14)),
                  Text('National ambulance helpline — 24/7 free',
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.call_rounded,
                      color: DesignTokens.danger, size: 16),
                  SizedBox(width: 6),
                  Text('102',
                      style: TextStyle(
                          color: DesignTokens.danger,
                          fontWeight: FontWeight.w900,
                          fontSize: 16)),
                ]),
              ),
            ]),
          ),
        ),

        // ── Ambulance list / empty ─────────────────────────────────────
        state.ambulances.isEmpty
            ? const Expanded(child: _EmptyAmbulances())
            : Expanded(
                child: RefreshIndicator(
                  color: DesignTokens.danger,
                  onRefresh: () => ref
                      .read(emergencyControllerProvider.notifier)
                      .refreshAmbulances(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemCount: state.ambulances.length,
                    itemBuilder: (ctx, i) =>
                        _AmbulanceCard(ambulance: state.ambulances[i]),
                  ),
                ),
              ),
      ]),
    );
  }
}

// ─── Ambulance card ───────────────────────────────────────────────────────────
class _AmbulanceCard extends StatelessWidget {
  final Ambulance ambulance;
  const _AmbulanceCard({required this.ambulance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.border),
      ),
      child: Row(children: [
        // Icon
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: DesignTokens.dangerContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(child: Text('🚑', style: TextStyle(fontSize: 26))),
        ),
        const SizedBox(width: 12),

        // Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ambulance.providerName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: DesignTokens.textStrong)),
              const SizedBox(height: 2),
              Text('👨‍💼  ${ambulance.driverName}',
                  style: const TextStyle(
                      color: DesignTokens.textMuted, fontSize: 12)),
              Text('📞  ${ambulance.phoneNumber}',
                  style: const TextStyle(
                      color: DesignTokens.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              Row(children: [
                // Availability badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: ambulance.available
                        ? DesignTokens.successContainer
                        : DesignTokens.surfaceMuted,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ambulance.available ? '🟢 Available' : '🔴 Busy',
                    style: TextStyle(
                      color: ambulance.available
                          ? DesignTokens.success
                          : DesignTokens.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '⏱ ${ambulance.etaMinutes} min  •  ${ambulance.distanceKm.toStringAsFixed(1)} km',
                  style: const TextStyle(
                      color: DesignTokens.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ]),
            ],
          ),
        ),

        // Call button
        const SizedBox(width: 8),
        Material(
          color: ambulance.available ? DesignTokens.danger : DesignTokens.border,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: ambulance.available
                ? () {
                    HapticFeedback.mediumImpact();
                    PhoneCallService.call(context, ambulance.phoneNumber,
                        label: ambulance.providerName);
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              child: Column(children: [
                Icon(Icons.call_rounded,
                    size: 20,
                    color: ambulance.available
                        ? Colors.white
                        : DesignTokens.textMuted),
                const SizedBox(height: 2),
                Text('Call',
                    style: TextStyle(
                        color: ambulance.available
                            ? Colors.white
                            : DesignTokens.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyAmbulances extends StatelessWidget {
  const _EmptyAmbulances();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🚑', style: TextStyle(fontSize: 50)),
        const SizedBox(height: 16),
        const Text('No ambulances found',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: DesignTokens.textStrong)),
        const SizedBox(height: 6),
        const Text('Call 102 directly for an emergency ambulance.',
            style: TextStyle(color: DesignTokens.textMuted, fontSize: 13)),
        const SizedBox(height: 20),
        Material(
          color: DesignTokens.danger,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              HapticFeedback.heavyImpact();
              PhoneCallService.call(context, '102', label: 'Ambulance');
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.call_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Call 102',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}
