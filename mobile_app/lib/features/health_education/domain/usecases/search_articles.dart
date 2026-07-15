import '../entities/search_result.dart';
import '../repositories/health_education_repository.dart';

class SearchArticles {
  final HealthEducationRepository _repo;
  const SearchArticles(this._repo);

  Future<SearchResult> call({
    required String query,
    String language = 'en',
    int limit = 20,
  }) =>
      _repo.searchArticles(query: query, language: language, limit: limit);
}
