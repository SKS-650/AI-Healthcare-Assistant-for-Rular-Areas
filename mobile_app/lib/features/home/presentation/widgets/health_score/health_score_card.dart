import 'package:flutter/material.dart';
import '../../../../../shared/design_system/design_tokens.dart';
import '../../../domain/entities/health_score.dart';

class HealthScoreCard extends StatelessWidget {
  final HealthScore healthScore;
  const HealthScoreCard({super.key, required this.healthScore});

  List<Color> _gradColors(int score) {
    if (score >= 80) return const [Color(0xFF2ECC8B), Color(0xFF16A34A)];
    if (score >= 60) return const [Color(0xFFFFB829), Color(0xFFD98E00)];
    if (score >= 40) return const [Color(0xFFFF7B3D), Color(0xFFE55A1A)];
    return const [Color(0xFFFF4757), Color(0xFFCC2233)];
  }

  String _emoji(int score) {
    if (score >= 80) return '💚';
    if (score >= 60) return '💛';
    if (score >= 40) return '🧡';
    return '❤️';
  }

  @override
  Widget build(BuildContext context) {
    final grad = _gradColors(healthScore.score);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DesignTokens.border),
        boxShadow: [
          BoxShadow(
            color: grad[0].withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Score ring
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: healthScore.score / 100,
                    strokeWidth: 7,
                    backgroundColor: grad[0].withValues(alpha: 0.10),
                    valueColor: AlwaysStoppedAnimation<Color>(grad[0]),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${healthScore.score}',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: grad[0],
                            height: 1.0)),
                    const Text('/100',
                        style: TextStyle(
                            fontSize: 10,
                            color: DesignTokens.textSubtle,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        grad[0].withValues(alpha: 0.15),
                        grad[1].withValues(alpha: 0.08)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: grad[0].withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_emoji(healthScore.score),
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 5),
                      Text(healthScore.status,
                          style: TextStyle(
                              color: grad[0],
                              fontSize: 12,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                const SizedBox(height: 7),
                const Text('Health Score',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: DesignTokens.textStrong,
                        letterSpacing: -0.2)),
                const SizedBox(height: 3),
                Text(healthScore.description,
                    style: const TextStyle(
                        color: DesignTokens.textMuted,
                        fontSize: 12,
                        height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded,
              size: 20, color: DesignTokens.textSubtle),
        ],
      ),
    );
  }
}
