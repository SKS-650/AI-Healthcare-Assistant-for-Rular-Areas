import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../providers/symptom_provider.dart';
import 'analyzing_page.dart';

class ReviewPage extends ConsumerWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(symptomControllerProvider);
    final notifier = ref.read(symptomControllerProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DesignTokens.primary, DesignTokens.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                Text('✅', style: TextStyle(fontSize: 24)),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Almost there!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Review your info before AI analysis',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Summary cards
          _ReviewCard(
            emoji: '🩺',
            title: 'Symptoms',
            items: state.selectedSymptoms
                .map((s) => '${s.symptom.name} (${s.severity.toInt()}/10)')
                .toList(),
            color: DesignTokens.primary,
            onEdit: () => notifier.setStep(0),
          ),

          const SizedBox(height: 10),

          _ReviewCard(
            emoji: '👤',
            title: 'Personal Info',
            items: [
              'Age: ${state.age} years',
              'Gender: ${state.gender}',
            ],
            color: DesignTokens.blue,
            onEdit: () => notifier.setStep(3),
          ),

          if (state.chronicConditions.isNotEmpty ||
              state.allergies.isNotEmpty ||
              state.currentMedications.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ReviewCard(
              emoji: '🏥',
              title: 'Medical History',
              items: [
                if (state.chronicConditions.isNotEmpty)
                  'Conditions: ${state.chronicConditions.join(', ')}',
                if (state.allergies.isNotEmpty)
                  'Allergies: ${state.allergies.join(', ')}',
                if (state.currentMedications.isNotEmpty)
                  'Medications: ${state.currentMedications.join(', ')}',
              ],
              color: DesignTokens.orange,
              onEdit: () => notifier.setStep(4),
            ),
          ],

          const SizedBox(height: 10),

          _ReviewCard(
            emoji: '🏃',
            title: 'Lifestyle',
            items: [
              'Smoking: ${state.smokingHabit}',
              'Alcohol: ${state.alcoholConsumption}',
              'Exercise: ${state.exerciseFrequency}',
              'Sleep: ${state.averageSleepHours} hours/night',
            ],
            color: DesignTokens.green,
            onEdit: () => notifier.setStep(5),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: DesignTokens.warningContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: DesignTokens.warning.withValues(alpha: 0.3)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⚠️', style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This AI analysis is for informational purposes only and does not replace professional medical advice. Always consult a qualified healthcare provider.',
                    style: TextStyle(
                      color: Color(0xFF92400E),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [DesignTokens.primary, DesignTokens.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.primary.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    notifier.runDiagnosticAnalysis();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AnalyzingPage()),
                    );
                  },
                  child: const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🤖', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 10),
                        Text(
                          'Run AI Analysis',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String emoji, title;
  final List<String> items;
  final Color color;
  final VoidCallback onEdit;

  const _ReviewCard({
    required this.emoji,
    required this.title,
    required this.items,
    required this.color,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                    child: Text(emoji,
                        style: const TextStyle(fontSize: 16))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: color,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13,
                        color: DesignTokens.textStrong,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
