import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../config/api_config.dart';
import '../../../../constants/api_constants.dart';
import '../../../../core/local_db/local_db_service.dart';
import '../../../authentication/data/repositories/authentication_repository_impl.dart';
import '../../domain/entities/article_list_result.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/entities/education_dashboard.dart';
import '../../domain/entities/health_article.dart';
import '../../domain/entities/health_category.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/health_education_repository.dart';
import '../datasources/education_dummy_data.dart';
import '../models/article_list_model.dart';
import '../models/bookmark_model.dart';
import '../models/education_dashboard_model.dart';
import '../models/health_article_model.dart';
import '../models/health_category_model.dart';

class HealthEducationRepositoryImpl implements HealthEducationRepository {
  final AuthenticationRepositoryImpl _authRepo;

  HealthEducationRepositoryImpl(this._authRepo);

  String? get _token => _authRepo.accessToken;

  // ── HTTP helpers ─────────────────────────────────────────────────────────

  Future<http.Response?> _get(String path, {Map<String, String>? params}) async {
    if (_token == null || _token!.isEmpty) return null;
    try {
      var uri = Uri.parse('${ApiConfig.baseUrl}$path');
      if (params != null && params.isNotEmpty) {
        uri = uri.replace(queryParameters: params);
      }
      return await _authRepo.authenticatedRequest(
        (headers) => http.get(uri, headers: headers)
            .timeout(const Duration(seconds: 20)),
      );
    } catch (_) {
      return null;
    }
  }

