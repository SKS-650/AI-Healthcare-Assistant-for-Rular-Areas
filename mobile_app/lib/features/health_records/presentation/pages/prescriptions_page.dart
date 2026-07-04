import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/health_records_provider.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/prescriptions/prescription_card.dart';

class PrescriptionsPage extends ConsumerWidget {
  const PrescriptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptions = ref.watch(
      healthRecordsControllerProvider.select((state) => state.prescriptions),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Prescriptions')),
      body: prescriptions.isEmpty
          ? const EmptyState(
              title: 'No prescriptions',
              message: 'Your active and past prescriptions will appear here.',
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: prescriptions.length,
              itemBuilder: (context, index) {
                return PrescriptionCard(prescription: prescriptions[index]);
              },
            ),
    );
  }
}
