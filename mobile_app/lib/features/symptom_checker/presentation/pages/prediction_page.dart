import 'package:flutter/material.dart';

import '../../../../constants/app_strings.dart';
import '../../domain/entities/prediction.dart';
import '../widgets/prediction_card.dart';

class PredictionPage extends StatelessWidget {
  const PredictionPage({required this.prediction, super.key});

  final Prediction prediction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.prediction)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PredictionCard(prediction: prediction),
          const SizedBox(height: 16),
          const Card(
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'This result is educational support only and is not a medical diagnosis.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
