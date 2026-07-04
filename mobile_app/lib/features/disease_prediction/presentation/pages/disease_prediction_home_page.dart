import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../providers/disease_prediction_provider.dart';
import '../widgets/common/section_title.dart';
import '../widgets/history/history_card.dart';
import 'prediction_history_page.dart';
import 'prediction_loading_page.dart';
import 'prediction_result_page.dart';

class DiseasePredictionHomePage extends ConsumerStatefulWidget {
  const DiseasePredictionHomePage({super.key});

  @override
  ConsumerState<DiseasePredictionHomePage> createState() =>
      _DiseasePredictionHomePageState();
}

class _DiseasePredictionHomePageState
    extends ConsumerState<DiseasePredictionHomePage> {
  final TextEditingController _symptomController = TextEditingController();

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diseasePredictionControllerProvider);
    final controller =
        ref.read(diseasePredictionControllerProvider.notifier);

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: DesignTokens.textStrong, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Row(
          children: [
            Text('🧠', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text(
              'Disease Prediction',
              style: TextStyle(
                color: DesignTokens.textStrong,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: DesignTokens.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: DesignTokens.border),
            ),
            child: IconButton(
              tooltip: 'History',
              icon: const Icon(Icons.history_rounded, size: 20),
              color: DesignTokens.textStrong,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PredictionHistoryPage(),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // Header banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  BorderRadius.circular(DesignTokens.cardRadius),
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.violet.withValues(alpha: 0.25),
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
                        'AI Disease Prediction',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Enter your symptoms below and our AI will analyze them to suggest possible conditions.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Text('🧬', style: TextStyle(fontSize: 48)),
              ],
            ),
          ),

          // Symptom input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: DesignTokens.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: DesignTokens.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _symptomController,
                      decoration: const InputDecoration(
                        hintText:
                            'Type a symptom (e.g., fever, headache)',
                        prefixIcon: Icon(
                          Icons.add_circle_outline_rounded,
                          color: DesignTokens.primary,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onSubmitted: (value) {
                        controller.addSymptom(value);
                        _symptomController.clear();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilledButton(
                      onPressed: () {
                        controller
                            .addSymptom(_symptomController.text);
                        _symptomController.clear();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: DesignTokens.primary,
                        minimumSize: const Size(60, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Add'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Selected symptoms chips
          if (state.symptoms.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.symptoms.map((symptom) {
                  return Container(
                    decoration: BoxDecoration(
                      color: DesignTokens.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: DesignTokens.primary
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          symptom,
                          style: const TextStyle(
                            color: DesignTokens.primaryDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () =>
                              controller.removeSymptom(symptom),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: DesignTokens.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DesignTokens.dangerContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Text('❌', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(
                          color: DesignTokens.danger,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Run prediction button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: state.symptoms.isEmpty
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const PredictionLoadingPage(),
                          ),
                        ),
                icon: const Icon(Icons.psychology_outlined),
                label: const Text(
                  'Run AI Prediction',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: DesignTokens.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),

          // Latest result
          if (state.predictionResult != null) ...[
            const SectionTitle(title: 'Latest Result', emoji: '🎯'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: HistoryCard(
                result: state.predictionResult!,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PredictionResultPage(
                      result: state.predictionResult!,
                    ),
                  ),
                ),
              ),
            ),
          ],

          // History
          if (state.history.isNotEmpty) ...[
            SectionTitle(
              title: 'Recent Predictions',
              emoji: '📋',
              onSeeAll: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PredictionHistoryPage(),
                ),
              ),
            ),
            ...state.history.take(2).map(
              (result) => Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                child: HistoryCard(result: result),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
