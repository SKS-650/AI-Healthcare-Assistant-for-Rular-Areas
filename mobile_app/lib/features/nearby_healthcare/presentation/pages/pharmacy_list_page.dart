import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/nearby_healthcare_provider.dart';
import '../widgets/cards/pharmacy_card.dart';
import '../widgets/common/empty_state.dart';
import 'directions_page.dart';

class PharmacyListPage extends ConsumerWidget {
  const PharmacyListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pharmacies = ref.watch(
      nearbyHealthcareControllerProvider.select((state) => state.pharmacies),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Pharmacies')),
      body: pharmacies.isEmpty
          ? const EmptyState(
              title: 'No pharmacies found',
              message: 'Try refreshing your location.',
              icon: Icons.local_pharmacy_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: pharmacies.length,
              itemBuilder: (context, index) {
                final pharmacy = pharmacies[index];
                return PharmacyCard(
                  pharmacy: pharmacy,
                  onRoute: () async {
                    await ref
                        .read(nearbyHealthcareControllerProvider.notifier)
                        .loadRoute(pharmacy.location);
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
