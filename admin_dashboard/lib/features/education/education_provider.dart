import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api.dart';
import '../../core/models.dart';

class EducationState {
  final bool isLoading; final String? error;
  final List<HealthArticle> articles; final int total, page, pageSize;
  final String search; final bool? publishedFilter;
  const EducationState({
    this.isLoading = false, this.error, this.articles = const [],
    this.total = 0, this.page = 1, this.pageSize = 20,
    this.search = '', this.publishedFilter,
  });
  int get totalPages => (total / pageSize).ceil().clamp(1, 9999);
  EducationState copyWith({
    bool? isLoading, String? error, bool clearError = false,
    List<HealthArticle>? articles, int? total, int? page,
    String? search, bool? publishedFilter, bool clearPublished = false,
  }) => EducationState(
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    articles: articles ?? this.articles, total: total ?? this.total,
    page: page ?? this.page, pageSize: pageSize, search: search ?? this.search,
    publishedFilter: clearPublished ? null : (publishedFilter ?? this.publishedFilter),
  );
}

class EducationNotifier extends StateNotifier<EducationState> {
  EducationNotifier() : super(const EducationState()) { load(); }

  Future<void> load({int? page}) async {
    state = state.copyWith(isLoading: true, page: page ?? state.page);
    try {
      final params = <String, dynamic>{'page': state.page, 'page_size': state.pageSize};
      if (state.search.isNotEmpty) params['search'] = state.search;
      if (state.publishedFilter != null) params['is_published'] = state.publishedFilter;
      final resp = await ApiClient.instance.get('/admin/education/articles', queryParameters: params);
      final data = resp.data as Map<String, dynamic>;
      state = state.copyWith(
        isLoading: false,
        articles: (data['articles'] as List).cast<Map<String, dynamic>>().map(HealthArticle.fromJson).toList(),
        total: data['total'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ApiResult.fromError(e).error);
    }
  }

  void setSearch(String v) { state = state.copyWith(search: v, page: 1); load(); }
  void setPublishedFilter(bool? v) {
    state = v == null ? state.copyWith(clearPublished: true, page: 1) : state.copyWith(publishedFilter: v, page: 1);
    load();
  }
  void goToPage(int p) => load(page: p);

  Future<bool> createArticle(Map<String, dynamic> data) async {
    try {
      await ApiClient.instance.post('/admin/education/articles', data: data);
      load();
      return true;
    } catch (e) {
      state = state.copyWith(error: ApiResult.fromError(e).error);
      return false;
    }
  }

  Future<bool> updateArticle(String id, Map<String, dynamic> data) async {
    try {
      await ApiClient.instance.put('/admin/education/articles/$id', data: data);
      load();
      return true;
    } catch (e) {
      state = state.copyWith(error: ApiResult.fromError(e).error);
      return false;
    }
  }

  Future<bool> deleteArticle(String id) async {
    try {
      await ApiClient.instance.delete('/admin/education/articles/$id');
      load();
      return true;
    } catch (e) {
      state = state.copyWith(error: ApiResult.fromError(e).error);
      return false;
    }
  }
}

final educationProvider = StateNotifierProvider<EducationNotifier, EducationState>((ref) => EducationNotifier());
