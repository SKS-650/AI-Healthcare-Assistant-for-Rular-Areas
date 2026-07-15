import '../entities/article_list_result.dart';
import '../entities/bookmark.dart';
import '../entities/education_dashboard.dart';
import '../entities/health_article.dart';
import '../entities/health_category.dart';
import '../entities/search_result.dart';

abstract class HealthEducationRepository {
  // ── Dashboard ─────────────────────────────────────────────────────────────
  Future<EducationDashboard> getDashboard({String language = 'en'});

  // ── Categories ────────────────────────────────────────────────────────────
  Future<List<HealthCategory>> getCategories();

  // ── Articles ──────────────────────────────────────────────────────────────
  Future<ArticleListResult> getArticles({
    String? categorySlug,
    String language = 'en',
    int page = 1,
    int perPage = 20,
  });

  Future<HealthArticle> getArticleDetail(String articleId);

  Future<List<HealthArticle>> getFeaturedArticles({
    String language = 'en',
    int limit = 5,
  });

  // ── Search ────────────────────────────────────────────────────────────────
  Future<SearchResult> searchArticles({
    required String query,
    String language = 'en',
    int limit = 20,
  });

  // ── Recommendations ───────────────────────────────────────────────────────
  Future<List<HealthArticle>> getRecommendations({
    String language = 'en',
    int limit = 8,
  });

  // ── Bookmarks ─────────────────────────────────────────────────────────────
  Future<List<HealthArticle>> getBookmarks({String language = 'en'});
  Future<Bookmark> addBookmark(String articleId);
  Future<void> removeBookmark(String bookmarkId);

  // ── Reading progress ──────────────────────────────────────────────────────
  Future<void> updateReadingProgress({
    required String articleId,
    required int position,
    bool isCompleted = false,
  });

  // ── Offline ───────────────────────────────────────────────────────────────
  Future<void> saveArticleOffline(HealthArticle article);
  Future<List<HealthArticle>> getOfflineArticles();
  Future<void> removeOfflineArticle(String articleId);
  Future<bool> isArticleOffline(String articleId);
}
