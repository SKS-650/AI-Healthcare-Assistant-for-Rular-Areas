import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/nearby_healthcare_provider.dart';
import '../widgets/cards/hospital_card.dart';
import '../widgets/common/empty_state.dart';
import 'directions_page.dart';
import 'hospital_detail_page.dart';

class HospitalListPage extends ConsumerWidget {
  const HospitalListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hospitals = ref.watch(
      nearbyHealthcareControllerProvider.select((state) => state.hospitals),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Hospitals')),
      body: hospitals.isEmpty
          ? const EmptyState(
              title: 'No hospitals found',
              message: 'Try refreshing your location.',
              icon: Icons.local_hospital_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: hospitals.length,
              itemBuilder: (context, index) {
                final hospital = hospitals[index];
                return HospitalCard(
                  hospital: hospital,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HospitalDetailPage(hospital: hospital),
                    ),
                  ),
                  onRoute: () async {
                    await ref
                        .read(nearbyHealthcareControllerProvider.notifier)
                        .loadRoute(hospital.location);
                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DirectionsPage(),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
