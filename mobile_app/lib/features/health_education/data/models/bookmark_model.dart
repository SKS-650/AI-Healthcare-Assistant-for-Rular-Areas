import '../../domain/entities/bookmark.dart';

class BookmarkModel extends Bookmark {
  const BookmarkModel({
    required super.id,
    required super.userId,
    required super.articleId,
    required super.createdAt,
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) => BookmarkModel(
        id:        json['id'] as String,
        userId:    json['user_id'] as String,
        articleId: json['article_id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id':         id,
        'user_id':    userId,
        'article_id': articleId,
        'created_at': createdAt.toIso8601String(),
      };
}
