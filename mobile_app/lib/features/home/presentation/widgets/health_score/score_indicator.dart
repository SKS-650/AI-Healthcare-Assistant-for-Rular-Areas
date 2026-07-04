import 'package:flutter/material.dart';

class ScoreIndicator extends StatelessWidget {
  const ScoreIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator(value: 0.8);
  }
}
