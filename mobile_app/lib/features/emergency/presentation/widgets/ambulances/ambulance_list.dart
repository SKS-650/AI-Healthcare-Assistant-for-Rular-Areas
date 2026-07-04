import 'package:flutter/material.dart';

import '../../../domain/entities/ambulance.dart';
import '../common/empty_state.dart';
import 'ambulance_card.dart';

class AmbulanceList extends StatelessWidget {
  final List<Ambulance> ambulances;

  const AmbulanceList({super.key, required this.ambulances});

  @override
  Widget build(BuildContext context) {
    if (ambulances.isEmpty) {
      return const EmergencyEmptyState(
        icon: Icons.emergency_share_outlined,
        title: 'No ambulances found',
        message: 'Available ambulance data will appear here.',
      );
    }
    return ListView.builder(
      itemCount: ambulances.length,
      itemBuilder: (context, index) =>
          AmbulanceCard(ambulance: ambulances[index]),
    );
  }
}
