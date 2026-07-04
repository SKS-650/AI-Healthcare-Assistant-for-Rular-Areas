import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/location.dart';
import '../controllers/nearby_healthcare_state.dart';
import '../providers/nearby_healthcare_provider.dart';
import '../widgets/cards/clinic_card.dart';
import '../widgets/cards/hospital_card.dart';
import '../widgets/cards/pharmacy_card.dart';
import '../widgets/map/map_placeholder.dart';
import 'directions_page.dart';

class MapViewPage extends ConsumerWidget {
  const MapViewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nearbyHealthcareControllerProvider);
    final controller = ref.read(nearbyHealthcareControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Healthcare Map')),
      body: Column(
        children: [
          const MapPlaceholder(
            title: 'Kathmandu healthcare map',
            subtitle: 'Ready for Google Maps markers and Places results.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<HealthcareFacilityType>(
              segments: const [
                ButtonSegment(
                  value: HealthcareFacilityType.hospitals,
                  icon: Icon(Icons.local_hospital_outlined),
                  label: Text('Hospitals'),
                ),
                ButtonSegment(
                  value: HealthcareFacilityType.clinics,
                  icon: Icon(Icons.medical_services_outlined),
                  label: Text('Clinics'),
                ),
                ButtonSegment(
                  value: HealthcareFacilityType.pharmacies,
                  icon: Icon(Icons.local_pharmacy_outlined),
                  label: Text('Pharmacies'),
                ),
              ],
              selected: {state.selectedType},
              onSelectionChanged: (selection) {
                controller.selectType(selection.first);
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _FacilityList(state: state, ref: ref),
          ),
        ],
      ),
    );
  }
}

class _FacilityList extends StatelessWidget {
  final NearbyHealthcareState state;
  final WidgetRef ref;

  const _FacilityList({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    Future<void> openRoute(Location location) async {
      await ref
          .read(nearbyHealthcareControllerProvider.notifier)
          .loadRoute(location);
      if (context.mounted) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const DirectionsPage()));
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: switch (state.selectedType) {
        HealthcareFacilityType.hospitals =>
          state.hospitals
              .map(
                (hospital) => HospitalCard(
                  hospital: hospital,
                  onRoute: () => openRoute(hospital.location),
                ),
              )
              .toList(),
        HealthcareFacilityType.clinics =>
          state.clinics
              .map(
                (clinic) => ClinicCard(
                  clinic: clinic,
                  onRoute: () => openRoute(clinic.location),
                ),
              )
              .toList(),
        HealthcareFacilityType.pharmacies =>
          state.pharmacies
              .map(
                (pharmacy) => PharmacyCard(
                  pharmacy: pharmacy,
                  onRoute: () => openRoute(pharmacy.location),
                ),
              )
              .toList(),
      },
    );
  }
}
