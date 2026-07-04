import 'package:flutter/material.dart';

class RouteButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RouteButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      tooltip: 'Route',
      icon: const Icon(Icons.alt_route_outlined),
      onPressed: onPressed,
    );
  }
}
