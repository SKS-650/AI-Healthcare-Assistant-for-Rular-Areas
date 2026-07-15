class Bookmark {
  final String id;
  final String userId;
  final String articleId;
  final DateTime createdAt;

  const Bookmark({
    required this.id,
    required this.userId,
    required this.articleId,
    required this.createdAt,
  });
}
