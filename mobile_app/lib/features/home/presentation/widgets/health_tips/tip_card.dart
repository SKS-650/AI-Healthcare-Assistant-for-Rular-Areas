import 'package:flutter/material.dart';

class TipCard extends StatelessWidget {
  const TipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(child: ListTile(title: Text('Health Tip')));
  }
}
