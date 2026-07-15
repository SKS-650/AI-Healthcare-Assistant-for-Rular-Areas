import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
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
        foregroundColor: const Color(0xFF1A1035),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: DesignTokens.textStrong, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          children: [
            Text('ðŸ¥', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text('Nearby Hospitals'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
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
              child: Column(
                children: [
                  // Summary gradient banner
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF0D9488)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Text('ðŸ“', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hospitals near you',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14),
                              ),
                              Text(
                                '${state.hospitals.length} facilities found',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: state.hospitals.length,
                      itemBuilder: (context, i) =>
                          _HospitalCard(hospital: state.hospitals[i]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _HospitalCard extends StatelessWidget {
  final Hospital hospital;
  const _HospitalCard({required this.hospital});

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
              color: DesignTokens.secondaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(child: Text('ðŸ¥', style: TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hospital.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: DesignTokens.textStrong,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 12, color: DesignTokens.textMuted),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        hospital.address,
                        style: const TextStyle(
                            color: DesignTokens.textMuted, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: hospital.emergencyAvailable
                            ? DesignTokens.successContainer
                            : DesignTokens.surfaceMuted,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        hospital.emergencyAvailable
                            ? 'âœ… Emergency Open'
                            : 'â›” Closed',
                        style: TextStyle(
                          color: hospital.emergencyAvailable
                              ? DesignTokens.success
                              : DesignTokens.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ðŸ“ ${hospital.distanceKm.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        color: DesignTokens.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Column(
            children: [
              _SmallBtn(
                emoji: 'ðŸ“ž',
                label: 'Call',
                color: DesignTokens.success,
                bg: DesignTokens.successContainer,
              ),
              SizedBox(height: 6),
              _SmallBtn(
                emoji: 'ðŸ—ºï¸',
                label: 'Route',
                color: DesignTokens.secondary,
                bg: DesignTokens.secondaryContainer,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallBtn extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final Color bg;

  const _SmallBtn({
    required this.emoji,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _EmptyHospitals extends StatelessWidget {
  const _EmptyHospitals();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('ðŸ¥', style: TextStyle(fontSize: 50)),
          SizedBox(height: 16),
          Text('No hospitals found nearby',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: DesignTokens.textStrong)),
          SizedBox(height: 6),
          Text('Enable location access to find nearby hospitals',
              style: TextStyle(color: DesignTokens.textMuted, fontSize: 13)),
        ],
      ),
    );
  }
}
