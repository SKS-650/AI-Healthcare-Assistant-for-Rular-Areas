import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../disease_prediction/domain/entities/prediction_result.dart';
import '../../../disease_prediction/presentation/pages/prediction_result_page.dart';
import '../../../disease_prediction/presentation/providers/disease_prediction_provider.dart';

/// /history route — shows the disease prediction history for the current user.
/// Reuses the rich [PredictionResult] data already loaded by the disease
/// prediction controller so no additional API call is needed.
class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(
      diseasePredictionControllerProvider.select((s) => s.history),
    );

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
            Text('📋', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              'Symptom Check History',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textStrong,
              ),
            ),
          ],
        ),
      ),
      body: history.isEmpty
          ? _EmptyHistory(
              onCheckSymptoms: () => Navigator.of(context).pop(),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: history.length,
              itemBuilder: (ctx, i) => _HistoryCard(
                result: history[i],
                onTap: () => Navigator.of(ctx).push(
                  MaterialPageRoute(
                    builder: (_) => PredictionResultPage(result: history[i]),
                  ),
                ),
              ),
            ),
    );
  }
}

// ─── History card ─────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final PredictionResult result;
  final VoidCallback onTap;
  const _HistoryCard({required this.result, required this.onTap});

  Color _riskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':
        return DesignTokens.success;
      case 'medium':
      case 'moderate':
        return DesignTokens.warning;
      case 'high':
        return DesignTokens.orange;
      case 'critical':
        return DesignTokens.danger;
      default:
        return DesignTokens.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rc = _riskColor(result.riskLevel);
    final pct = (result.confidence * 100).toStringAsFixed(1);
    final dateStr = DateFormat('d MMM yyyy  HH:mm').format(result.createdAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: DesignTokens.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: rc.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: rc.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Risk indicator
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: rc.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  result.isEmergency ? '🚨' : '🧬',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          result.disease.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: DesignTokens.textStrong,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: rc.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          result.riskLevel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: rc,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Confidence: $pct%',
                    style: const TextStyle(
                        fontSize: 12, color: DesignTokens.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: result.confidence.clamp(0.0, 1.0),
                            minHeight: 4,
                            backgroundColor:
                                DesignTokens.border,
                            valueColor: AlwaysStoppedAnimation<Color>(rc),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        dateStr,
                        style: const TextStyle(
                            fontSize: 10,
                            color: DesignTokens.textSubtle),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: DesignTokens.textSubtle),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyHistory extends StatelessWidget {
  final VoidCallback onCheckSymptoms;
  const _EmptyHistory({required this.onCheckSymptoms});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: DesignTokens.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text('📋', style: TextStyle(fontSize: 44)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No History Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textStrong,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your symptom check results will appear here after completing an assessment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: DesignTokens.textMuted, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onCheckSymptoms,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Check Symptoms',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                backgroundColor: DesignTokens.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(180, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
