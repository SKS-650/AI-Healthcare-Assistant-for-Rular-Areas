import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/nearby_healthcare_provider.dart';
import '../widgets/cards/clinic_card.dart';
import '../widgets/common/empty_state.dart';
import 'directions_page.dart';

class ClinicListPage extends ConsumerWidget {
  const ClinicListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clinics = ref.watch(
      nearbyHealthcareControllerProvider.select((state) => state.clinics),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Clinics')),
      body: clinics.isEmpty
          ? const EmptyState(
              title: 'No clinics found',
              message: 'Try refreshing your location.',
              icon: Icons.medical_services_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: clinics.length,
              itemBuilder: (context, index) {
                final clinic = clinics[index];
                return ClinicCard(
                  clinic: clinic,
                  onRoute: () async {
                    await ref
                        .read(nearbyHealthcareControllerProvider.notifier)
                        .loadRoute(clinic.location);
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
