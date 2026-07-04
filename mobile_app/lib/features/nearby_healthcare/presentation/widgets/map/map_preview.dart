import 'package:flutter/material.dart';

import '../../../domain/entities/location.dart';
import 'map_placeholder.dart';

class MapPreview extends StatelessWidget {
  final Location? location;
  final VoidCallback? onTap;

  const MapPreview({super.key, this.location, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: MapPlaceholder(
        title: location?.label ?? 'Nearby healthcare map',
        subtitle: location?.address ?? 'Hospitals, clinics, and pharmacies',
      ),
    );
  }
}
