import '../entities/bookmark.dart';
import '../entities/health_article.dart';
import '../repositories/health_education_repository.dart';

class GetBookmarks {
  final HealthEducationRepository _repo;
  const GetBookmarks(this._repo);
  Future<List<HealthArticle>> call({String language = 'en'}) =>
      _repo.getBookmarks(language: language);
}

class AddBookmark {
  final HealthEducationRepository _repo;
  const AddBookmark(this._repo);
  Future<Bookmark> call(String articleId) => _repo.addBookmark(articleId);
}

class RemoveBookmark {
  final HealthEducationRepository _repo;
  const RemoveBookmark(this._repo);
  Future<void> call(String bookmarkId) => _repo.removeBookmark(bookmarkId);
}
