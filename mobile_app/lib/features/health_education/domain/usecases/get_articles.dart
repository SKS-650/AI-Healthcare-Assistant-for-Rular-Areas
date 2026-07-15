import '../entities/article_list_result.dart';
import '../repositories/health_education_repository.dart';

class GetArticles {
  final HealthEducationRepository _repo;
  const GetArticles(this._repo);

  Future<ArticleListResult> call({
    String? categorySlug,
    String language = 'en',
    int page = 1,
    int perPage = 20,
  }) =>
      _repo.getArticles(
        categorySlug: categorySlug,
        language: language,
        page: page,
        perPage: perPage,
      );
}
