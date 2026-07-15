import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/article_list_result.dart';
import '../../domain/entities/health_article.dart';
import '../../domain/repositories/health_education_repository.dart';
import '../../domain/usecases/get_article_detail.dart';
import '../../domain/usecases/get_articles.dart';
import '../../domain/usecases/get_education_dashboard.dart';
import '../../domain/usecases/manage_bookmarks.dart';
import '../../domain/usecases/manage_offline.dart';
import '../../domain/usecases/search_articles.dart';
import 'health_education_state.dart';

class HealthEducationController
    extends StateNotifier<HealthEducationState> {
  final HealthEducationRepository repository;
  final GetEducationDashboard   _getDashboard;
  final GetArticles             _getArticles;
  final GetArticleDetail        _getDetail;
  final SearchArticles          _search;
  final GetBookmarks            _getBookmarks;
  final AddBookmark             _addBookmark;
  final RemoveBookmark          _removeBookmark;
  final SaveArticleOffline      _saveOffline;
  final GetOfflineArticles      _getOffline;
  final RemoveOfflineArticle    _removeOffline;
  final IsArticleOffline        _isOffline;
  final UpdateReadingProgress   _updateProgress;

  HealthEducationController({
    required this.repository,
    required GetEducationDashboard   getDashboard,
    required GetArticles             getArticles,
    required GetArticleDetail        getDetail,
    required SearchArticles          search,
    required GetBookmarks            getBookmarks,
    required AddBookmark             addBookmark,
    required RemoveBookmark          removeBookmark,
    required SaveArticleOffline      saveOffline,
    required GetOfflineArticles      getOffline,
    required RemoveOfflineArticle    removeOffline,
    required IsArticleOffline        isOffline,
    required UpdateReadingProgress   updateProgress,
  })  : _getDashboard      = getDashboard,
        _getArticles       = getArticles,
        _getDetail         = getDetail,
        _search            = search,
        _getBookmarks      = getBookmarks,
        _addBookmark       = addBookmark,
        _removeBookmark    = removeBookmark,
        _saveOffline       = saveOffline,
        _getOffline        = getOffline,
        _removeOffline     = removeOffline,
        _isOffline         = isOffline,
        _updateProgress    = updateProgress,
        super(const HealthEducationState()) {
    loadDashboard();
  }

  // ── Dashboard ─────────────────────────────────────────────────────────────

  Future<void> loadDashboard() async {
    state = state.copyWith(status: HealthEducationStatus.loading, clearError: true);
    try {
      final dashboard = await _getDashboard(language: state.activeLanguage);
      final offline   = await _getOffline();
      final offIds    = offline.map((a) => a.id).toSet();
      state = state.copyWith(
        status:          HealthEducationStatus.loaded,
        dashboard:       dashboard,
        bookmarks:       dashboard.bookmarks,
        offlineArticles: offline,
        offlineIds:      offIds,
      );
    } catch (e) {
      state = state.copyWith(
        status:       HealthEducationStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Article list ──────────────────────────────────────────────────────────

  Future<void> loadArticles({String? categorySlug, int page = 1}) async {
    state = state.copyWith(status: HealthEducationStatus.loading, clearError: true);
    try {
      final result = await _getArticles(
        categorySlug: categorySlug,
        language: state.activeLanguage,
        page: page,
      );
      state = state.copyWith(
        status:             HealthEducationStatus.loaded,
        articleList:        result,
        activeCategorySlug: categorySlug,
      );
    } catch (e) {
      state = state.copyWith(
        status: HealthEducationStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMoreArticles() async {
    if (!state.articleList.hasMore) return;
    try {
      final result = await _getArticles(
        categorySlug: state.activeCategorySlug,
        language:     state.activeLanguage,
        page:         state.articleList.page + 1,
      );
      final merged = [
        ...state.articleList.articles,
        ...result.articles,
      ];
      state = state.copyWith(
        articleList: result.copyWith(articles: merged),
      );
    } catch (_) {}
  }

  void filterByCategory(String? slug) {
    if (slug == state.activeCategorySlug) {
      // Deselect — show all
      loadArticles(categorySlug: null);
    } else {
      loadArticles(categorySlug: slug);
    }
  }

  // ── Article detail ────────────────────────────────────────────────────────

  Future<void> openArticle(String articleId) async {
    state = state.copyWith(detailLoading: true, clearError: true);
    try {
      final article = await _getDetail(articleId);
      final isOff   = await _isOffline(articleId);
      state = state.copyWith(
        selectedArticle: article.copyWith(isBookmarked: article.isBookmarked),
        detailLoading:   false,
        offlineIds: isOff
            ? {...state.offlineIds, articleId}
            : state.offlineIds,
      );
    } catch (e) {
      state = state.copyWith(
        detailLoading: false,
        errorMessage:  e.toString(),
      );
    }
  }

  // ── Search ────────────────────────────────────────────────────────────────

  Future<void> searchArticles(String query) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }
    state = state.copyWith(
      status: HealthEducationStatus.searching,
      searchQuery: query,
      isSearchActive: true,
    );
    try {
      final result = await _search(query: query, language: state.activeLanguage);
      state = state.copyWith(
        status:        HealthEducationStatus.loaded,
        searchResults: result.articles,
      );
    } catch (e) {
      state = state.copyWith(
        status:       HealthEducationStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  void clearSearch() {
    state = state.copyWith(
      isSearchActive: false,
      searchQuery:    '',
      searchResults:  [],
      status:         HealthEducationStatus.loaded,
    );
  }

  // ── Bookmarks ─────────────────────────────────────────────────────────────

  Future<void> loadBookmarks() async {
    try {
      final bms = await _getBookmarks(language: state.activeLanguage);
      state = state.copyWith(bookmarks: bms);
    } catch (_) {}
  }

  Future<void> toggleBookmark(HealthArticle article) async {
    if (article.isBookmarked) {
      // Remove — use article.id as bookmark id for simplicity
      await _removeBookmark('local-${article.id}');
      final updated = state.bookmarks.where((a) => a.id != article.id).toList();
      state = state.copyWith(bookmarks: updated);
      // Update selected article state
      if (state.selectedArticle?.id == article.id) {
        state = state.copyWith(
          selectedArticle: state.selectedArticle!.copyWith(isBookmarked: false),
        );
      }
    } else {
      await _addBookmark(article.id);
      final updated = [article.copyWith(isBookmarked: true), ...state.bookmarks];
      state = state.copyWith(bookmarks: updated);
      if (state.selectedArticle?.id == article.id) {
        state = state.copyWith(
          selectedArticle: state.selectedArticle!.copyWith(isBookmarked: true),
        );
      }
    }
  }

  // ── Offline ───────────────────────────────────────────────────────────────

  Future<void> toggleOffline(HealthArticle article) async {
    if (state.offlineIds.contains(article.id)) {
      await _removeOffline(article.id);
      final newIds = {...state.offlineIds}..remove(article.id);
      final newList = state.offlineArticles.where((a) => a.id != article.id).toList();
      state = state.copyWith(offlineArticles: newList, offlineIds: newIds);
    } else {
      // Fetch full content first
      final full = state.selectedArticle?.id == article.id
          ? state.selectedArticle!
          : await _getDetail(article.id);
      await _saveOffline(full);
      final newIds = {...state.offlineIds, article.id};
      final newList = [full, ...state.offlineArticles];
      state = state.copyWith(offlineArticles: newList, offlineIds: newIds);
    }
  }

  // ── Reading progress ──────────────────────────────────────────────────────

  Future<void> trackProgress(String articleId, int position,
      {bool completed = false}) async {
    await _updateProgress(
        articleId: articleId, position: position, isCompleted: completed);
  }

  // ── Language ──────────────────────────────────────────────────────────────

  void setLanguage(String lang) {
    state = state.copyWith(activeLanguage: lang);
    loadDashboard();
  }
}

extension on ArticleListResult {
  ArticleListResult copyWith({List<HealthArticle>? articles}) =>
      ArticleListResult(
        total:    total,
        page:     page,
        perPage:  perPage,
        articles: articles ?? this.articles,
      );
}
