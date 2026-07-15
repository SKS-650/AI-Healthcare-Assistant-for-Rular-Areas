import '../entities/health_article.dart';
import '../repositories/health_education_repository.dart';

class GetRecommendations {
  final HealthEducationRepository _repo;
  const GetRecommendations(this._repo);

  Future<List<HealthArticle>> call({String language = 'en', int limit = 8}) =>
      _repo.getRecommendations(language: language, limit: limit);
}
