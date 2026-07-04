import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final Widget child;

  const DashboardCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(margin: const EdgeInsets.all(8), child: Padding(padding: const EdgeInsets.all(12), child: child));
  }
}
