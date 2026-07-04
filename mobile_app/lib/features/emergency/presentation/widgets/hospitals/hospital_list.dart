import 'package:flutter/material.dart';

import '../../../domain/entities/hospital.dart';
import '../common/empty_state.dart';
import 'hospital_card.dart';

class HospitalList extends StatelessWidget {
  final List<Hospital> hospitals;

  const HospitalList({super.key, required this.hospitals});

  @override
  Widget build(BuildContext context) {
    if (hospitals.isEmpty) {
      return const EmergencyEmptyState(
        icon: Icons.local_hospital_outlined,
        title: 'No hospitals found',
        message: 'Nearby hospital data will appear here.',
      );
    }
    return ListView.builder(
      itemCount: hospitals.length,
      itemBuilder: (context, index) => HospitalCard(hospital: hospitals[index]),
    );
  }
}
