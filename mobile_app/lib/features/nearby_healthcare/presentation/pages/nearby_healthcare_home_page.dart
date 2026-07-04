import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/location.dart';
import '../controllers/nearby_healthcare_state.dart';
import '../providers/nearby_healthcare_provider.dart';
import '../widgets/cards/clinic_card.dart';
import '../widgets/cards/hospital_card.dart';
import '../widgets/cards/pharmacy_card.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/common/section_title.dart';
import '../widgets/map/map_preview.dart';
import 'clinic_list_page.dart';
import 'directions_page.dart';
import 'hospital_detail_page.dart';
import 'hospital_list_page.dart';
import 'map_view_page.dart';
import 'pharmacy_list_page.dart';

class NearbyHealthcareHomePage extends ConsumerWidget {
  const NearbyHealthcareHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nearbyHealthcareControllerProvider);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: DesignTokens.background,
        body: LoadingWidget(),
      );
    }

    if (state.status == NearbyHealthcareStatus.error) {
      return Scaffold(
        backgroundColor: DesignTokens.background,
        appBar: AppBar(
          title: const Text('ðŸ“ Nearby Healthcare'),
          backgroundColor: DesignTokens.background,
          foregroundColor: const Color(0xFF1A1035),
        ),
        body: EmptyState(
          title: 'Could not load nearby care',
          message: state.errorMessage ?? 'Please try again.',
          icon: Icons.error_outline,
        ),
      );
    }

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        foregroundColor: const Color(0xFF1A1035),
        title: const Row(
          children: [
            Text('ðŸ“', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text('Nearby Healthcare'),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: DesignTokens.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: DesignTokens.border),
            ),
            child: IconButton(
              tooltip: 'Map View',
              icon: const Icon(Icons.map_rounded, size: 20),
              onPressed: () => _push(context, const MapViewPage()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: DesignTokens.primary,
        onRefresh: () =>
            ref.read(nearbyHealthcareControllerProvider.notifier).load(),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            _LocationBanner(state: state),
            MapPreview(
              location: state.currentLocation,
              onTap: () => _push(context, const MapViewPage()),
            ),
            _CategoryGrid(
              onHospitals: () => _push(context, const HospitalListPage()),
              onClinics: () => _push(context, const ClinicListPage()),
              onPharmacies: () => _push(context, const PharmacyListPage()),
              onMap: () => _push(context, const MapViewPage()),
            ),
            SectionTitle(
              title: 'Nearest hospitals',
              emoji: 'ðŸ¥',
              onSeeAll: () => _push(context, const HospitalListPage()),
            ),
            ...state.hospitals.take(2).map((hospital) => HospitalCard(
              hospital: hospital,
              onTap: () =>
                  _push(context, HospitalDetailPage(hospital: hospital)),
              onRoute: () => _openDirections(context, ref, hospital.location),
            )),
            SectionTitle(
              title: 'Clinics nearby',
              emoji: 'ðŸ¨',
              onSeeAll: () => _push(context, const ClinicListPage()),
            ),
            ...state.clinics.take(1).map((clinic) => ClinicCard(
              clinic: clinic,
              onRoute: () => _openDirections(context, ref, clinic.location),
            )),
            SectionTitle(
              title: 'Open pharmacies',
              emoji: 'ðŸ’Š',
              onSeeAll: () => _push(context, const PharmacyListPage()),
            ),
            ...state.pharmacies.take(1).map((pharmacy) => PharmacyCard(
              pharmacy: pharmacy,
              onRoute: () => _openDirections(context, ref, pharmacy.location),
            )),
          ],
        ),
      ),
    );
  }

  static Future<void> _openDirections(
    BuildContext context,
    WidgetRef ref,
    Location location,
  ) async {
    await ref
        .read(nearbyHealthcareControllerProvider.notifier)
        .loadRoute(location);
    if (context.mounted) _push(context, const DirectionsPage());
  }

  static void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class _LocationBanner extends StatelessWidget {
  final NearbyHealthcareState state;
  const _LocationBanner({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.primary.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('ðŸ“', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.currentLocation?.label ?? 'Current location',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                Text(
                  state.currentLocation?.address ?? 'Location unavailable',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${state.totalFacilities} found',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final VoidCallback onHospitals;
  final VoidCallback onClinics;
  final VoidCallback onPharmacies;
  final VoidCallback onMap;

  const _CategoryGrid({
    required this.onHospitals,
    required this.onClinics,
    required this.onPharmacies,
    required this.onMap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      ('ðŸ¥', 'Hospitals', DesignTokens.secondaryContainer, onHospitals),
      ('ðŸ¨', 'Clinics', DesignTokens.emeraldContainer, onClinics),
      ('ðŸ’Š', 'Pharmacies', DesignTokens.warningContainer, onPharmacies),
      ('ðŸ—ºï¸', 'Map View', DesignTokens.primaryContainer, onMap),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: items.map((item) {
          return Expanded(
            child: GestureDetector(
              onTap: item.$4,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: item.$3,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: DesignTokens.border,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(item.$1, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 5),
                    Text(
                      item.$2,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: DesignTokens.textStrong,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
