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
  final HealthArticle previewArticle;
  const ArticleDetailPage({super.key, required this.previewArticle});

  @override
  ConsumerState<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends ConsumerState<ArticleDetailPage> {
  final _scrollCtrl = ScrollController();
  final _tts        = FlutterTts();

  bool   _ttsPlaying   = false;
  double _ttsRate      = 0.5;
  bool   _showTtsBar   = false;
  double _readProgress = 0.0; // 0..1

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

  int _lastTrackedPos = 0;

  void _trackProgress() {
    final article = _article;
    if (article == null) return;
    final max = _scrollCtrl.position.maxScrollExtent;
    if (max <= 0) return;
    final pixels = _scrollCtrl.position.pixels;
    final ratio  = (pixels / max).clamp(0.0, 1.0);
    if ((ratio - _readProgress).abs() > 0.01) {
      setState(() => _readProgress = ratio);
    }
    // Only call the notifier every 50px to avoid excessive state updates
    final pos  = pixels.toInt();
    if ((pos - _lastTrackedPos).abs() < 50 && ratio < 0.95) return;
    _lastTrackedPos = pos;
    final done = ratio > 0.95;
    ref
        .read(healthEducationControllerProvider.notifier)
        .trackProgress(article.id, pos, completed: done);
  }

  HealthArticle? get _article {
    final state = ref.read(healthEducationControllerProvider);
    return state.selectedArticle ?? widget.previewArticle;
  }

  Color _categoryColor(HealthArticle article) {
    if (article.categoryColor == null) return DesignTokens.primary;
    return Color(
        int.parse('FF${article.categoryColor!.replaceAll('#', '')}', radix: 16));
  }

  Color _secondColor(Color base) {
    final hsl = HSLColor.fromColor(base);
    return hsl
        .withHue((hsl.hue + 30) % 360)
        .withSaturation((hsl.saturation * 0.85).clamp(0.0, 1.0))
        .toColor();
  }

  // ── TTS ────────────────────────────────────────────────────────────────────

  Future<void> _toggleTts() async {
    final article = _article;
    if (article == null) return;
    if (_ttsPlaying) {
      await _tts.stop();
      setState(() => _ttsPlaying = false);
    } else {
      final raw = article.content ?? article.summary ?? article.title;
      final text = raw
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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state   = ref.watch(healthEducationControllerProvider);
    final article = state.selectedArticle ?? widget.previewArticle;
    final loading = state.detailLoading;
    final color   = _categoryColor(article);
    final color2  = _secondColor(color);
    final isOff   = state.offlineIds.contains(article.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              _buildSliverAppBar(article, color, color2, state),
              SliverToBoxAdapter(
                child: loading
                    ? _buildShimmer()
                    : _buildBody(article, color, color2, isOff),
              ),
            ],
          ),
          // Reading progress bar — sits just below the status bar
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0, right: 0,
            child: _ReadingProgressBar(
              progress: _readProgress,
              color: color,
            ),
          ),
          if (_showTtsBar) _buildTtsBar(color),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(article, color, isOff, state),
    );
  }

  // ── Sliver AppBar ──────────────────────────────────────────────────────────

  Widget _buildSliverAppBar(HealthArticle article, Color color, Color color2,
      HealthEducationState state) {
    final isOff = state.offlineIds.contains(article.id);
    return SliverAppBar(
      backgroundColor: color,
      expandedHeight: 210,
      pinned: true,
      stretch: false,
      leading: IconButton(
        icon: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 16, color: Colors.white),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        _AppBarAction(
          icon: article.isBookmarked
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          onTap: () => ref
              .read(healthEducationControllerProvider.notifier)
              .toggleBookmark(article),
        ),
        _AppBarAction(
          icon: isOff
              ? Icons.download_done_rounded
              : Icons.download_for_offline_outlined,
          onTap: () => ref
              .read(healthEducationControllerProvider.notifier)
              .toggleOffline(article),
        ),
        _AppBarAction(
          icon: Icons.share_rounded,
          onTap: () => _shareArticle(article),
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Decorative blobs
              Positioned(
                top: -40, right: -40,
                child: Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Positioned(
                bottom: -30, left: -20,
                child: Container(
                  width: 130, height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              // Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 56, 20, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Category + Emoji row
                      Row(
                        children: [
                          if (article.categoryName != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                article.categoryName!.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          const Spacer(),
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Center(
                              child: Text(
                                article.emoji ?? '📋',
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Title
                      Text(
                        article.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                          height: 1.25,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // Meta row
                      Row(
                        children: [
                          _MetaPill(
                              icon: Icons.schedule_rounded,
                              label: '${article.readTimeMin} min read'),
                          const SizedBox(width: 8),
                          if (article.source != null)
                            _MetaPill(
                                icon: Icons.verified_rounded,
                                label: article.source!),
                          if (article.author != null &&
                              article.source == null)
                            _MetaPill(
                                icon: Icons.person_outline_rounded,
                                label: article.author!),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildBody(
      HealthArticle article, Color color, Color color2, bool isOff) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reading progress summary strip
        _buildProgressStrip(color),
        // Tags
        if (article.tags.isNotEmpty)
          _buildTags(article, color),
        // Badges row
        _buildBadgesRow(article, color, isOff),
        // Summary highlight card (if available)
        if (article.summary != null)
          _buildSummaryCard(article.summary!, color, color2),
        // Article content
        _buildContent(article, color),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildProgressStrip(Color color) {
    final pct = (_readProgress * 100).toInt();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _readProgress,
                minHeight: 5,
                backgroundColor: color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$pct% read',
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags(HealthArticle article, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Wrap(
        spacing: 7,
        runSpacing: 6,
        children: article.tags.map((tag) {
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.22)),
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
    ).animate().fadeIn(duration: 280.ms);
  }

  Widget _buildBadgesRow(
      HealthArticle article, Color color, bool isOff) {
    final badges = <Widget>[];
    if (article.isFeatured) {
      badges.add(const _Badge(
          icon: Icons.star_rounded,
          label: 'Featured',
          color: Color(0xFFFFB829)));
    }
    if (isOff) {
      badges.add(const _Badge(
          icon: Icons.download_done_rounded,
          label: 'Offline Ready',
          color: DesignTokens.green));
    }
    if (article.isBookmarked) {
      badges.add(_Badge(
          icon: Icons.bookmark_rounded,
          label: 'Bookmarked',
          color: color));
    }
    if (badges.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Wrap(spacing: 8, children: badges),
    );
  }

  Widget _buildSummaryCard(
      String summary, Color color, Color color2) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.10),
            color2.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3)),
              ],
            ),
            child: const Center(
              child: Icon(Icons.info_outline_rounded,
                  size: 18, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick Summary',
                    style: TextStyle(
                      color: color,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    )),
                const SizedBox(height: 4),
                Text(
                  summary,
                  style: const TextStyle(
                    color: Color(0xFF3D4154),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 80.ms, duration: 320.ms);
  }

  Widget _buildContent(HealthArticle article, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: article.content != null
          ? MarkdownBody(
              data: article.content!,
              styleSheet: _markdownStyle(color),
              selectable: true,
            )
          : Text(
              article.summary ?? '',
              style: const TextStyle(
                color: Color(0xFF1A1D2E),
                fontSize: 15,
                height: 1.65,
              ),
            ),
    ).animate().fadeIn(delay: 120.ms, duration: 400.ms);
  }

  // ── Markdown Style ─────────────────────────────────────────────────────────

  MarkdownStyleSheet _markdownStyle(Color accent) {
    final light = accent.withValues(alpha: 0.08);
    return MarkdownStyleSheet(
      h1: TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w900,
        color: accent,
        letterSpacing: -0.4,
        height: 1.3,
      ),
      h2: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: accent,
        letterSpacing: -0.2,
        height: 1.5,
      ),
      h3: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1D2E),
        height: 1.45,
      ),
      p: const TextStyle(
        fontSize: 14.5,
        color: Color(0xFF3D4154),
        height: 1.70,
        fontWeight: FontWeight.w400,
      ),
      strong: TextStyle(
        fontWeight: FontWeight.w800,
        color: accent,
      ),
      em: TextStyle(
        fontStyle: FontStyle.italic,
        color: accent.withValues(alpha: 0.9),
      ),
      listBullet: TextStyle(
        fontSize: 14.5,
        color: accent,
        height: 1.65,
      ),
      tableHead: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 12.5,
        color: accent,
        backgroundColor: light,
      ),
      tableBody: const TextStyle(
        fontSize: 12.5,
        color: Color(0xFF3D4154),
        height: 1.5,
      ),
      tableBorder: TableBorder.all(
        color: accent.withValues(alpha: 0.18),
        width: 1,
        borderRadius: BorderRadius.circular(10),
      ),
      tableColumnWidth: const FlexColumnWidth(),
      tableHeadAlign: TextAlign.left,
      blockquoteDecoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: accent, width: 4)),
      ),
      blockquotePadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFFF0F1F5),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFE0E3ED)),
      ),
      code: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 12.5,
        color: Color(0xFF3D4154),
        backgroundColor: Color(0xFFF0F1F5),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: accent.withValues(alpha: 0.18), width: 1.5),
        ),
      ),
    );
  }

  // ── Bottom Bar ─────────────────────────────────────────────────────────────

  Widget _buildBottomBar(HealthArticle article, Color color, bool isOff,
      HealthEducationState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 10, 12, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE8EAED), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          _BottomBtn(
            icon: _ttsPlaying
                ? Icons.pause_circle_filled_rounded
                : Icons.record_voice_over_rounded,
            label: _ttsPlaying ? 'Pause' : 'Listen',
            color: color,
            filled: _ttsPlaying,
            onTap: () {
              setState(() => _showTtsBar = !_showTtsBar);
              _toggleTts();
            },
          ),
          const SizedBox(width: 8),
          _BottomBtn(
            icon: article.isBookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            label: article.isBookmarked ? 'Saved' : 'Save',
            color: article.isBookmarked ? color : const Color(0xFFAAB0C4),
            filled: article.isBookmarked,
            onTap: () => ref
                .read(healthEducationControllerProvider.notifier)
                .toggleBookmark(article),
          ),
          const SizedBox(width: 8),
          _BottomBtn(
            icon: isOff
                ? Icons.download_done_rounded
                : Icons.download_for_offline_outlined,
            label: isOff ? 'Offline' : 'Download',
            color: isOff ? DesignTokens.green : const Color(0xFFAAB0C4),
            filled: isOff,
            onTap: () => ref
                .read(healthEducationControllerProvider.notifier)
                .toggleOffline(article),
          ),
          const SizedBox(width: 8),
          _BottomBtn(
            icon: Icons.share_rounded,
            label: 'Share',
            color: const Color(0xFFAAB0C4),
            onTap: () => _shareArticle(article),
          ),
        ],
      ),
    );
  }

  // ── TTS Speed Bar ──────────────────────────────────────────────────────────

  Widget _buildTtsBar(Color color) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    // Bottom bar is ~78px tall (10 top + 10 bottom padding + ~58 content)
    // Add safe area inset so it floats cleanly above it
    final barBottom = bottomInset + 80.0;
    return Positioned(
      bottom: barBottom,
      left: 16,
      right: 16,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.speed_rounded, size: 16, color: color),
                ),
                const SizedBox(width: 8),
                Text('Reading Speed',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: color,
                    )),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _showTtsBar = false),
                  child: Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F1F5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 14, color: Color(0xFF8890AA)),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 7),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 14),
                      activeTrackColor: color,
                      inactiveTrackColor: color.withValues(alpha: 0.18),
                      thumbColor: color,
                      overlayColor: color.withValues(alpha: 0.12),
                    ),
                    child: Slider(
                      value: _ttsRate,
                      min: 0.25,
                      max: 1.0,
                      divisions: 3,
                      onChanged: _updateTtsRate,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_ttsRate}x',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 200.ms)
          .slideY(begin: 0.15, end: 0, duration: 200.ms),
    );
  }

  // ── Shimmer ────────────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(10, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Shimmer.fromColors(
              baseColor: const Color(0xFFE8EAED),
              highlightColor: const Color(0xFFF4F5F7),
              child: Container(
                height: i == 0 ? 26 : 15,
                width: i % 3 == 0
                    ? double.infinity
                    : MediaQuery.of(context).size.width *
                        (0.45 + (i % 4) * 0.1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Share ──────────────────────────────────────────────────────────────────

  void _shareArticle(HealthArticle article) {
    final text =
        '📚 ${article.title}\n\n${article.summary ?? ''}\n\n— AI Healthcare Assistant';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Copied to clipboard!',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        backgroundColor: DesignTokens.green,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ─── Reading Progress Bar ─────────────────────────────────────────────────────

class _ReadingProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  const _ReadingProgressBar({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.transparent,
        valueColor: AlwaysStoppedAnimation<Color>(color.withValues(alpha: 0.7)),
      ),
    );
  }
}

// ─── AppBar Action Pill ────────────────────────────────────────────────────────

class _AppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AppBarAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 17, color: Colors.white),
        ),
      ),
    );
  }
}

// ─── Meta Pill ────────────────────────────────────────────────────────────────

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Badge ────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Action Button ─────────────────────────────────────────────────────

class _BottomBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool filled;

  const _BottomBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: filled
                ? color.withValues(alpha: 0.12)
                : color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: filled
                  ? color.withValues(alpha: 0.30)
                  : color.withValues(alpha: 0.12),
            ),
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
