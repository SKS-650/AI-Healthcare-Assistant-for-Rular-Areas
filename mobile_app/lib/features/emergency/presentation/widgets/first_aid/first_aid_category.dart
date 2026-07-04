import 'package:flutter/material.dart';

class FirstAidCategory extends StatelessWidget {
  final String category;

  const FirstAidCategory({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.medical_services_outlined, size: 18),
      label: Text(category),
    );
  }
}