  Future<http.Response?> _post(String path, Map<String, dynamic> body) async {
    if (_token == null || _token!.isEmpty) return null;
    try {
      return await _authRepo.authenticatedRequest(
        (headers) => http.post(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: headers,
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 20)),
      );
    } catch (_) {
      return null;
    }
  }

  Future<http.Response?> _delete(String path) async {
    if (_token == null || _token!.isEmpty) return null;
    try {
      return await _authRepo.authenticatedRequest(
        (headers) => http.delete(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: headers,
        ).timeout(const Duration(seconds: 20)),
      );
    } catch (_) {
      return null;
    }
  }

  // ── Dashboard ─────────────────────────────────────────────────────────────

  @override
  Future<EducationDashboard> getDashboard({String language = 'en'}) async {
    final resp = await _get(ApiConstants.educationDashboardPath,
        params: {'language': language});
    if (resp != null && resp.statusCode == 200) {
      try {
        return EducationDashboardModel.fromJson(
            jsonDecode(resp.body) as Map<String, dynamic>);
      } catch (_) {}
    }
    // Offline fallback
    final cached = await LocalDbService.instance.loadEducationDashboard();
    if (cached != null) return cached;
    return _buildDummyDashboard();
  }

  EducationDashboard _buildDummyDashboard() => EducationDashboard(
        featuredArticles:    EducationDummyData.featuredArticles,
        categories:          EducationDummyData.categories,
        recommendedArticles: EducationDummyData.recommendedArticles,
        recentArticles:      [],
        bookmarks:           [],
      );

  // ── Categories ────────────────────────────────────────────────────────────

  @override
  Future<List<HealthCategory>> getCategories() async {
    final resp = await _get(ApiConstants.educationCategoriesPath);
    if (resp != null && resp.statusCode == 200) {
      try {
        final list = jsonDecode(resp.body) as List;
        return list
            .map((e) => HealthCategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    return EducationDummyData.categories;
  }

  // ── Articles ──────────────────────────────────────────────────────────────

  @override
  Future<ArticleListResult> getArticles({
    String? categorySlug,
    String language = 'en',
    int page = 1,
    int perPage = 20,
  }) async {
    final params = <String, String>{
      'language': language,
      'page':     '$page',
      'per_page': '$perPage',
      if (categorySlug != null) 'category': categorySlug,
    };
    final resp = await _get(ApiConstants.educationArticlesPath, params: params);
    if (resp != null && resp.statusCode == 200) {
      try {
        return ArticleListModel.fromJson(
            jsonDecode(resp.body) as Map<String, dynamic>);
      } catch (_) {}
    }
    // Offline fallback
    final all = categorySlug != null
        ? EducationDummyData.articlesByCategory(categorySlug)
        : EducationDummyData.articles;
    return ArticleListResult(
      total: all.length, page: 1, perPage: all.length, articles: all,
    );
  }

  @override
  Future<HealthArticle> getArticleDetail(String articleId) async {
    final resp = await _get(ApiConstants.educationArticleById(articleId));
    if (resp != null && resp.statusCode == 200) {
      try {
        return HealthArticleModel.fromJson(
            jsonDecode(resp.body) as Map<String, dynamic>);
      } catch (_) {}
    }
    // Offline fallback: check saved articles first
    final offline = await LocalDbService.instance.getOfflineArticle(articleId);
    if (offline != null) return offline;
    return EducationDummyData.byId(articleId) ??
        EducationDummyData.articles.first;
  }

  @override
  Future<List<HealthArticle>> getFeaturedArticles({
    String language = 'en', int limit = 5,
  }) async {
    final resp = await _get(ApiConstants.educationFeaturedPath,
        params: {'language': language, 'limit': '$limit'});
    if (resp != null && resp.statusCode == 200) {
      try {
        final list = jsonDecode(resp.body) as List;
        return list
            .map((e) => HealthArticleModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    return EducationDummyData.featuredArticles.take(limit).toList();
  }

  // ── Search ────────────────────────────────────────────────────────────────

  @override
  Future<SearchResult> searchArticles({
    required String query,
    String language = 'en',
    int limit = 20,
  }) async {
    final resp = await _get(ApiConstants.educationSearchPath,
        params: {'q': query, 'language': language, 'limit': '$limit'});
    if (resp != null && resp.statusCode == 200) {
      try {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final list = data['articles'] as List? ?? [];
        return SearchResult(
          query: query,
          total: (data['total'] as num?)?.toInt() ?? 0,
          articles: list
              .map((e) => HealthArticleModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      } catch (_) {}
    }
    final results = EducationDummyData.search(query);
    return SearchResult(query: query, total: results.length, articles: results);
  }

  // ── Recommendations ───────────────────────────────────────────────────────

  @override
  Future<List<HealthArticle>> getRecommendations({
    String language = 'en', int limit = 8,
  }) async {
    final resp = await _get(ApiConstants.educationRecommendPath,
        params: {'language': language, 'limit': '$limit'});
    if (resp != null && resp.statusCode == 200) {
      try {
        final list = jsonDecode(resp.body) as List;
        return list
            .map((e) => HealthArticleModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    return EducationDummyData.recommendedArticles.take(limit).toList();
  }

  // ── Bookmarks ─────────────────────────────────────────────────────────────

  @override
  Future<List<HealthArticle>> getBookmarks({String language = 'en'}) async {
    final resp = await _get(ApiConstants.educationBookmarksPath,
        params: {'language': language});
    if (resp != null && resp.statusCode == 200) {
      try {
        final list = jsonDecode(resp.body) as List;
        return list
            .map((e) => HealthArticleModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    // Return locally bookmarked
    return await LocalDbService.instance.loadBookmarkedArticles();
  }

  @override
  Future<Bookmark> addBookmark(String articleId) async {
    final resp =
        await _post(ApiConstants.educationBookmarksPath, {'article_id': articleId});
    if (resp != null && resp.statusCode == 201) {
      try {
        return BookmarkModel.fromJson(
            jsonDecode(resp.body) as Map<String, dynamic>);
      } catch (_) {}
    }
    // Local bookmark fallback
    await LocalDbService.instance.addLocalBookmark(articleId);
    return BookmarkModel(
      id: 'local-$articleId',
      userId: 'local',
      articleId: articleId,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> removeBookmark(String bookmarkId) async {
    await _delete(ApiConstants.educationBookmarkById(bookmarkId));
    await LocalDbService.instance.removeLocalBookmark(bookmarkId);
  }

  // ── Reading progress ──────────────────────────────────────────────────────

  @override
  Future<void> updateReadingProgress({
    required String articleId,
    required int position,
    bool isCompleted = false,
  }) async {
    await _post(
      ApiConstants.educationReadProgress(articleId),
      {'last_read_position': position, 'is_completed': isCompleted},
    );
    await LocalDbService.instance.saveReadingProgress(
        articleId: articleId, position: position, isCompleted: isCompleted);
  }

  // ── Offline ───────────────────────────────────────────────────────────────

  @override
  Future<void> saveArticleOffline(HealthArticle article) async {
    await LocalDbService.instance
        .saveOfflineArticle(HealthArticleModel.fromEntity(article));
  }

  @override
  Future<List<HealthArticle>> getOfflineArticles() async {
    return await LocalDbService.instance.loadOfflineArticles();
  }

  @override
  Future<void> removeOfflineArticle(String articleId) async {
    await LocalDbService.instance.removeOfflineArticle(articleId);
  }

  @override
  Future<bool> isArticleOffline(String articleId) async {
    return await LocalDbService.instance.isArticleOffline(articleId);
  }
}
