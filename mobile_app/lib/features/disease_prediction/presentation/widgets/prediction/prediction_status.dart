import 'package:flutter/material.dart';

class PredictionStatus extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const PredictionStatus({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(message),
    );
  }
}
