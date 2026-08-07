import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/disease_prediction_remote_datasource.dart';
import '../../data/repositories/disease_prediction_repository_impl.dart';
import '../../domain/repositories/disease_prediction_repository.dart';
import '../../domain/usecases/get_prediction_history.dart';
import '../../domain/usecases/get_prediction_result.dart';
import '../../domain/usecases/get_recommendations.dart';
import '../../domain/usecases/save_prediction.dart';
import '../controller/disease_prediction_controller.dart';
import '../controller/disease_prediction_state.dart';

// ── Network client ────────────────────────────────────────────────────────────

final _apiClientProvider = Provider<SimpleApiClient>(
  (_) => SimpleApiClient.instance,
);

// ── Data source ───────────────────────────────────────────────────────────────

final _remoteDatasourceProvider =
    Provider<DiseasePredictionRemoteDataSource>((ref) {
  return DiseasePredictionRemoteDataSource(
      ref.watch(_apiClientProvider));
});

// ── Repository ────────────────────────────────────────────────────────────────

final diseasePredictionRepositoryProvider =
    Provider<DiseasePredictionRepository>((ref) {
  return DiseasePredictionRepositoryImpl(
    remoteDataSource: ref.watch(_remoteDatasourceProvider),
  );
});

// ── Use-cases ─────────────────────────────────────────────────────────────────

final getPredictionResultProvider = Provider((ref) {
  return GetPredictionResult(
      ref.watch(diseasePredictionRepositoryProvider));
});

final savePredictionProvider = Provider((ref) {
  return SavePrediction(
      ref.watch(diseasePredictionRepositoryProvider));
});

final getPredictionHistoryProvider = Provider((ref) {
  return GetPredictionHistory(
      ref.watch(diseasePredictionRepositoryProvider));
});

final getRecommendationsProvider = Provider((ref) {
  return GetRecommendations(
      ref.watch(diseasePredictionRepositoryProvider));
});

// ── Controller ────────────────────────────────────────────────────────────────

final diseasePredictionControllerProvider =
    StateNotifierProvider<DiseasePredictionController,
        DiseasePredictionState>((ref) {
  return DiseasePredictionController(
    getPredictionResult: ref.watch(getPredictionResultProvider),
    savePrediction: ref.watch(savePredictionProvider),
    getPredictionHistory: ref.watch(getPredictionHistoryProvider),
  );
});
