import '../entities/recommendation.dart';
import '../repositories/disease_prediction_repository.dart';

class GetRecommendations {
  final DiseasePredictionRepository repository;

  const GetRecommendations(this.repository);

  Future<Recommendation> call(String diseaseId) {
    return repository.getRecommendations(diseaseId);
  }
}
