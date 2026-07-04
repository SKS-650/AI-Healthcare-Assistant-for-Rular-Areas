import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../providers/symptom_provider.dart';

class SeverityPage extends ConsumerWidget {
  const SeverityPage({super.key});

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
              color: DesignTokens.warningContainer,
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: DesignTokens.warning.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Text('📊', style: TextStyle(fontSize: 22)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Rate how severe each symptom feels on a scale of 1 (mild) to 10 (severe).',
                    style: TextStyle(
                      color: Color(0xFF92400E),
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

        // Severity list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            itemCount: state.selectedSymptoms.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final selected = state.selectedSymptoms[index];
              return _SeverityCard(
                name: selected.symptom.name,
                severity: selected.severity,
                onChanged: (val) =>
                    notifier.updateSymptomSeverity(selected.symptom.id, val),
              );
            },
          ),
        ),

        // Bottom action
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: () => notifier.nextStep(),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Next: Duration',
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

class _SeverityCard extends StatelessWidget {
  final String name;
  final double severity;
  final ValueChanged<double> onChanged;

  const _SeverityCard({
    required this.name,
    required this.severity,
    required this.onChanged,
  });

  Color _severityColor(double s) {
    if (s <= 3) return DesignTokens.success;
    if (s <= 6) return DesignTokens.warning;
    if (s <= 8) return DesignTokens.orange;
    return DesignTokens.danger;
  }

  String _severityLabel(double s) {
    if (s <= 2) return 'Very Mild';
    if (s <= 4) return 'Mild';
    if (s <= 6) return 'Moderate';
    if (s <= 8) return 'Severe';
    return 'Very Severe';
  }

  String _severityEmoji(double s) {
    if (s <= 2) return '😊';
    if (s <= 4) return '😐';
    if (s <= 6) return '😟';
    if (s <= 8) return '😣';
    return '😰';
  }

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(severity);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_severityEmoji(severity),
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: DesignTokens.textStrong,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      severity.toInt().toString(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '/10',
                      style: TextStyle(
                        color: color.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.15),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.12),
              trackHeight: 6,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: severity,
              min: 1.0,
              max: 10.0,
              divisions: 9,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mild',
                  style: TextStyle(
                      color: DesignTokens.textSubtle,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _severityLabel(severity),
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Text('Severe',
                  style: TextStyle(
                      color: DesignTokens.textSubtle,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
