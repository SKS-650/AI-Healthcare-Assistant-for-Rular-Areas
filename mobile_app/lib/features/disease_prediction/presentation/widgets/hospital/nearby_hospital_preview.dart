import 'package:flutter/material.dart';

import '../../../domain/entities/hospital.dart';
import 'hospital_card.dart';

class NearbyHospitalPreview extends StatelessWidget {
  final List<Hospital> hospitals;
  const NearbyHospitalPreview({super.key, required this.hospitals});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: hospitals.take(3).map((h) => HospitalCard(hospital: h)).toList(),
      ),
    );
  }
}
