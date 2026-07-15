import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/data/repositories/authentication_repository_impl.dart';
import '../../../authentication/presentation/providers/authentication_provider.dart';
import '../../data/repositories/health_education_repository_impl.dart';
import '../../domain/repositories/health_education_repository.dart';
import '../../domain/usecases/get_article_detail.dart';
import '../../domain/usecases/get_articles.dart';
import '../../domain/usecases/get_education_dashboard.dart';
import '../../domain/usecases/manage_bookmarks.dart';
import '../../domain/usecases/manage_offline.dart';
import '../../domain/usecases/search_articles.dart';
import '../controllers/health_education_controller.dart';
import '../controllers/health_education_state.dart';

// ── Repository ────────────────────────────────────────────────────────────────

final healthEducationRepositoryProvider =
    Provider<HealthEducationRepository>((ref) {
  final authRepo =
      ref.watch(authRepositoryProvider) as AuthenticationRepositoryImpl;
  return HealthEducationRepositoryImpl(authRepo);
});

// ── Controller ────────────────────────────────────────────────────────────────

final healthEducationControllerProvider =
    StateNotifierProvider<HealthEducationController, HealthEducationState>((ref) {
  final repo = ref.watch(healthEducationRepositoryProvider);
  return HealthEducationController(
    repository:         repo,
    getDashboard:       GetEducationDashboard(repo),
    getArticles:        GetArticles(repo),
    getDetail:          GetArticleDetail(repo),
    search:             SearchArticles(repo),
    getBookmarks:       GetBookmarks(repo),
    addBookmark:        AddBookmark(repo),
    removeBookmark:     RemoveBookmark(repo),
    saveOffline:        SaveArticleOffline(repo),
    getOffline:         GetOfflineArticles(repo),
    removeOffline:      RemoveOfflineArticle(repo),
    isOffline:          IsArticleOffline(repo),
    updateProgress:     UpdateReadingProgress(repo),
  );
});
