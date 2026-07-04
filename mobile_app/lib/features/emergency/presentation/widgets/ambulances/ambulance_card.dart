import 'package:flutter/material.dart';

import '../../../domain/entities/ambulance.dart';

class AmbulanceCard extends StatelessWidget {
  final Ambulance ambulance;

  const AmbulanceCard({super.key, required this.ambulance});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Icon(
          Icons.emergency_share_rounded,
          color: ambulance.available ? Colors.red.shade600 : Colors.grey,
        ),
        title: Text(ambulance.providerName),
        subtitle: Text(
          'Driver: ${ambulance.driverName}\nETA ${ambulance.etaMinutes} min • ${ambulance.distanceKm.toStringAsFixed(1)} km',
        ),
        isThreeLine: true,
        trailing: IconButton(
          tooltip: 'Call ambulance',
          onPressed: ambulance.available ? () {} : null,
          icon: const Icon(Icons.call_rounded),
        ),
      ),
    );
  }
}
