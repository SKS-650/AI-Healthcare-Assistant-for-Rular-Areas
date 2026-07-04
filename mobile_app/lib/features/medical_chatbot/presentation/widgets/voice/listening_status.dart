import 'package:flutter/material.dart';

class ListeningStatus extends StatelessWidget {
  final String transcript;

  const ListeningStatus({super.key, required this.transcript});

  @override
  Widget build(BuildContext context) {
    return Text(
      transcript.isEmpty ? 'Voice input is ready.' : transcript,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}
