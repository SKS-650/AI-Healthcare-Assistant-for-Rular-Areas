import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../routing/route_names.dart';
import '../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/health_article.dart';
import '../controllers/health_education_state.dart';
import '../providers/health_education_provider.dart';

class BookmarksPage extends ConsumerStatefulWidget {
  const BookmarksPage({super.key});

  @override
  ConsumerState<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends ConsumerState<BookmarksPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl =
      TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthEducationControllerProvider.notifier).loadBookmarks();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _openArticle(HealthArticle article) {
    ref.read(healthEducationControllerProvider.notifier).openArticle(article.id);
    Navigator.of(context)
        .pushNamed(RouteNames.articleDetail, arguments: article);
  }

  @override
  Widget build(BuildContext context) {
    final state   = ref.watch(healthEducationControllerProvider);
    final loading = state.status == HealthEducationStatus.loading;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [_buildAppBar()],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            // ── Bookmarks tab ──────────────────────────────────────────────
            _buildBookmarkTab(state, loading),
            // ── Offline tab ────────────────────────────────────────────────
            _buildOfflineTab(state, loading),
          ],
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: DesignTokens.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Row(
        children: [
          Text('🔖', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Text(
            'Saved Articles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: DesignTokens.textStrong,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      bottom: TabBar(
        controller: _tabCtrl,
        labelColor: DesignTokens.primary,
        unselectedLabelColor: DesignTokens.textMuted,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        indicatorColor: DesignTokens.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: DesignTokens.border,
        tabs: const [
          Tab(text: '🔖  Bookmarks'),
          Tab(text: '📥  Offline'),
        ],
      ),
    );
  }

  // ── Bookmarks tab ─────────────────────────────────────────────────────────

  Widget _buildBookmarkTab(HealthEducationState state, bool loading) {
    if (loading && state.bookmarks.isEmpty) return _shimmerList();

    if (state.bookmarks.isEmpty) {
      return _emptyState(
        emoji: '🔖',
        title: 'No bookmarks yet',
        subtitle: 'Tap the bookmark icon on any article to save it here.',
        action: 'Browse Articles',
        onAction: () =>
            Navigator.of(context).pushNamed(RouteNames.articleList),
      );
    }

    return RefreshIndicator(
      color: DesignTokens.primary,
      onRefresh: () =>
          ref.read(healthEducationControllerProvider.notifier).loadBookmarks(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        itemCount: state.bookmarks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final article = state.bookmarks[i];
          return _ArticleCard(
            article: article,
            onTap: () => _openArticle(article),
            trailing: IconButton(
              icon: const Icon(Icons.bookmark_remove_rounded,
                  color: DesignTokens.danger, size: 20),
              tooltip: 'Remove bookmark',
              onPressed: () => ref
                  .read(healthEducationControllerProvider.notifier)
                  .toggleBookmark(article),
            ),
          ).animate().fadeIn(
              delay: Duration(milliseconds: 50 * i), duration: 280.ms);
        },
      ),
    );
  }

  // ── Offline tab ───────────────────────────────────────────────────────────

  Widget _buildOfflineTab(HealthEducationState state, bool loading) {
    if (loading && state.offlineArticles.isEmpty) return _shimmerList();

    if (state.offlineArticles.isEmpty) {
      return _emptyState(
        emoji: '📥',
        title: 'No offline articles',
        subtitle:
            'Download articles to read them without internet connection.',
        action: 'Browse Articles',
        onAction: () =>
            Navigator.of(context).pushNamed(RouteNames.articleList),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: state.offlineArticles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final article = state.offlineArticles[i];
        return _ArticleCard(
          article: article,
          onTap: () => _openArticle(article),
          badge: _OfflineBadge(),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: DesignTokens.danger, size: 20),
            tooltip: 'Remove from offline',
            onPressed: () => ref
                .read(healthEducationControllerProvider.notifier)
                .toggleOffline(article),
          ),
        ).animate().fadeIn(
            delay: Duration(milliseconds: 50 * i), duration: 280.ms);
      },
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _emptyState({
    required String emoji,
    required String title,
    required String subtitle,
    required String action,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 56))
                .animate()
                .scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textStrong,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: DesignTokens.textMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: DesignTokens.purpleGradient,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: DesignTokens.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  action,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: DesignTokens.border,
        highlightColor: DesignTokens.borderMuted,
        child: Container(
          height: 96,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

// ─── Offline Badge ────────────────────────────────────────────────────────────

class _OfflineBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: DesignTokens.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: DesignTokens.green.withValues(alpha: 0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.download_done_rounded,
              size: 10, color: DesignTokens.green),
          SizedBox(width: 4),
          Text(
            'OFFLINE',
            style: TextStyle(
              color: DesignTokens.green,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Article Card ─────────────────────────────────────────────────────────────

class _ArticleCard extends StatelessWidget {
  final HealthArticle article;
  final VoidCallback onTap;
  final Widget? trailing;
  final Widget? badge;

  const _ArticleCard({
    required this.article,
    required this.onTap,
    this.trailing,
    this.badge,
  });

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
          padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.65)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
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
                      style: const TextStyle(fontSize: 24)),
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
                        if (badge != null) ...[
                          const SizedBox(width: 6),
                          badge!,
                        ],
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
                    const SizedBox(height: 5),
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
                      ],
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
