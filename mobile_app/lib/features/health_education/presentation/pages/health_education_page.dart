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

// ─── Palette used across this page ───────────────────────────────────────────
class _Palette {
  static const List<List<Color>> categoryGradients = [
    [Color(0xFFF97316), Color(0xFFFF6B35)], // orange  – Diseases
    [Color(0xFF2ECC8B), Color(0xFF10B981)], // green   – Nutrition
    [Color(0xFF4F94FF), Color(0xFF3B82F6)], // blue    – Vaccination
    [Color(0xFFE879A0), Color(0xFFEC4899)], // pink    – Maternal
    [Color(0xFFFFB829), Color(0xFFF59E0B)], // amber   – Child
    [Color(0xFF18C8C8), Color(0xFF06B6D4)], // teal    – Hygiene
    [Color(0xFF926EFF), Color(0xFF8B5CF6)], // violet  – Lifestyle
    [Color(0xFF7C3AED), Color(0xFF6D28D9)], // purple  – Mental
    [Color(0xFFEF4444), Color(0xFFDC2626)], // red     – Heart
    [Color(0xFFF43F5E), Color(0xFFE11D48)], // rose    – First Aid
    [Color(0xFFEC4899), Color(0xFFDB2777)], // fuchsia – Women
    [Color(0xFF0EA5E9), Color(0xFF0284C7)], // sky     – Eye/Ear
  ];

  static List<Color> gradientForIndex(int i) =>
      categoryGradients[i % categoryGradients.length];

