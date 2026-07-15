import 'package:flutter/material.dart';

class HealthCategory {
  final String id;
  final String name;
  final String slug;
  final String? icon;
  final String? description;
  final String? colorHex;
  final int sortOrder;
  final bool isActive;

  const HealthCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.description,
    this.colorHex,
    required this.sortOrder,
    required this.isActive,
  });

  Color get color {
    if (colorHex == null) return const Color(0xFF926EFF);
    final hex = colorHex!.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is HealthCategory && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
