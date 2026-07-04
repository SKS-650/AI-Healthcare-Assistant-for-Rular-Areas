import 'package:flutter/material.dart';

class TimelineConnector extends StatelessWidget {
  final bool isLast;

  const TimelineConnector({super.key, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 8,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        if (!isLast)
          Expanded(child: Container(width: 2, color: Colors.blueGrey.shade100)),
      ],
    );
  }
}
