import 'package:flutter/material.dart';
import '../../../../../shared/design_system/design_tokens.dart';
import '../../../domain/entities/article.dart';

const _articleAccents = [
  _AA(bg: Color(0xFFF0EBFF), border: Color(0xFFD4C8FF), icon: Color(0xFF926EFF), badge: Color(0xFF6B47E8)),
  _AA(bg: Color(0xFFE8F1FF), border: Color(0xFFBFD4FF), icon: Color(0xFF4F94FF), badge: Color(0xFF2563EB)),
  _AA(bg: Color(0xFFE4FBF0), border: Color(0xFFAAEFCF), icon: Color(0xFF2ECC8B), badge: Color(0xFF16A34A)),
  _AA(bg: Color(0xFFFFF8E6), border: Color(0xFFFFE08A), icon: Color(0xFFFFB829), badge: Color(0xFFD98E00)),
  _AA(bg: Color(0xFFFFEAF3), border: Color(0xFFFFB8D4), icon: Color(0xFFFF5E9E), badge: Color(0xFFE11D68)),
  _AA(bg: Color(0xFFE4FAFA), border: Color(0xFFAAE8E8), icon: Color(0xFF18C8C8), badge: Color(0xFF0B9B9B)),
];

class _AA {
  final Color bg, border, icon, badge;
  const _AA({required this.bg, required this.border, required this.icon, required this.badge});
}

class LatestArticlesList extends StatelessWidget {
  final List<Article> articles;
  const LatestArticlesList({super.key, required this.articles});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 218,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: articles.length,
        itemBuilder: (context, i) =>
            _ArticleCard(article: articles[i], index: i),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;
  final int index;
  const _ArticleCard({required this.article, required this.index});

  String _emoji(String cat) {
    switch (cat.toLowerCase()) {
      case 'nutrition': return '🍎';
      case 'mental health': return '🧠';
      case 'exercise': return '🏃';
      case 'heart': return '❤️';
      case 'diabetes': return '🩸';
      case 'hygiene': return '💧';
      default: return '📖';
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = _articleAccents[index % _articleAccents.length];
    return Container(
      width: 210,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: a.border, width: 1.2),
        boxShadow: [BoxShadow(color: a.icon.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 84,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [a.bg, a.border.withValues(alpha: 0.4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Center(child: Text(_emoji(article.category), style: const TextStyle(fontSize: 36))),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: a.bg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: a.icon.withValues(alpha: 0.3))),
                      child: Text(article.category.toUpperCase(),
                          style: TextStyle(color: a.badge, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
                    ),
                    const SizedBox(height: 5),
                    Text(article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13, height: 1.3,
                            color: DesignTokens.textStrong, letterSpacing: -0.1)),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.schedule_rounded, size: 11, color: a.icon),
                      const SizedBox(width: 3),
                      Text(article.readTime, style: TextStyle(color: a.icon, fontSize: 11, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: a.bg, borderRadius: BorderRadius.circular(8)),
                        child: Text('Read →', style: TextStyle(color: a.badge, fontSize: 10, fontWeight: FontWeight.w800)),
                      ),
                    ]),
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
