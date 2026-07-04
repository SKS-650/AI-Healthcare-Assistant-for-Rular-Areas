// lib/features/home/domain/entities/article.dart
class Article {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final String readTime;

  const Article({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.readTime,
  });
}