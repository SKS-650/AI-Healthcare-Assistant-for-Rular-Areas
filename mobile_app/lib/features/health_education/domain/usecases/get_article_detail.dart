import '../entities/health_article.dart';
import '../repositories/health_education_repository.dart';

class GetArticleDetail {
  final HealthEducationRepository _repo;
  const GetArticleDetail(this._repo);

  Future<HealthArticle> call(String articleId) =>
      _repo.getArticleDetail(articleId);
}
