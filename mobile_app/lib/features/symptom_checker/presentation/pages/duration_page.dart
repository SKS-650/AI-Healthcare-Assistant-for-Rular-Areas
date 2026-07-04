import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../providers/symptom_provider.dart';

class DurationPage extends ConsumerWidget {
  const DurationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(symptomControllerProvider);
    final notifier = ref.read(symptomControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: DesignTokens.infoContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: DesignTokens.info.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Text('⏱️', style: TextStyle(fontSize: 22)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'How many days have you been experiencing each symptom?',
                    style: TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            itemCount: state.selectedSymptoms.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final selected = state.selectedSymptoms[index];
              return _DurationCard(
                name: selected.symptom.name,
                duration: selected.durationInDays,
                onChanged: (val) =>
                    notifier.updateSymptomDuration(selected.symptom.id, val),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: () => notifier.nextStep(),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Next: Personal Info',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              style: FilledButton.styleFrom(
                backgroundColor: DesignTokens.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DurationCard extends StatelessWidget {
  final String name;
  final int duration;
  final ValueChanged<int> onChanged;

  const _DurationCard({
    required this.name,
    required this.duration,
    required this.onChanged,
  });

  String _durationCategory(int d) {
    if (d <= 1) return 'Today';
    if (d <= 3) return 'Few days';
    if (d <= 7) return 'About a week';
    if (d <= 14) return 'Two weeks';
    return 'Over 2 weeks';
  }

  Color _durationColor(int d) {
    if (d <= 2) return DesignTokens.success;
    if (d <= 7) return DesignTokens.warning;
    return DesignTokens.danger;
  }

  @override
  Widget build(BuildContext context) {
    final color = _durationColor(duration);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⏱️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: DesignTokens.textStrong,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$duration day${duration == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Quick select chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [1, 2, 3, 5, 7, 10, 14, 21, 30].map((d) {
              final isSelected = duration == d;
              return GestureDetector(
                onTap: () => onChanged(d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(colors: [
                            _durationColor(d),
                            _durationColor(d).withValues(alpha: 0.8)
                          ])
                        : null,
                    color: isSelected
                        ? null
                        : DesignTokens.surfaceMuted,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? _durationColor(d)
                          : DesignTokens.border,
                    ),
                  ),
                  child: Text(
                    '$d day${d == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : DesignTokens.textMuted,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            _durationCategory(duration),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
