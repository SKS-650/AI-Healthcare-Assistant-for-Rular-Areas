import 'health_article.dart';
import 'health_category.dart';

class EducationDashboard {
  final List<HealthArticle> featuredArticles;
  final List<HealthCategory> categories;
  final List<HealthArticle> recommendedArticles;
  final List<HealthArticle> recentArticles;
  final List<HealthArticle> bookmarks;

  const EducationDashboard({
    required this.featuredArticles,
    required this.categories,
    required this.recommendedArticles,
    required this.recentArticles,
    required this.bookmarks,
  });

  static EducationDashboard empty() => const EducationDashboard(
        featuredArticles: [],
        categories: [],
        recommendedArticles: [],
        recentArticles: [],
        bookmarks: [],
      );
}
