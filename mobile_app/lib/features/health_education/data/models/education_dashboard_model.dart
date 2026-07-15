import '../../domain/entities/education_dashboard.dart';
import 'health_article_model.dart';
import 'health_category_model.dart';

class EducationDashboardModel extends EducationDashboard {
  EducationDashboardModel({
    required super.featuredArticles,
    required super.categories,
    required super.recommendedArticles,
    required super.recentArticles,
    required super.bookmarks,
  });

  factory EducationDashboardModel.fromJson(Map<String, dynamic> json) {
    List<T> parseList<T>(String key, T Function(Map<String, dynamic>) parser) {
      final raw = json[key] as List?;
      if (raw == null) return [];
      return raw.map((e) => parser(e as Map<String, dynamic>)).toList();
    }

    return EducationDashboardModel(
      featuredArticles: parseList('featured_articles', HealthArticleModel.fromJson),
      categories:       parseList('categories',        HealthCategoryModel.fromJson),
      recommendedArticles: parseList('recommended_articles', HealthArticleModel.fromJson),
      recentArticles:   parseList('recent_articles',   HealthArticleModel.fromJson),
      bookmarks:        parseList('bookmarks',         HealthArticleModel.fromJson),
    );
  }
}
