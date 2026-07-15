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

class HealthEducationPage extends ConsumerStatefulWidget {
  const HealthEducationPage({super.key});

  @override
  ConsumerState<HealthEducationPage> createState() =>
      _HealthEducationPageState();
}

class _HealthEducationPageState extends ConsumerState<HealthEducationPage> {
  final _searchController = TextEditingController();
  bool _searchFocused = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openArticle(BuildContext context, HealthArticle article) {
    ref.read(healthEducationControllerProvider.notifier).openArticle(article.id);
    Navigator.of(context).pushNamed(
      RouteNames.articleDetail,
      arguments: article,
    );
  }

  void _openArticleList(BuildContext context, {HealthCategory? category}) {
    Navigator.of(context).pushNamed(
      RouteNames.articleList,
      arguments: category,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(healthEducationControllerProvider);
    final isLoading = state.status == HealthEducationStatus.loading;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: RefreshIndicator(
        color: DesignTokens.primary,
        onRefresh: () =>
            ref.read(healthEducationControllerProvider.notifier).loadDashboard(),
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context, state),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(context, state),
                  if (state.isSearchActive)
                    _buildSearchResults(context, state)
                  else ...[
                    _buildHeroBanner(),
                    _buildCategories(context, state, isLoading),
                    _buildFeaturedSection(context, state, isLoading),
                    _buildRecommendedSection(context, state, isLoading),
                    if (state.dashboard.recentArticles.isNotEmpty)
                      _buildRecentSection(context, state),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sliver AppBar ────────────────────────────────────────────────────────

  Widget _buildSliverAppBar(BuildContext context, HealthEducationState state) {
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
      title: const Row(
        children: [
          Text('📚', style: TextStyle(fontSize: 22)),
          SizedBox(width: 8),
          Text(
            'Health Education',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: DesignTokens.textStrong,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.bookmark_rounded, size: 22),
          color: DesignTokens.primary,
          tooltip: 'Bookmarks',
          onPressed: () =>
              Navigator.of(context).pushNamed(RouteNames.eduBookmarks),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Search bar ───────────────────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext context, HealthEducationState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: DesignTokens.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _searchFocused
                ? DesignTokens.primary
                : DesignTokens.border,
            width: _searchFocused ? 1.5 : 1.0,
          ),
          boxShadow: _searchFocused
              ? [
                  BoxShadow(
                    color: DesignTokens.primary.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.search_rounded,
                size: 20,
                color: _searchFocused
                    ? DesignTokens.primary
                    : DesignTokens.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Focus(
                onFocusChange: (f) => setState(() => _searchFocused = f),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    fontSize: 14,
                    color: DesignTokens.textStrong,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search diseases, nutrition, vaccines…',
                    hintStyle: TextStyle(
                        color: DesignTokens.textMuted, fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (q) {
                    if (q.isEmpty) {
                      ref
                          .read(healthEducationControllerProvider.notifier)
                          .clearSearch();
                    } else {
                      ref
                          .read(healthEducationControllerProvider.notifier)
                          .searchArticles(q);
                    }
                  },
                ),
              ),
            ),
            if (state.isSearchActive)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
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

  // ── Hero banner ──────────────────────────────────────────────────────────

  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B47E8), Color(0xFF4F94FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Learn & Stay Healthy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Evidence-based health education for rural communities',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    '📖 Browse Articles',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Text('🏥', style: TextStyle(fontSize: 54)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  // ── Categories ───────────────────────────────────────────────────────────

  Widget _buildCategories(
      BuildContext context, HealthEducationState state, bool loading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Health Topics', onTap: () => _openArticleList(context)),
        SizedBox(
          height: 100,
          child: loading
              ? _shimmerRow(width: 80, height: 88, count: 6)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.dashboard.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final cat = state.dashboard.categories[i];
                    return _CategoryChip(
                      category: cat,
                      onTap: () =>
                          _openArticleList(context, category: cat),
                    ).animate().fadeIn(
                        delay: Duration(milliseconds: 60 * i),
                        duration: 300.ms);
                  },
                ),
        ),
      ],
    );
  }

  // ── Featured ─────────────────────────────────────────────────────────────

  Widget _buildFeaturedSection(
      BuildContext context, HealthEducationState state, bool loading) {
    final articles = state.dashboard.featuredArticles;
    if (!loading && articles.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Featured Articles',
            onTap: () => _openArticleList(context)),
        SizedBox(
          height: 210,
          child: loading
              ? _shimmerRow(width: 220, height: 200, count: 3)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: articles.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _FeaturedCard(
                    article: articles[i],
                    onTap: () => _openArticle(context, articles[i]),
                  ).animate().fadeIn(
                      delay: Duration(milliseconds: 80 * i),
                      duration: 350.ms),
                ),
        ),
      ],
    );
  }

  // ── Recommended ──────────────────────────────────────────────────────────

  Widget _buildRecommendedSection(
      BuildContext context, HealthEducationState state, bool loading) {
    final articles = state.dashboard.recommendedArticles;
    if (!loading && articles.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Recommended For You',
            onTap: () => _openArticleList(context)),
        loading
            ? _shimmerList(count: 4)
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                itemCount: articles.length.clamp(0, 6),
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 10),
                itemBuilder: (_, i) => _ArticleListCard(
                  article: articles[i],
                  onTap: () => _openArticle(context, articles[i]),
                ).animate().fadeIn(
                    delay: Duration(milliseconds: 60 * i),
                    duration: 300.ms),
              ),
      ],
    );
  }

  // ── Recent ───────────────────────────────────────────────────────────────

  Widget _buildRecentSection(
      BuildContext context, HealthEducationState state) {
    final articles = state.dashboard.recentArticles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Continue Reading'),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: articles.length.clamp(0, 3),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _ArticleListCard(
            article: articles[i],
            onTap: () => _openArticle(context, articles[i]),
            showProgress: true,
          ),
        ),
      ],
    );
  }

  // ── Search results ───────────────────────────────────────────────────────

  Widget _buildSearchResults(
      BuildContext context, HealthEducationState state) {
    if (state.status == HealthEducationStatus.searching) {
      return _shimmerList(count: 5);
    }
    if (state.searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Column(
            children: [
              const Text('🔍', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(
                'No results for "${state.searchQuery}"',
                style: const TextStyle(
                  color: DesignTokens.textMuted,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            '${state.searchResults.length} results for "${state.searchQuery}"',
            style: const TextStyle(
              color: DesignTokens.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: state.searchResults.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _ArticleListCard(
            article: state.searchResults[i],
            onTap: () => _openArticle(context, state.searchResults[i]),
          ).animate().fadeIn(
              delay: Duration(milliseconds: 40 * i), duration: 250.ms),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _sectionHeader(String title, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: DesignTokens.textStrong,
              letterSpacing: -0.3,
            ),
          ),
          if (onTap != null)
            GestureDetector(
              onTap: onTap,
              child: const Text(
                'See All →',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: DesignTokens.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _shimmerRow(
      {required double width,
      required double height,
      required int count}) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: DesignTokens.border,
        highlightColor: DesignTokens.borderMuted,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _shimmerList({required int count}) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: DesignTokens.border,
        highlightColor: DesignTokens.borderMuted,
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// ─── Category Chip ────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final HealthCategory category;
  final VoidCallback onTap;
  const _CategoryChip({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = category.color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        decoration: BoxDecoration(
          color: DesignTokens.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(category.icon ?? '📋',
                    style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: DesignTokens.textStrong,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Featured Card ────────────────────────────────────────────────────────────

class _FeaturedCard extends StatelessWidget {
  final HealthArticle article;
  final VoidCallback onTap;
  const _FeaturedCard({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = article.categoryColor != null
        ? Color(int.parse(
            'FF${article.categoryColor!.replaceAll('#', '')}',
            radix: 16))
        : DesignTokens.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.9), color.withValues(alpha: 0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    article.categoryName?.toUpperCase() ?? 'HEALTH',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Text(article.emoji ?? '📋',
                    style: const TextStyle(fontSize: 22)),
              ],
            ),
            const Spacer(),
            Text(
              article.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    size: 11, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  '${article.readTimeMin} min read',
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (article.isBookmarked)
                  const Icon(Icons.bookmark_rounded,
                      size: 14, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Article List Card ────────────────────────────────────────────────────────

class _ArticleListCard extends StatelessWidget {
  final HealthArticle article;
  final VoidCallback onTap;
  final bool showProgress;
  const _ArticleListCard({
    required this.article,
    required this.onTap,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = article.categoryColor != null
        ? Color(int.parse(
            'FF${article.categoryColor!.replaceAll('#', '')}',
            radix: 16))
        : DesignTokens.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: DesignTokens.surface,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: color.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(article.emoji ?? '📋',
                      style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
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
                            article.categoryName?.toUpperCase() ??
                                'HEALTH',
                            style: TextStyle(
                              color: color,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (article.isBookmarked)
                          Icon(Icons.bookmark_rounded,
                              size: 14, color: color),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        color: DesignTokens.textStrong,
                        letterSpacing: -0.2,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 11, color: color),
                        const SizedBox(width: 4),
                        Text(
                          '${article.readTimeMin} min read',
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            showProgress ? 'Continue →' : 'Read →',
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
