import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class HealthEducationPage extends StatefulWidget {
  const HealthEducationPage({super.key});

  @override
  State<HealthEducationPage> createState() => _HealthEducationPageState();
}

class _HealthEducationPageState extends State<HealthEducationPage> {
  int _selectedCategory = 0;

  static const _categories = [
    ('All', '📚'),
    ('Nutrition', '🍎'),
    ('Exercise', '🏃'),
    ('Mental Health', '🧠'),
    ('Heart', '❤️'),
    ('Diabetes', '🩸'),
    ('Hygiene', '🧼'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          children: [
            Text('📚', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              'Health Education',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textStrong,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFB829), Color(0xFFFF7B3D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.yellow.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Learn & Stay Healthy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Evidence-based health articles for rural communities',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Text('📖', style: TextStyle(fontSize: 48)),
              ],
            ),
          ),

          // Category filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 0, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.asMap().entries.map((e) {
                  final selected = _selectedCategory == e.key;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = e.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? const LinearGradient(
                                colors: [
                                  DesignTokens.primary,
                                  DesignTokens.primaryDark
                                ],
                              )
                            : null,
                        color: selected ? null : DesignTokens.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? DesignTokens.primary
                              : DesignTokens.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(e.value.$2,
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 5),
                          Text(
                            e.value.$1,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? Colors.white
                                  : DesignTokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Article list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              itemCount: _articles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _ArticleCard(article: _articles[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final _Article article;
  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: article.color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: article.color.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon box
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        article.color,
                        article.color.withValues(alpha: 0.7)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: article.color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                      child: Text(article.emoji,
                          style: const TextStyle(fontSize: 26))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: article.color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          article.category.toUpperCase(),
                          style: TextStyle(
                            color: article.color,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
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
                      const SizedBox(height: 5),
                      Text(
                        article.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: DesignTokens.textMuted,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded,
                              size: 12, color: article.color),
                          const SizedBox(width: 4),
                          Text(article.readTime,
                              style: TextStyle(
                                  color: article.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: article.color.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Read →',
                                style: TextStyle(
                                    color: article.color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800)),
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
      ),
    );
  }
}

class _Article {
  final String emoji, title, category, summary, readTime;
  final Color color;
  const _Article({
    required this.emoji,
    required this.title,
    required this.category,
    required this.summary,
    required this.readTime,
    required this.color,
  });
}

const _articles = [
  _Article(
    emoji: '💧',
    title: 'How Much Water Should You Drink Daily?',
    category: 'Nutrition',
    summary:
        'Learn about daily hydration needs based on your age, weight, and activity level for optimal health.',
    readTime: '3 min read',
    color: Color(0xFF4F94FF),
  ),
  _Article(
    emoji: '🏃',
    title: 'Simple Exercises for a Healthier Life',
    category: 'Exercise',
    summary:
        'Low-cost exercise routines you can do at home or in your village — no gym equipment needed.',
    readTime: '5 min read',
    color: Color(0xFF2ECC8B),
  ),
  _Article(
    emoji: '🧠',
    title: 'Understanding Stress and Mental Wellness',
    category: 'Mental Health',
    summary:
        'Practical ways to manage stress, anxiety and improve your mental well-being in daily life.',
    readTime: '4 min read',
    color: Color(0xFF926EFF),
  ),
  _Article(
    emoji: '❤️',
    title: 'Heart Health: Warning Signs You Should Know',
    category: 'Heart',
    summary:
        'Recognizing early signs of heart disease and how simple lifestyle changes can protect your heart.',
    readTime: '6 min read',
    color: Color(0xFFFF4757),
  ),
  _Article(
    emoji: '🩸',
    title: 'Managing Diabetes in Rural Communities',
    category: 'Diabetes',
    summary:
        'How to monitor blood sugar, eat right, and stay active even with limited access to healthcare.',
    readTime: '7 min read',
    color: Color(0xFFFF7B3D),
  ),
  _Article(
    emoji: '🍎',
    title: 'Balanced Diet on a Budget',
    category: 'Nutrition',
    summary:
        'Eating nutritiously without spending much — affordable local foods that provide all essential nutrients.',
    readTime: '4 min read',
    color: Color(0xFFFFB829),
  ),
  _Article(
    emoji: '🧼',
    title: 'Handwashing: Your First Line of Defense',
    category: 'Hygiene',
    summary:
        'Proper handwashing technique that prevents 80% of common infections. Simple but critical.',
    readTime: '2 min read',
    color: Color(0xFF18C8C8),
  ),
  _Article(
    emoji: '😴',
    title: 'Why Sleep Matters for Your Health',
    category: 'Mental Health',
    summary:
        'The science of sleep and how getting 7–8 hours each night can prevent chronic diseases.',
    readTime: '5 min read',
    color: Color(0xFF5F6FFF),
  ),
];
