import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
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
        foregroundColor: const Color(0xFF1A1035),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: DesignTokens.textStrong, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          children: [
            Text('ðŸš‘', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text('Nearby Ambulances'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: () =>
                ref.read(emergencyControllerProvider.notifier).refreshAmbulances(),
          ),
        ],
      ),
      body: Column(
        children: [
          // National helpline banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DesignTokens.danger, Color(0xFFB91C1C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Text('ðŸš¨', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Emergency? Call 102 directly',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13)),
                      Text('National ambulance helpline â€” 24/7 free',
                          style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('ðŸ“ž 102',
                      style: TextStyle(
                          color: DesignTokens.danger,
                          fontWeight: FontWeight.w900,
                          fontSize: 15)),
                ),
              ],
            ),
          ),

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
                      itemBuilder: (context, i) =>
                          _AmbulanceCard(ambulance: state.ambulances[i]),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

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
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: DesignTokens.dangerContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
                child: Text('ðŸš‘', style: TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ambulance.providerName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: DesignTokens.textStrong),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Text('ðŸ‘¨â€ðŸ’¼', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    Text(ambulance.driverName,
                        style: const TextStyle(
                            color: DesignTokens.textMuted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Text('ðŸ“ž', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    Text(ambulance.phoneNumber,
                        style: const TextStyle(
                            color: DesignTokens.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
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
                        ambulance.available ? 'ðŸŸ¢ Available' : 'ðŸ”´ Busy',
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
                      'â±ï¸ ${ambulance.etaMinutes} min  â€¢  ðŸ“ ${ambulance.distanceKm.toStringAsFixed(1)} km',
                      style: const TextStyle(
                          color: DesignTokens.secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: DesignTokens.danger,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text('ðŸ“ž', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 2),
                  Text('Call',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAmbulances extends StatelessWidget {
  const _EmptyAmbulances();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('ðŸš‘', style: TextStyle(fontSize: 50)),
          SizedBox(height: 16),
          Text('No ambulances found',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: DesignTokens.textStrong)),
          SizedBox(height: 6),
          Text('Call 102 directly for emergency ambulance',
              style: TextStyle(color: DesignTokens.textMuted, fontSize: 13)),
          SizedBox(height: 16),
          Text('ðŸ“ž 102',
              style: TextStyle(
                  color: DesignTokens.danger,
                  fontSize: 28,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
