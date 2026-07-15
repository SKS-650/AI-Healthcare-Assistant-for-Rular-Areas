class HealthArticle {
  final String id;
  final String? categoryId;
  final String? categoryName;
  final String? categorySlug;
  final String? categoryColor;
  final String title;
  final String slug;
  final String? summary;
  final String? content; // null in list view, populated in detail
  final String language;
  final String? author;
  final String? source;
  final int readTimeMin;
  final String? coverImage;
  final String? emoji;
  final List<String> tags;
  final bool isFeatured;
  final int viewCount;
  final int bookmarkCount;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  bool isBookmarked;

  HealthArticle({
    required this.id,
    this.categoryId,
    this.categoryName,
    this.categorySlug,
    this.categoryColor,
    required this.title,
    required this.slug,
    this.summary,
    this.content,
    required this.language,
    this.author,
    this.source,
    required this.readTimeMin,
    this.coverImage,
    this.emoji,
    required this.tags,
    required this.isFeatured,
    required this.viewCount,
    required this.bookmarkCount,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
    this.isBookmarked = false,
  });

  HealthArticle copyWith({bool? isBookmarked, String? content}) => HealthArticle(
        id: id,
        categoryId: categoryId,
        categoryName: categoryName,
        categorySlug: categorySlug,
        categoryColor: categoryColor,
        title: title,
        slug: slug,
        summary: summary,
        content: content ?? this.content,
        language: language,
        author: author,
        source: source,
        readTimeMin: readTimeMin,
        coverImage: coverImage,
        emoji: emoji,
        tags: tags,
        isFeatured: isFeatured,
        viewCount: viewCount,
        bookmarkCount: bookmarkCount,
        publishedAt: publishedAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isBookmarked: isBookmarked ?? this.isBookmarked,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is HealthArticle && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
