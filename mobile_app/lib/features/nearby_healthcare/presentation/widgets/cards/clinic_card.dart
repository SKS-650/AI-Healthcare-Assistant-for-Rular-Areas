import 'package:flutter/material.dart';

import '../../../domain/entities/clinic.dart';
import '../actions/call_button.dart';
import '../actions/route_button.dart';
import '../distance/travel_time_chip.dart';

class ClinicCard extends StatelessWidget {
  final Clinic clinic;
  final VoidCallback? onRoute;

  const ClinicCard({super.key, required this.clinic, this.onRoute});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFEAF0FF),
                  child: Icon(Icons.medical_services_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clinic.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(clinic.specialty),
                    ],
                  ),
                ),
                Icon(
                  clinic.isOpen ? Icons.check_circle : Icons.cancel_outlined,
                  color: clinic.isOpen ? Colors.green : Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(clinic.location.address),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.star, size: 18),
                  label: Text(clinic.rating.toStringAsFixed(1)),
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  label: Text('${clinic.distanceKm.toStringAsFixed(1)} km'),
                  visualDensity: VisualDensity.compact,
                ),
                TravelTimeChip(minutes: clinic.travelTimeMinutes),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CallButton(phoneNumber: clinic.phoneNumber),
                const SizedBox(width: 8),
                RouteButton(onPressed: onRoute ?? () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
