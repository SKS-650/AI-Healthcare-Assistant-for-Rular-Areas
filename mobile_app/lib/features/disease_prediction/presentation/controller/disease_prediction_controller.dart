import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/prediction_result.dart';
import '../../domain/usecases/get_prediction_history.dart';
import '../../domain/usecases/get_prediction_result.dart';
import '../../domain/usecases/save_prediction.dart';
import 'disease_prediction_state.dart';

class DiseasePredictionController
    extends StateNotifier<DiseasePredictionState> {
  final GetPredictionResult getPredictionResult;
  final SavePrediction savePrediction;
  final GetPredictionHistory getPredictionHistory;

  DiseasePredictionController({
    required this.getPredictionResult,
    required this.savePrediction,
    required this.getPredictionHistory,
  }) : super(const DiseasePredictionState()) {
    loadHistory();
  }

  void addSymptom(String symptom) {
    final value = symptom.trim();
    if (value.isEmpty || state.symptoms.contains(value)) return;
    state = state.copyWith(
      symptoms: [...state.symptoms, value],
      clearError: true,
    );
  }

  void removeSymptom(String symptom) {
    state = state.copyWith(
      symptoms: state.symptoms.where((item) => item != symptom).toList(),
    );
  }

  Future<void> predict() async {
    if (state.symptoms.isEmpty) {
      state = state.copyWith(
        status: DiseasePredictionStatus.failure,
        errorMessage: 'Add at least one symptom before running prediction.',
      );
      return;
    }

    state = state.copyWith(
      status: DiseasePredictionStatus.loading,
      clearError: true,
    );
    try {
      final result = await getPredictionResult(state.symptoms);
      await savePrediction(result);
      final history = await getPredictionHistory();
      state = state.copyWith(
        status: DiseasePredictionStatus.success,
        predictionResult: result,
        history: history,
      );
    } catch (e) {
      state = state.copyWith(
        status: DiseasePredictionStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadHistory() async {
    try {
      final history = await getPredictionHistory();
      state = state.copyWith(history: history);
    } catch (e) {
      state = state.copyWith(
        status: DiseasePredictionStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  void selectResult(PredictionResult result) {
    state = state.copyWith(
      status: DiseasePredictionStatus.success,
      predictionResult: result,
    );
  }

  void reset() {
    state = DiseasePredictionState(history: state.history);
  }
}
