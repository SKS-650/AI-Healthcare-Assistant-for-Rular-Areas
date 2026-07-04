import 'package:flutter/material.dart';
import '../../../../../shared/design_system/design_tokens.dart';

const _tipAccents = [
  _TA(bg: Color(0xFFFFF8E6), border: Color(0xFFFFE08A), iconBg: Color(0xFFFEF3C7), text: Color(0xFF92400E), dot: Color(0xFFFFB829), emoji: '💡'),
  _TA(bg: Color(0xFFF0EBFF), border: Color(0xFFD4C8FF), iconBg: Color(0xFFE8E0FF), text: Color(0xFF4A2FC4), dot: Color(0xFF926EFF), emoji: '🌿'),
  _TA(bg: Color(0xFFE4FBF0), border: Color(0xFFAAEFCF), iconBg: Color(0xFFD1FAE5), text: Color(0xFF065F46), dot: Color(0xFF2ECC8B), emoji: '🏃'),
  _TA(bg: Color(0xFFE8F1FF), border: Color(0xFFBFD4FF), iconBg: Color(0xFFDBEAFE), text: Color(0xFF1E3A8A), dot: Color(0xFF4F94FF), emoji: '💧'),
  _TA(bg: Color(0xFFFFEAF3), border: Color(0xFFFFB8D4), iconBg: Color(0xFFFFE4F0), text: Color(0xFF9D174D), dot: Color(0xFFFF5E9E), emoji: '❤️'),
];

class _TA {
  final Color bg, border, iconBg, text, dot;
  final String emoji;
  const _TA({required this.bg, required this.border, required this.iconBg, required this.text, required this.dot, required this.emoji});
}

class TipsSlider extends StatefulWidget {
  final List<String> tips;
  const TipsSlider({super.key, required this.tips});

  @override
  State<TipsSlider> createState() => _TipsSliderState();
}

class _TipsSliderState extends State<TipsSlider> {
  int _idx = 0;
  late final PageController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 90,
        child: PageView.builder(
          controller: _ctrl,
          onPageChanged: (i) => setState(() => _idx = i),
          itemCount: widget.tips.length,
          itemBuilder: (context, i) {
            final a = _tipAccents[i % _tipAccents.length];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: a.bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: a.border, width: 1.2),
                boxShadow: [BoxShadow(color: a.dot.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: a.iconBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: a.border)),
                  child: Center(child: Text(a.emoji, style: const TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(widget.tips[i],
                      style: TextStyle(fontSize: 13, color: a.text, height: 1.4, fontWeight: FontWeight.w600),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ]),
            );
          },
        ),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.tips.length, (i) {
          final a = _tipAccents[i % _tipAccents.length];
          final active = _idx == i;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 18 : 6, height: 6,
            decoration: BoxDecoration(
              gradient: active ? LinearGradient(colors: [a.dot, a.border]) : null,
              color: active ? null : DesignTokens.border,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    ]);
  }
}
