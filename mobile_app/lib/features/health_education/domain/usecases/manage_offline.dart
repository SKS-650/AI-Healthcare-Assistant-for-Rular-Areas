import '../entities/health_article.dart';
import '../repositories/health_education_repository.dart';

class SaveArticleOffline {
  final HealthEducationRepository _repo;
  const SaveArticleOffline(this._repo);
  Future<void> call(HealthArticle article) => _repo.saveArticleOffline(article);
}

class GetOfflineArticles {
  final HealthEducationRepository _repo;
  const GetOfflineArticles(this._repo);
  Future<List<HealthArticle>> call() => _repo.getOfflineArticles();
}

class RemoveOfflineArticle {
  final HealthEducationRepository _repo;
  const RemoveOfflineArticle(this._repo);
  Future<void> call(String articleId) => _repo.removeOfflineArticle(articleId);
}

class IsArticleOffline {
  final HealthEducationRepository _repo;
  const IsArticleOffline(this._repo);
  Future<bool> call(String articleId) => _repo.isArticleOffline(articleId);
}

class UpdateReadingProgress {
  final HealthEducationRepository _repo;
  const UpdateReadingProgress(this._repo);
  Future<void> call({
    required String articleId,
    required int position,
    bool isCompleted = false,
  }) =>
      _repo.updateReadingProgress(
          articleId: articleId, position: position, isCompleted: isCompleted);
}
