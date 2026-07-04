import 'package:flutter/material.dart';

import '../../../domain/entities/hospital.dart';

class HospitalCard extends StatelessWidget {
  final Hospital hospital;

  const HospitalCard({super.key, required this.hospital});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Icon(
          Icons.local_hospital_rounded,
          color: hospital.emergencyAvailable
              ? Colors.red.shade600
              : Colors.grey,
        ),
        title: Text(hospital.name),
        subtitle: Text(
          '${hospital.address}\n${hospital.distanceKm.toStringAsFixed(1)} km away',
        ),
        isThreeLine: true,
        trailing: IconButton(
          tooltip: 'Call hospital',
          onPressed: () {},
          icon: const Icon(Icons.call_rounded),
        ),
      ),
    );
  }
}
