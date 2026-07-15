import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../routing/route_names.dart';
import '../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/health_article.dart';
import '../../domain/entities/health_category.dart';
import '../controllers/health_education_state.dart';
import '../providers/health_education_provider.dart';

class ArticleListPage extends ConsumerStatefulWidget {
  /// Optional pre-selected category passed via route arguments.
  final HealthCategory? initialCategory;

  const ArticleListPage({super.key, this.initialCategory});

  @override
  ConsumerState<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends ConsumerState<ArticleListPage> {
  final _searchCtrl  = TextEditingController();
  final _scrollCtrl  = ScrollController();
  bool  _searchFocus = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(healthEducationControllerProvider.notifier);
      notifier.loadArticles(categorySlug: widget.initialCategory?.slug);
    });
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(healthEducationControllerProvider.notifier).loadMoreArticles();
    }
  }

  void _openArticle(HealthArticle article) {
    ref.read(healthEducationControllerProvider.notifier).openArticle(article.id);
    Navigator.of(context).pushNamed(RouteNames.articleDetail, arguments: article);
  }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(healthEducationControllerProvider);
    final loading  = state.status == HealthEducationStatus.loading;
    final articles = state.isSearchActive
        ? state.searchResults
        : state.articleList.articles;
    final categories = state.dashboard.categories;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: NestedScrollView(
        controller: _scrollCtrl,
        headerSliverBuilder: (_, __) => [
          _buildAppBar(state),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildSearchBar(state),
                if (categories.isNotEmpty)
                  _buildCategoryFilter(categories, state.activeCategorySlug),
              ],
            ),
          ),
        ],
        body: loading && articles.isEmpty
            ? _buildShimmerList()
            : articles.isEmpty
                ? _buildEmpty(state)
                : _buildList(articles, state),
      ),
    );
  }

  // ── AppBar ───────────────────────────────────────────────────────────────

  SliverAppBar _buildAppBar(HealthEducationState state) {
    final category = state.activeCategorySlug != null
        ? state.dashboard.categories
            .where((c) => c.slug == state.activeCategorySlug)
            .firstOrNull
        : null;

    return SliverAppBar(
      backgroundColor: DesignTokens.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      floating: true,
      snap: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Text(
            category?.icon ?? '📚',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Text(
            category?.name ?? 'All Articles',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: DesignTokens.textStrong,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.bookmark_rounded, size: 22),
          color: DesignTokens.primary,
          onPressed: () =>
              Navigator.of(context).pushNamed(RouteNames.eduBookmarks),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Search bar ───────────────────────────────────────────────────────────

  Widget _buildSearchBar(HealthEducationState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: DesignTokens.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _searchFocus ? DesignTokens.primary : DesignTokens.border,
            width: _searchFocus ? 1.5 : 1.0,
          ),
          boxShadow: _searchFocus
              ? [
                  BoxShadow(
                    color: DesignTokens.primary.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(
              Icons.search_rounded,
              size: 20,
              color: _searchFocus
                  ? DesignTokens.primary
                  : DesignTokens.textMuted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Focus(
                onFocusChange: (f) => setState(() => _searchFocus = f),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(
                    fontSize: 14,
                    color: DesignTokens.textStrong,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search articles…',
                    hintStyle: TextStyle(
                        color: DesignTokens.textMuted, fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (q) {
                    final notifier =
                        ref.read(healthEducationControllerProvider.notifier);
                    q.isEmpty
                        ? notifier.clearSearch()
                        : notifier.searchArticles(q);
                  },
                ),
              ),
            ),
            if (state.isSearchActive)
              GestureDetector(
                onTap: () {
                  _searchCtrl.clear();
                  ref
                      .read(healthEducationControllerProvider.notifier)
                      .clearSearch();
                  FocusScope.of(context).unfocus();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.close_rounded,
                      size: 18, color: DesignTokens.textMuted),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Category filter chips ────────────────────────────────────────────────

  Widget _buildCategoryFilter(
      List<HealthCategory> categories, String? activeslug) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1, // +1 for "All"
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          if (i == 0) {
            final isAll = activeslug == null;
            return _FilterChip(
              label: 'All',
              icon: '📚',
              selected: isAll,
              color: DesignTokens.primary,
              onTap: () => ref
                  .read(healthEducationControllerProvider.notifier)
                  .filterByCategory(null),
            );
          }
          final cat = categories[i - 1];
          return _FilterChip(
            label: cat.name,
            icon: cat.icon ?? '📋',
            selected: activeslug == cat.slug,
            color: cat.color,
            onTap: () => ref
                .read(healthEducationControllerProvider.notifier)
                .filterByCategory(cat.slug),
          );
        },
      ),
    );
  }

  // ── Article list ─────────────────────────────────────────────────────────

  Widget _buildList(List<HealthArticle> articles, HealthEducationState state) {
    final hasMore = state.articleList.hasMore && !state.isSearchActive;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: articles.length + (hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        if (i == articles.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: DesignTokens.primary,
              ),
            ),
          );
        }
        final article = articles[i];
        return _ArticleCard(
          article: article,
          onTap: () => _openArticle(article),
        )
            .animate()
            .fadeIn(
                delay: Duration(milliseconds: 40 * i.clamp(0, 15)),
                duration: 280.ms)
            .slideY(begin: 0.04, end: 0);
      },
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmpty(HealthEducationState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            state.isSearchActive
                ? 'No results for "${state.searchQuery}"'
                : 'No articles found',
            style: const TextStyle(
              color: DesignTokens.textMuted,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try a different search or category',
            style: TextStyle(color: DesignTokens.textSubtle, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Shimmer ──────────────────────────────────────────────────────────────

  Widget _buildShimmerList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: DesignTokens.border,
        highlightColor: DesignTokens.borderMuted,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final String icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(colors: [color, color.withValues(alpha: 0.75)])
              : null,
          color: selected ? null : DesignTokens.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : DesignTokens.border,
            width: selected ? 0 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : DesignTokens.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Article Card ─────────────────────────────────────────────────────────────

class _ArticleCard extends StatelessWidget {
  final HealthArticle article;
  final VoidCallback onTap;

  const _ArticleCard({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = article.categoryColor != null
        ? Color(int.parse(
            'FF${article.categoryColor!.replaceAll('#', '')}',
            radix: 16))
        : DesignTokens.primary;

    return Material(
      color: DesignTokens.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji icon box
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.65)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(article.emoji ?? '📋',
                      style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            (article.categoryName ?? 'HEALTH').toUpperCase(),
                            style: TextStyle(
                              color: color,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (article.isFeatured)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: DesignTokens.yellow
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              '⭐ FEATURED',
                              style: TextStyle(
                                color: DesignTokens.yellow,
                                fontSize: 7.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: DesignTokens.textStrong,
                        letterSpacing: -0.2,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (article.summary != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        article.summary!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: DesignTokens.textMuted,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 11, color: color),
                        const SizedBox(width: 4),
                        Text(
                          '${article.readTimeMin} min read',
                          style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.visibility_outlined,
                            size: 11,
                            color: DesignTokens.textSubtle),
                        const SizedBox(width: 3),
                        Text(
                          '${article.viewCount}',
                          style: const TextStyle(
                              color: DesignTokens.textSubtle,
                              fontSize: 11,
                              fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        if (article.isBookmarked)
                          Icon(Icons.bookmark_rounded,
                              size: 15, color: color),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Read →',
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
