import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/health_article.dart';
import '../controllers/health_education_state.dart';
import '../providers/health_education_provider.dart';

class ArticleDetailPage extends ConsumerStatefulWidget {
  /// Passed via route arguments — used as a preview until full detail loads.
  final HealthArticle previewArticle;

  const ArticleDetailPage({super.key, required this.previewArticle});

  @override
  ConsumerState<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends ConsumerState<ArticleDetailPage> {
  final _scrollCtrl = ScrollController();
  final _tts        = FlutterTts();

  bool _ttsPlaying  = false;
  double _ttsRate   = 0.5;
  bool _showTtsBar  = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _scrollCtrl.addListener(_trackProgress);
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(_ttsRate);
    await _tts.setVolume(1.0);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _ttsPlaying = false);
    });
    _tts.setCancelHandler(() {
      if (mounted) setState(() => _ttsPlaying = false);
    });
  }

  void _trackProgress() {
    final article = _article;
    if (article == null) return;
    final max = _scrollCtrl.position.maxScrollExtent;
    if (max <= 0) return;
    final ratio = _scrollCtrl.position.pixels / max;
    final pos   = (_scrollCtrl.position.pixels).toInt();
    final done  = ratio > 0.95;
    ref.read(healthEducationControllerProvider.notifier)
        .trackProgress(article.id, pos, completed: done);
  }

  HealthArticle? get _article {
    final state = ref.read(healthEducationControllerProvider);
    return state.selectedArticle ?? widget.previewArticle;
  }

  Color _categoryColor(HealthArticle article) {
    if (article.categoryColor == null) return DesignTokens.primary;
    return Color(int.parse(
        'FF${article.categoryColor!.replaceAll('#', '')}', radix: 16));
  }

  // ── TTS ──────────────────────────────────────────────────────────────────

  Future<void> _toggleTts() async {
    final article = _article;
    if (article == null) return;
    if (_ttsPlaying) {
      await _tts.stop();
      setState(() => _ttsPlaying = false);
    } else {
      final text = (article.content ?? article.summary ?? article.title)
          .replaceAll(RegExp(r'#+\s'), '')
          .replaceAll(RegExp(r'\*\*|__|\*|_'), '')
          .replaceAll(RegExp(r'\|.*?\|'), '')
          .replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '');
      setState(() => _ttsPlaying = true);
      await _tts.speak(text);
    }
  }

  Future<void> _updateTtsRate(double rate) async {
    _ttsRate = rate;
    await _tts.setSpeechRate(rate);
    setState(() {});
  }

  @override
  void dispose() {
    _tts.stop();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state   = ref.watch(healthEducationControllerProvider);
    final article = state.selectedArticle ?? widget.previewArticle;
    final loading = state.detailLoading;
    final color   = _categoryColor(article);
    final isOff   = state.offlineIds.contains(article.id);

    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              _buildSliverAppBar(article, color, state),
              SliverToBoxAdapter(
                child: loading
                    ? _buildShimmer()
                    : _buildBody(article, color, isOff),
              ),
            ],
          ),
          if (_showTtsBar) _buildTtsBar(color),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(article, color, isOff, state),
    );
  }

  // ── Sliver AppBar ────────────────────────────────────────────────────────

  Widget _buildSliverAppBar(
      HealthArticle article, Color color, HealthEducationState state) {
    final isOff = state.offlineIds.contains(article.id);
    return SliverAppBar(
      backgroundColor: color,
      expandedHeight: 200,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 20, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        // Bookmark
        IconButton(
          icon: Icon(
            article.isBookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => ref
              .read(healthEducationControllerProvider.notifier)
              .toggleBookmark(article),
        ),
        // Offline download
        IconButton(
          icon: Icon(
            isOff
                ? Icons.download_done_rounded
                : Icons.download_for_offline_outlined,
            color: Colors.white,
            size: 22,
          ),
          tooltip: isOff ? 'Saved offline' : 'Save for offline',
          onPressed: () => ref
              .read(healthEducationControllerProvider.notifier)
              .toggleOffline(article),
        ),
        // Share
        IconButton(
          icon: const Icon(Icons.share_rounded,
              color: Colors.white, size: 22),
          onPressed: () => _shareArticle(article),
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color,
                color.withValues(alpha: 0.75),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (article.categoryName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        article.categoryName!.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                      height: 1.25,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 13, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        '${article.readTimeMin} min read',
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                      if (article.author != null) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.person_outline_rounded,
                            size: 13, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          article.author!,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Body ─────────────────────────────────────────────────────────────────

  Widget _buildBody(HealthArticle article, Color color, bool isOff) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tags
        if (article.tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: article.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: color.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ).animate().fadeIn(duration: 300.ms),

        // Offline badge
        if (isOff)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: DesignTokens.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: DesignTokens.green.withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download_done_rounded,
                      size: 14, color: DesignTokens.green),
                  SizedBox(width: 6),
                  Text(
                    'Available offline',
                    style: TextStyle(
                      color: DesignTokens.green,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Content
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: article.content != null
              ? MarkdownBody(
                  data: article.content!,
                  styleSheet: _markdownStyle(color),
                  selectable: true,
                )
              : Text(
                  article.summary ?? '',
                  style: const TextStyle(
                    color: DesignTokens.textStrong,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
        ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

        const SizedBox(height: 80), // bottom bar clearance
      ],
    );
  }

  MarkdownStyleSheet _markdownStyle(Color accent) {
    return MarkdownStyleSheet(
      h1: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: DesignTokens.textStrong,
        letterSpacing: -0.3,
        height: 1.3,
      ),
      h2: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: accent,
        letterSpacing: -0.2,
        height: 1.4,
      ),
      h3: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: DesignTokens.textStrong,
        height: 1.4,
      ),
      p: const TextStyle(
        fontSize: 14.5,
        color: DesignTokens.textStrong,
        height: 1.65,
        fontWeight: FontWeight.w400,
      ),
      strong: const TextStyle(
        fontWeight: FontWeight.w800,
        color: DesignTokens.textStrong,
      ),
      listBullet: TextStyle(
        fontSize: 14.5,
        color: accent,
        height: 1.65,
      ),
      tableHead: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 12.5,
        color: DesignTokens.textStrong,
      ),
      tableBody: const TextStyle(
        fontSize: 12.5,
        color: DesignTokens.textStrong,
        height: 1.5,
      ),
      tableBorder: TableBorder.all(
        color: DesignTokens.border,
        width: 1,
        borderRadius: BorderRadius.circular(8),
      ),
      blockquoteDecoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: accent, width: 3),
        ),
      ),
      codeblockDecoration: BoxDecoration(
        color: DesignTokens.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      horizontalRuleDecoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: DesignTokens.border, width: 1.5),
        ),
      ),
    );
  }

  // ── Bottom Action Bar ─────────────────────────────────────────────────────

  Widget _buildBottomBar(
    HealthArticle article,
    Color color,
    bool isOff,
    HealthEducationState state,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        border: const Border(
          top: BorderSide(color: DesignTokens.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // TTS button
          _BottomBtn(
            icon: _ttsPlaying
                ? Icons.pause_circle_filled_rounded
                : Icons.record_voice_over_rounded,
            label: _ttsPlaying ? 'Pause' : 'Listen',
            color: color,
            onTap: () {
              setState(() => _showTtsBar = !_showTtsBar);
              _toggleTts();
            },
          ),
          const SizedBox(width: 8),
          // Bookmark
          _BottomBtn(
            icon: article.isBookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            label: article.isBookmarked ? 'Saved' : 'Save',
            color: article.isBookmarked ? color : DesignTokens.textMuted,
            onTap: () => ref
                .read(healthEducationControllerProvider.notifier)
                .toggleBookmark(article),
          ),
          const SizedBox(width: 8),
          // Download
          _BottomBtn(
            icon: isOff
                ? Icons.download_done_rounded
                : Icons.download_for_offline_outlined,
            label: isOff ? 'Offline' : 'Download',
            color: isOff ? DesignTokens.green : DesignTokens.textMuted,
            onTap: () => ref
                .read(healthEducationControllerProvider.notifier)
                .toggleOffline(article),
          ),
          const SizedBox(width: 8),
          // Share
          _BottomBtn(
            icon: Icons.share_rounded,
            label: 'Share',
            color: DesignTokens.textMuted,
            onTap: () => _shareArticle(article),
          ),
        ],
      ),
    );
  }

  // ── TTS Speed Bar ─────────────────────────────────────────────────────────

  Widget _buildTtsBar(Color color) {
    return Positioned(
      bottom: 80,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: DesignTokens.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.speed_rounded, size: 16, color: color),
            const SizedBox(width: 8),
            const Text(
              'Speed',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: DesignTokens.textStrong),
            ),
            Expanded(
              child: Slider(
                value: _ttsRate,
                min: 0.25,
                max: 1.0,
                divisions: 3,
                activeColor: color,
                inactiveColor: color.withValues(alpha: 0.2),
                onChanged: _updateTtsRate,
              ),
            ),
            Text(
              '${_ttsRate}x',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _showTtsBar = false),
              child: const Icon(Icons.close_rounded,
                  size: 16, color: DesignTokens.textMuted),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0),
    );
  }

  // ── Shimmer ──────────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          8,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Shimmer.fromColors(
              baseColor: DesignTokens.border,
              highlightColor: DesignTokens.borderMuted,
              child: Container(
                height: i == 0 ? 24 : 16,
                width: i % 3 == 0
                    ? double.infinity
                    : MediaQuery.of(context).size.width * (0.5 + i * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Share ────────────────────────────────────────────────────────────────

  void _shareArticle(HealthArticle article) {
    final text =
        '📚 ${article.title}\n\n${article.summary ?? ''}\n\n— AI Healthcare Assistant for Rural Areas';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Article link copied to clipboard!',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: DesignTokens.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ─── Bottom Button Widget ─────────────────────────────────────────────────────

class _BottomBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BottomBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
