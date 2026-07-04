import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../providers/symptom_provider.dart';
import 'duration_page.dart';
import 'lifestyle_page.dart';
import 'medical_history_page.dart';
import 'personal_info_page.dart';
import 'review_page.dart';
import 'severity_page.dart';
import 'symptom_selection_page.dart';

class SymptomCheckerPage extends ConsumerWidget {
  const SymptomCheckerPage({super.key});

  static const _stepTitles = [
    'Select Symptoms',
    'Rate Severity',
    'Duration',
    'Personal Info',
    'Medical History',
    'Lifestyle',
    'Review & Submit',
  ];

  static const _stepEmojis = [
    '🩺', '📊', '⏱️', '👤', '🏥', '🏃', '✅',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(
        symptomControllerProvider.select((s) => s.currentStep));

    final List<Widget> steps = [
      const SymptomSelectionPage(),
      const SeverityPage(),
      const DurationPage(),
      const PersonalInfoPage(),
      const MedicalHistoryPage(),
      const LifestylePage(),
      const ReviewPage(),
    ];

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () =>
                    ref.read(symptomControllerProvider.notifier).previousStep(),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(_stepEmojis[currentStep],
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  _stepTitles[currentStep],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.textStrong,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            Text(
              'Step ${currentStep + 1} of 7',
              style: const TextStyle(
                  fontSize: 11,
                  color: DesignTokens.textMuted,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress steps bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: List.generate(7, (i) {
                  final done = i < currentStep;
                  final active = i == currentStep;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: done || active
                            ? const LinearGradient(
                                colors: [
                                  DesignTokens.primary,
                                  DesignTokens.primaryLight
                                ],
                              )
                            : null,
                        color: done || active ? null : DesignTokens.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Page content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.06, 0),
                    end: Offset.zero,
                  ).animate(anim),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: KeyedSubtree(
                  key: ValueKey(currentStep),
                  child: steps[currentStep],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
