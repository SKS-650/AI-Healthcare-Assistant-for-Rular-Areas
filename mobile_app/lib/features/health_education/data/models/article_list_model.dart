import '../../domain/entities/article_list_result.dart';
import 'health_article_model.dart';

class ArticleListModel extends ArticleListResult {
  const ArticleListModel({
    required super.total,
    required super.page,
    required super.perPage,
    required super.articles,
  });

  factory ArticleListModel.fromJson(Map<String, dynamic> json) {
    final rawArticles = json['articles'] as List? ?? [];
    return ArticleListModel(
      total:    (json['total']    as num?)?.toInt() ?? 0,
      page:     (json['page']     as num?)?.toInt() ?? 1,
      perPage:  (json['per_page'] as num?)?.toInt() ?? 20,
      articles: rawArticles
          .map((e) => HealthArticleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
