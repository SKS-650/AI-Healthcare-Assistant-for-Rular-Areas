import '../../domain/entities/prediction_result.dart';

enum DiseasePredictionStatus { initial, loading, success, failure }

class DiseasePredictionState {
  final DiseasePredictionStatus status;
  final List<String> symptoms;
  final PredictionResult? predictionResult;
  final List<PredictionResult> history;
  final String? errorMessage;

  const DiseasePredictionState({
    this.status = DiseasePredictionStatus.initial,
    this.symptoms = const [],
    this.predictionResult,
    this.history = const [],
    this.errorMessage,
  });

  DiseasePredictionState copyWith({
    DiseasePredictionStatus? status,
    List<String>? symptoms,
    PredictionResult? predictionResult,
    List<PredictionResult>? history,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return DiseasePredictionState(
      status: status ?? this.status,
      symptoms: symptoms ?? this.symptoms,
      predictionResult: clearResult
          ? null
          : predictionResult ?? this.predictionResult,
      history: history ?? this.history,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
