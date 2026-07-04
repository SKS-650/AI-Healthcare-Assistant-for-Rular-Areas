import 'package:flutter/material.dart';

import '../prediction/probability_chart.dart';

class DiseaseProbabilityChart extends StatelessWidget {
  final Map<String, double> probabilities;
  const DiseaseProbabilityChart({super.key, required this.probabilities});

  @override
  Widget build(BuildContext context) {
    return ProbabilityChart(probabilities: probabilities);
  }
}
