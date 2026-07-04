import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/nearby_healthcare_state.dart';
import '../providers/nearby_healthcare_provider.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/distance/distance_card.dart';
import '../widgets/map/map_placeholder.dart';

class DirectionsPage extends ConsumerWidget {
  const DirectionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nearbyHealthcareControllerProvider);
    final route = state.selectedRoute;

    if (state.status == NearbyHealthcareStatus.routing) {
      return const Scaffold(body: LoadingWidget(message: 'Calculating route'));
    }

    if (route == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Directions')),
        body: const EmptyState(
          title: 'No route selected',
          message: 'Choose a facility and tap route.',
          icon: Icons.alt_route_outlined,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Route to ${route.destination.label}')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          MapPlaceholder(
            title: route.destination.label,
            subtitle: '${route.mode} route from ${route.origin.label}',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DistanceCard(
              distanceKm: route.distanceKm,
              minutes: route.travelTimeMinutes,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Directions',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          ...route.steps.asMap().entries.map((entry) {
            return ListTile(
              leading: CircleAvatar(child: Text('${entry.key + 1}')),
              title: Text(entry.value),
            );
          }),
        ],
      ),
    );
  }
}
