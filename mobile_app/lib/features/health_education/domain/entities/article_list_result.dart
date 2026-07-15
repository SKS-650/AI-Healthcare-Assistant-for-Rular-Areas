import 'health_article.dart';

class ArticleListResult {
  final int total;
  final int page;
  final int perPage;
  final List<HealthArticle> articles;

  const ArticleListResult({
    required this.total,
    required this.page,
    required this.perPage,
    required this.articles,
  });

  bool get hasMore => articles.length < total;

  static ArticleListResult empty() => const ArticleListResult(
        total: 0, page: 1, perPage: 20, articles: [],
      );
}
