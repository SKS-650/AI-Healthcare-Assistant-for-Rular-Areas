import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../domain/entities/prediction_result.dart';
import 'history_card.dart';

class HistoryList extends StatelessWidget {
  final List<PredictionResult> results;
  final ValueChanged<PredictionResult>? onSelected;

  const HistoryList({super.key, required this.results, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final result = results[index];
        return HistoryCard(
          result: result,
          onTap: onSelected == null ? null : () => onSelected!(result),
        );
      },
    );
  }
}

class EmptyHistoryWidget extends StatelessWidget {
  const EmptyHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: DesignTokens.primaryContainer,
                borderRadius: BorderRadius.circular(22),
              ),
              child:
                  const Center(child: Text('📋', style: TextStyle(fontSize: 42))),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Predictions Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textStrong,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Run your first AI disease prediction\nto see results here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: DesignTokens.textMuted, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
