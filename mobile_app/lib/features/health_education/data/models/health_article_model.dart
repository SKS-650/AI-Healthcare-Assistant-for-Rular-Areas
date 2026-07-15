import '../../domain/entities/health_article.dart';

class HealthArticleModel extends HealthArticle {
  HealthArticleModel({
    required super.id,
    super.categoryId,
    super.categoryName,
    super.categorySlug,
    super.categoryColor,
    required super.title,
    required super.slug,
    super.summary,
    super.content,
    required super.language,
    super.author,
    super.source,
    required super.readTimeMin,
    super.coverImage,
    super.emoji,
    required super.tags,
    required super.isFeatured,
    required super.viewCount,
    required super.bookmarkCount,
    super.publishedAt,
    super.createdAt,
    super.updatedAt,
    super.isBookmarked = false,
  });

  factory HealthArticleModel.fromJson(Map<String, dynamic> json) {
    return HealthArticleModel(
      id:             json['id'] as String,
      categoryId:     json['category_id'] as String?,
      categoryName:   json['category_name'] as String?,
      categorySlug:   json['category_slug'] as String?,
      categoryColor:  json['category_color'] as String?,
      title:          json['title'] as String,
      slug:           json['slug'] as String,
      summary:        json['summary'] as String?,
      content:        json['content'] as String?,
      language:       json['language'] as String? ?? 'en',
      author:         json['author'] as String?,
      source:         json['source'] as String?,
      readTimeMin:    (json['read_time_min'] as num?)?.toInt() ?? 3,
      coverImage:     json['cover_image'] as String?,
      emoji:          json['emoji'] as String?,
      tags:           List<String>.from(json['tags'] as List? ?? []),
      isFeatured:     json['is_featured'] as bool? ?? false,
      viewCount:      (json['view_count'] as num?)?.toInt() ?? 0,
      bookmarkCount:  (json['bookmark_count'] as num?)?.toInt() ?? 0,
      publishedAt:    json['published_at'] != null
          ? DateTime.tryParse(json['published_at'] as String)
          : null,
      createdAt:      json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt:      json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      isBookmarked:   json['is_bookmarked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id':             id,
        'category_id':    categoryId,
        'category_name':  categoryName,
        'category_slug':  categorySlug,
        'category_color': categoryColor,
        'title':          title,
        'slug':           slug,
        'summary':        summary,
        'content':        content,
        'language':       language,
        'author':         author,
        'source':         source,
        'read_time_min':  readTimeMin,
        'cover_image':    coverImage,
        'emoji':          emoji,
        'tags':           tags,
        'is_featured':    isFeatured,
        'view_count':     viewCount,
        'bookmark_count': bookmarkCount,
        'published_at':   publishedAt?.toIso8601String(),
        'created_at':     createdAt?.toIso8601String(),
        'updated_at':     updatedAt?.toIso8601String(),
        'is_bookmarked':  isBookmarked,
      };

  factory HealthArticleModel.fromEntity(HealthArticle e) => HealthArticleModel(
        id: e.id, categoryId: e.categoryId, categoryName: e.categoryName,
        categorySlug: e.categorySlug, categoryColor: e.categoryColor,
        title: e.title, slug: e.slug, summary: e.summary, content: e.content,
        language: e.language, author: e.author, source: e.source,
        readTimeMin: e.readTimeMin, coverImage: e.coverImage, emoji: e.emoji,
        tags: e.tags, isFeatured: e.isFeatured, viewCount: e.viewCount,
        bookmarkCount: e.bookmarkCount, publishedAt: e.publishedAt,
        createdAt: e.createdAt, updatedAt: e.updatedAt,
        isBookmarked: e.isBookmarked,
      );
}
