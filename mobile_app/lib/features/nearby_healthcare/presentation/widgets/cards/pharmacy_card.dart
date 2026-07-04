import 'package:flutter/material.dart';

import '../../../domain/entities/pharmacy.dart';
import '../actions/call_button.dart';
import '../actions/route_button.dart';
import '../distance/travel_time_chip.dart';

class PharmacyCard extends StatelessWidget {
  final Pharmacy pharmacy;
  final VoidCallback? onRoute;

  const PharmacyCard({super.key, required this.pharmacy, this.onRoute});

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
                  backgroundColor: Color(0xFFFFF3E0),
                  child: Icon(Icons.local_pharmacy_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pharmacy.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(pharmacy.location.address),
                    ],
                  ),
                ),
                if (pharmacy.hasDelivery)
                  const Tooltip(
                    message: 'Delivery available',
                    child: Icon(Icons.delivery_dining_outlined),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.star, size: 18),
                  label: Text(pharmacy.rating.toStringAsFixed(1)),
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  label: Text('${pharmacy.distanceKm.toStringAsFixed(1)} km'),
                  visualDensity: VisualDensity.compact,
                ),
                TravelTimeChip(minutes: pharmacy.travelTimeMinutes),
                Chip(
                  label: Text(pharmacy.isOpen ? 'Open' : 'Closed'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              pharmacy.availableServices.join(' • '),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CallButton(phoneNumber: pharmacy.phoneNumber),
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
