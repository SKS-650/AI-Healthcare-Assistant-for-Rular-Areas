import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../providers/disease_prediction_provider.dart';
import '../widgets/history/history_list.dart';
import 'prediction_result_page.dart';

class PredictionHistoryPage extends ConsumerWidget {
  const PredictionHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(diseasePredictionControllerProvider);
    final controller = ref.read(diseasePredictionControllerProvider.notifier);

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
              'Prediction History',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textStrong,
              ),
            ),
          ],
        ),
      ),
      body: state.history.isEmpty
          ? const EmptyHistoryWidget()
          : HistoryList(
              results: state.history,
              onSelected: (result) {
                controller.selectResult(result);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PredictionResultPage(result: result),
                  ),
                );
              },
            ),
    );
  }
}
