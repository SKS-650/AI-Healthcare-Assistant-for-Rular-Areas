import 'package:flutter/material.dart';

import '../../domain/entities/prediction.dart';
import 'risk_indicator.dart';

class PredictionCard extends StatelessWidget {
  const PredictionCard({required this.prediction, super.key});

  final Prediction prediction;

  @override
  Widget build(BuildContext context) {
    final percent = (prediction.confidence * 100).round();

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    prediction.condition,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                RiskIndicator(riskLevel: prediction.riskLevel),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: prediction.confidence),
            const SizedBox(height: 8),
            Text('Confidence: $percent%'),
            const SizedBox(height: 16),
            Text(prediction.recommendation),
            if (prediction.matchedSymptoms.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: prediction.matchedSymptoms
                    .map((symptom) => Chip(label: Text(symptom)))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
