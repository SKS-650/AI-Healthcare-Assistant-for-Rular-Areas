import 'package:flutter/material.dart';

import '../../../domain/entities/hospital.dart';
import '../actions/call_button.dart';
import '../actions/route_button.dart';
import '../actions/share_button.dart';
import '../distance/travel_time_chip.dart';

class HospitalCard extends StatelessWidget {
  final Hospital hospital;
  final VoidCallback? onTap;
  final VoidCallback? onRoute;

  const HospitalCard({
    super.key,
    required this.hospital,
    this.onTap,
    this.onRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
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
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(hospital.type),
                        const SizedBox(height: 6),
                        Text(
                          hospital.location.address,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(isOpen: hospital.isOpen),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(Icons.star, size: 18),
                    label: Text(hospital.rating.toStringAsFixed(1)),
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    label: Text('${hospital.distanceKm.toStringAsFixed(1)} km'),
                    visualDensity: VisualDensity.compact,
                  ),
                  TravelTimeChip(minutes: hospital.travelTimeMinutes),
                  if (hospital.hasEmergency)
                    const Chip(
                      avatar: Icon(Icons.emergency_outlined, size: 18),
                      label: Text('Emergency'),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ShareButton(label: hospital.name),
                  const SizedBox(width: 8),
                  CallButton(phoneNumber: hospital.phoneNumber),
                  const SizedBox(width: 8),
                  RouteButton(onPressed: onRoute ?? () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isOpen;

  const _StatusBadge({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: (isOpen ? Colors.green : Colors.red).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          isOpen ? 'Open' : 'Closed',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isOpen ? Colors.green.shade800 : Colors.red.shade800,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
