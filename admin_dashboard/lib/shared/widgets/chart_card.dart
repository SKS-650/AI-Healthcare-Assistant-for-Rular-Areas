import 'package:flutter/material.dart';

class ChartCard extends StatelessWidget {
  const ChartCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(padding: const EdgeInsets.all(16), child: child);
  }
}

