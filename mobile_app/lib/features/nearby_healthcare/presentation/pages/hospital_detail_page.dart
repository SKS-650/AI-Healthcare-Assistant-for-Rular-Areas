import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/hospital.dart';
import '../providers/nearby_healthcare_provider.dart';
import '../widgets/actions/call_button.dart';
import '../widgets/actions/route_button.dart';
import '../widgets/actions/share_button.dart';
import '../widgets/distance/distance_card.dart';
import '../widgets/map/map_preview.dart';
import 'directions_page.dart';

class HospitalDetailPage extends ConsumerWidget {
  final Hospital hospital;

  const HospitalDetailPage({super.key, required this.hospital});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(hospital.name)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          MapPreview(location: hospital.location),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: Color(0xFFE7F5EF),
                      child: Icon(Icons.local_hospital_outlined),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hospital.name,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(hospital.type),
                          const SizedBox(height: 4),
                          Text(hospital.location.address),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DistanceCard(
                  distanceKm: hospital.distanceKm,
                  minutes: hospital.travelTimeMinutes,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.star, size: 18),
                      label: Text('${hospital.rating} rating'),
                    ),
                    Chip(label: Text(hospital.isOpen ? 'Open now' : 'Closed')),
                    if (hospital.hasEmergency)
                      const Chip(label: Text('Emergency available')),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Services',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: hospital.services
                      .map((service) => Chip(label: Text(service)))
                      .toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ShareButton(label: hospital.name),
                    const SizedBox(width: 8),
                    CallButton(phoneNumber: hospital.phoneNumber),
                    const SizedBox(width: 8),
                    RouteButton(
                      onPressed: () async {
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
