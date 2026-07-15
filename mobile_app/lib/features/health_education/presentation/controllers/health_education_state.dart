import '../../domain/entities/article_list_result.dart';
import '../../domain/entities/education_dashboard.dart';
import '../../domain/entities/health_article.dart';

enum HealthEducationStatus { initial, loading, loaded, searching, failure }

class HealthEducationState {
  final HealthEducationStatus status;
  final EducationDashboard dashboard;

  // Article list
  final ArticleListResult articleList;
  final String? activeCategorySlug;
  final String activeLanguage;

  // Article detail
  final HealthArticle? selectedArticle;
  final bool detailLoading;

  // Search
  final String searchQuery;
  final List<HealthArticle> searchResults;
  final bool isSearchActive;

  // Bookmarks
  final List<HealthArticle> bookmarks;

  // Offline
  final List<HealthArticle> offlineArticles;
  final Set<String> offlineIds;

  final String? errorMessage;

  const HealthEducationState({
    this.status               = HealthEducationStatus.initial,
    EducationDashboard?       dashboard,
    ArticleListResult?        articleList,
    this.activeCategorySlug,
    this.activeLanguage       = 'en',
    this.selectedArticle,
    this.detailLoading        = false,
    this.searchQuery          = '',
    this.searchResults        = const [],
    this.isSearchActive       = false,
    this.bookmarks            = const [],
    this.offlineArticles      = const [],
    this.offlineIds           = const {},
    this.errorMessage,
  })  : dashboard   = dashboard   ?? const EducationDashboard(featuredArticles: [], categories: [], recommendedArticles: [], recentArticles: [], bookmarks: []),
        articleList = articleList ?? const ArticleListResult(total: 0, page: 1, perPage: 20, articles: []);

  HealthEducationState copyWith({
    HealthEducationStatus? status,
    EducationDashboard?    dashboard,
    ArticleListResult?     articleList,
    String?                activeCategorySlug,
    bool                   clearCategory = false,
    String?                activeLanguage,
    HealthArticle?         selectedArticle,
    bool?                  detailLoading,
    String?                searchQuery,
    List<HealthArticle>?   searchResults,
    bool?                  isSearchActive,
    List<HealthArticle>?   bookmarks,
    List<HealthArticle>?   offlineArticles,
    Set<String>?           offlineIds,
    String?                errorMessage,
    bool                   clearError = false,
  }) {
    return HealthEducationState(
      status:              status              ?? this.status,
      dashboard:           dashboard           ?? this.dashboard,
      articleList:         articleList         ?? this.articleList,
      activeCategorySlug:  clearCategory ? null : (activeCategorySlug ?? this.activeCategorySlug),
      activeLanguage:      activeLanguage      ?? this.activeLanguage,
      selectedArticle:     selectedArticle     ?? this.selectedArticle,
      detailLoading:       detailLoading       ?? this.detailLoading,
      searchQuery:         searchQuery         ?? this.searchQuery,
      searchResults:       searchResults       ?? this.searchResults,
      isSearchActive:      isSearchActive      ?? this.isSearchActive,
      bookmarks:           bookmarks           ?? this.bookmarks,
      offlineArticles:     offlineArticles     ?? this.offlineArticles,
      offlineIds:          offlineIds          ?? this.offlineIds,
      errorMessage:        clearError ? null   : (errorMessage ?? this.errorMessage),
    );
  }
}
