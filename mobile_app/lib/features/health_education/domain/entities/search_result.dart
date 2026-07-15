import 'health_article.dart';

class SearchResult {
  final String query;
  final int total;
  final List<HealthArticle> articles;

  const SearchResult({
    required this.query,
    required this.total,
    required this.articles,
  });

  static SearchResult empty(String q) =>
      SearchResult(query: q, total: 0, articles: []);
}