  // Hero strip chips
  static const List<Map<String, dynamic>> quickFacts = [
    {'emoji': '🩺', 'label': '25 Articles', 'color': Color(0xFFF97316)},
    {'emoji': '📂', 'label': '12 Topics',   'color': Color(0xFF4F94FF)},
    {'emoji': '🌍', 'label': 'WHO Sourced', 'color': Color(0xFF2ECC8B)},
    {'emoji': '📴', 'label': 'Offline Ready', 'color': Color(0xFF926EFF)},
    {'emoji': '🔊', 'label': 'Listen Mode', 'color': Color(0xFFE879A0)},
  ];
}

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
    Navigator.of(context)
        .pushNamed(RouteNames.articleDetail, arguments: article);
  }

  void _openArticleList(BuildContext context, {HealthCategory? category}) {
    Navigator.of(context)
        .pushNamed(RouteNames.articleList, arguments: category);
  }

  @override
  Widget build(BuildContext context) {
    final state     = ref.watch(healthEducationControllerProvider);
    final isLoading = state.status == HealthEducationStatus.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
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
                    _buildHeroBanner(context, state),
                    _buildQuickFactsStrip(),
                    _buildCategoriesGrid(context, state, isLoading),
                    _buildFeaturedSection(context, state, isLoading),
                    _buildHealthTipCard(),
                    _buildRecommendedSection(context, state, isLoading),
                    if (state.dashboard.recentArticles.isNotEmpty)
                      _buildRecentSection(context, state),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sliver AppBar ──────────────────────────────────────────────────────────

  Widget _buildSliverAppBar(BuildContext context, HealthEducationState state) {
    return SliverAppBar(
      backgroundColor: const Color(0xFFF7F8FC),
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
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF926EFF), Color(0xFF4F94FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Center(
              child: Text('📚', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Health Education',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1D2E),
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

  // ── Search bar ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext context, HealthEducationState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _searchFocused
                ? DesignTokens.primary
                : const Color(0xFFE4E7F0),
            width: _searchFocused ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _searchFocused
                  ? DesignTokens.primary.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: _searchFocused ? 14 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(
              Icons.search_rounded,
              size: 20,
              color: _searchFocused
                  ? DesignTokens.primary
                  : const Color(0xFFAAB0C4),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Focus(
                onFocusChange: (f) => setState(() => _searchFocused = f),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1D2E),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search diseases, nutrition, vaccines…',
                    hintStyle: TextStyle(
                        color: Color(0xFFAAB0C4), fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (q) {
                    final n = ref.read(healthEducationControllerProvider.notifier);
                    q.isEmpty ? n.clearSearch() : n.searchArticles(q);
                  },
                ),
              ),
            ),
            if (state.isSearchActive)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  ref.read(healthEducationControllerProvider.notifier).clearSearch();
                  FocusScope.of(context).unfocus();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.close_rounded,
                      size: 18, color: Color(0xFFAAB0C4)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Hero Banner ────────────────────────────────────────────────────────────

  Widget _buildHeroBanner(BuildContext context, HealthEducationState state) {
    final articleCount = state.dashboard.featuredArticles.isEmpty
        ? 25
        : state.dashboard.recommendedArticles.length +
            state.dashboard.featuredArticles.length;
    final topicCount = state.dashboard.categories.isEmpty
        ? 12
        : state.dashboard.categories.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      // No fixed height — let content determine size, avoids overflow
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B47E8), Color(0xFF3E84F8), Color(0xFF18C8C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B47E8).withValues(alpha: 0.40),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Decorative circles — purely visual, don't affect layout
            Positioned(
              top: -30, right: -30,
              child: Container(
                width: 130, height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -40, left: 100,
              child: Container(
                width: 160, height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            // Content — IntrinsicHeight lets the banner size itself
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left column
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '🩺 WHO Evidence-Based',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Title
                        const Text(
                          'Learn &\nStay Healthy',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Subtitle
                        const Text(
                          'Evidence-based health education\nfor every family',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11.5,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        // CTA button — fixed size, no Spacer needed
                        GestureDetector(
                          onTap: () => _openArticleList(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Browse All Articles →',
                              style: TextStyle(
                                color: Color(0xFF6B47E8),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Right column — hospital icon + stat pills
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 68, height: 68,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('🏥', style: TextStyle(fontSize: 34)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _statPill('$articleCount Articles'),
                      const SizedBox(height: 5),
                      _statPill('$topicCount Topics'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0);
  }

  Widget _statPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ── Quick Facts Strip ──────────────────────────────────────────────────────

  Widget _buildQuickFactsStrip() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: _Palette.quickFacts.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final fact = _Palette.quickFacts[i];
            final color = fact['color'] as Color;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(fact['emoji'] as String,
                      style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 5),
                  Text(
                    fact['label'] as String,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(
                delay: Duration(milliseconds: 60 * i), duration: 280.ms);
          },
        ),
      ),
    );
  }

  // ── Categories Grid ────────────────────────────────────────────────────────

  Widget _buildCategoriesGrid(
      BuildContext context, HealthEducationState state, bool loading) {
    final cats = state.dashboard.categories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Health Topics', onTap: () => _openArticleList(context)),
        loading
            ? _shimmerGrid()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.90,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: cats.length,
                  itemBuilder: (_, i) {
                    final cat = cats[i];
                    final gradient = _Palette.gradientForIndex(i);
                    return _CategoryTile(
                      category: cat,
                      gradient: gradient,
                      index: i,
                      onTap: () => _openArticleList(context, category: cat),
                    ).animate().fadeIn(
                        delay: Duration(milliseconds: 50 * i),
                        duration: 300.ms)
                        .scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1),
                               duration: 300.ms, curve: Curves.easeOutBack);
                  },
                ),
              ),
      ],
    );
  }

  // ── Featured Section ───────────────────────────────────────────────────────

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
          height: 218,
          child: loading
              ? _shimmerRow(width: 230, height: 206, count: 4)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  scrollDirection: Axis.horizontal,
                  itemCount: articles.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _FeaturedCard(
                    article: articles[i],
                    index: i,
                    onTap: () => _openArticle(context, articles[i]),
                  ).animate().fadeIn(
                      delay: Duration(milliseconds: 80 * i), duration: 350.ms),
                ),
        ),
      ],
    );
  }

  // ── Health Tip Card ────────────────────────────────────────────────────────

  Widget _buildHealthTipCard() {
    const tips = [
      {'emoji': '💧', 'tip': 'Drink 8–10 glasses of water daily to stay hydrated and flush toxins.', 'color': Color(0xFF18C8C8)},
      {'emoji': '🥗', 'tip': 'Fill half your plate with vegetables and fruits at every meal.', 'color': Color(0xFF2ECC8B)},
      {'emoji': '🚶', 'tip': '30 minutes of brisk walking daily can reduce heart disease risk by 35%.', 'color': Color(0xFFF97316)},
      {'emoji': '😴', 'tip': '7–9 hours of quality sleep boosts immunity and prevents chronic disease.', 'color': Color(0xFF926EFF)},
      {'emoji': '🧼', 'tip': 'Washing hands for 20 seconds prevents 40% of diarrhoeal disease.', 'color': Color(0xFF4F94FF)},
    ];
    final tip = tips[DateTime.now().day % tips.length];
    final color = tip['color'] as Color;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(tip['emoji'] as String,
                  style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Tip of the Day',
                  style: TextStyle(
                    color: color,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tip['tip'] as String,
                  style: const TextStyle(
                    color: Color(0xFF1A1D2E),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 350.ms).slideX(begin: 0.05, end: 0);
  }

  // ── Recommended Section ────────────────────────────────────────────────────

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
            ? _shimmerList(count: 5)
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                itemCount: articles.length.clamp(0, 8),
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _ArticleListCard(
                  article: articles[i],
                  index: i,
                  onTap: () => _openArticle(context, articles[i]),
                ).animate().fadeIn(
                    delay: Duration(milliseconds: 50 * i), duration: 280.ms),
              ),
      ],
    );
  }

  // ── Recent Section ─────────────────────────────────────────────────────────

  Widget _buildRecentSection(BuildContext context, HealthEducationState state) {
    final articles = state.dashboard.recentArticles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Continue Reading'),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          itemCount: articles.length.clamp(0, 3),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _ArticleListCard(
            article: articles[i],
            index: i,
            onTap: () => _openArticle(context, articles[i]),
            showProgress: true,
          ),
        ),
      ],
    );
  }

  // ── Search Results ─────────────────────────────────────────────────────────

  Widget _buildSearchResults(BuildContext context, HealthEducationState state) {
    if (state.status == HealthEducationStatus.searching) {
      return _shimmerList(count: 5);
    }
    if (state.searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 56),
        child: Center(
          child: Column(
            children: [
              const Text('🔍', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 14),
              Text(
                'No results for "${state.searchQuery}"',
                style: const TextStyle(
                  color: Color(0xFF8890AA),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Try different keywords',
                style: TextStyle(color: Color(0xFFAAB0C4), fontSize: 13),
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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            '${state.searchResults.length} results for "${state.searchQuery}"',
            style: const TextStyle(
              color: Color(0xFF8890AA),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: state.searchResults.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _ArticleListCard(
            article: state.searchResults[i],
            index: i,
            onTap: () => _openArticle(context, state.searchResults[i]),
          ).animate().fadeIn(
              delay: Duration(milliseconds: 40 * i), duration: 240.ms),
        ),
      ],
    );
  }

  // ── Shared helpers ─────────────────────────────────────────────────────────

  Widget _sectionHeader(String title, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1D2E),
              letterSpacing: -0.4,
            ),
          ),
          if (onTap != null)
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: DesignTokens.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'See All →',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _shimmerGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.90,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 8,
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: const Color(0xFFE8EAED),
          highlightColor: const Color(0xFFF4F5F7),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _shimmerRow(
      {required double width, required double height, required int count}) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: const Color(0xFFE8EAED),
        highlightColor: const Color(0xFFF4F5F7),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _shimmerList({required int count}) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: const Color(0xFFE8EAED),
        highlightColor: const Color(0xFFF4F5F7),
        child: Container(
          height: 94,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

// ─── Category Tile ────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final HealthCategory category;
  final List<Color> gradient;
  final int index;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.gradient,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withValues(alpha: 0.14),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withValues(alpha: 0.30),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  category.icon ?? '📋',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                category.name,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1D2E),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
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
  final int index;
  final VoidCallback onTap;

  const _FeaturedCard({
    required this.article,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Build gradient from category color + a shifted hue
    final baseColor = article.categoryColor != null
        ? Color(int.parse(
            'FF${article.categoryColor!.replaceAll('#', '')}', radix: 16))
        : DesignTokens.primary;
    // Create a complementary second color by shifting hue
    final hsl = HSLColor.fromColor(baseColor);
    final secondColor = hsl
        .withHue((hsl.hue + 30) % 360)
        .withSaturation((hsl.saturation * 0.85).clamp(0.0, 1.0))
        .toColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 230,
        height: 206, // explicit height so Spacer works correctly
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [baseColor, secondColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.40),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Decorative background circle
            Positioned(
              top: -20, right: -20,
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -30, left: -10,
              child: Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            // Actual content
            Padding(
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
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          (article.categoryName ?? 'HEALTH').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Text(article.emoji ?? '📋',
                          style: const TextStyle(fontSize: 26)),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    article.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule_rounded,
                                size: 10, color: Colors.white),
                            const SizedBox(width: 3),
                            Text(
                              '${article.readTimeMin} min read',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.arrow_forward_rounded,
                              size: 14, color: Colors.white),
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
    );
  }
}

// ─── Article List Card ────────────────────────────────────────────────────────

class _ArticleListCard extends StatelessWidget {
  final HealthArticle article;
  final int index;
  final VoidCallback onTap;
  final bool showProgress;

  const _ArticleListCard({
    required this.article,
    required this.index,
    required this.onTap,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = article.categoryColor != null
        ? Color(int.parse(
            'FF${article.categoryColor!.replaceAll('#', '')}', radix: 16))
        : DesignTokens.primary;
    final hsl = HSLColor.fromColor(baseColor);
    final secondColor = hsl
        .withHue((hsl.hue + 25) % 360)
        .withSaturation((hsl.saturation * 0.85).clamp(0.0, 1.0))
        .toColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: baseColor.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon container
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [baseColor, secondColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: baseColor.withValues(alpha: 0.32),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  article.emoji ?? '📋',
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: baseColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            (article.categoryName ?? 'HEALTH').toUpperCase(),
                            style: TextStyle(
                              color: baseColor,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (article.isBookmarked) ...[
                        const SizedBox(width: 5),
                        Icon(Icons.bookmark_rounded,
                            size: 12, color: baseColor),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1D2E),
                      letterSpacing: -0.2,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 11, color: Color(0xFFAAB0C4)),
                      const SizedBox(width: 3),
                      Text(
                        '${article.readTimeMin} min read',
                        style: const TextStyle(
                          color: Color(0xFFAAB0C4),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: baseColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Read →',
                          style: TextStyle(
                            color: baseColor,
                            fontSize: 10.5,
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
    );
  }
}
