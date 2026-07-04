import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../providers/symptom_provider.dart';

class LifestylePage extends ConsumerWidget {
  const LifestylePage({super.key});

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
              color: DesignTokens.greenContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: DesignTokens.green.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Text('🏃', style: TextStyle(fontSize: 22)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Lifestyle habits significantly affect your health. Please answer honestly.',
                    style: TextStyle(
                      color: Color(0xFF065F46),
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _ChoiceField(
            emoji: '🚭',
            title: 'Smoking Habit',
            value: state.smokingHabit,
            options: const [
              _Option(value: 'Never', emoji: '✅', label: 'Never'),
              _Option(value: 'Occasional', emoji: '🌿', label: 'Occasional'),
              _Option(value: 'Regular', emoji: '⚠️', label: 'Regular'),
            ],
            onChanged: (v) => notifier.updateLifestyle(smoking: v),
          ),

          const SizedBox(height: 20),

          _ChoiceField(
            emoji: '🥛',
            title: 'Alcohol Consumption',
            value: state.alcoholConsumption,
            options: const [
              _Option(value: 'Never', emoji: '✅', label: 'Never'),
              _Option(value: 'Occasional', emoji: '🍷', label: 'Occasional'),
              _Option(value: 'Regular', emoji: '⚠️', label: 'Regular'),
            ],
            onChanged: (v) => notifier.updateLifestyle(alcohol: v),
          ),

          const SizedBox(height: 20),

          _ChoiceField(
            emoji: '🏋️',
            title: 'Exercise Frequency',
            value: state.exerciseFrequency,
            options: const [
              _Option(value: 'Low', emoji: '🛋️', label: 'Low'),
              _Option(value: 'Medium', emoji: '🚶', label: 'Medium'),
              _Option(value: 'High', emoji: '🏃', label: 'High'),
            ],
            onChanged: (v) => notifier.updateLifestyle(exercise: v),
          ),

          const SizedBox(height: 20),

          // Sleep
          Row(
            children: [
              const Text('😴', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              const Text(
                'Average Sleep (hours/night)',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: DesignTokens.textStrong,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: DesignTokens.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${state.averageSleepHours}h',
                  style: const TextStyle(
                    color: DesignTokens.primaryDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: DesignTokens.primary,
              inactiveTrackColor: DesignTokens.primaryContainer,
              thumbColor: DesignTokens.primary,
              overlayColor: DesignTokens.primary.withValues(alpha: 0.12),
              trackHeight: 6,
            ),
            child: Slider(
              value: state.averageSleepHours.toDouble(),
              min: 3,
              max: 12,
              divisions: 9,
              onChanged: (v) =>
                  notifier.updateLifestyle(sleep: v.round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('3h', style: TextStyle(color: DesignTokens.textSubtle, fontSize: 11)),
              Text(
                state.averageSleepHours < 6
                    ? '😟 Poor sleep'
                    : state.averageSleepHours <= 8
                        ? '😊 Good sleep'
                        : '😴 Excessive sleep',
                style: TextStyle(
                  color: state.averageSleepHours < 6
                      ? DesignTokens.danger
                      : state.averageSleepHours <= 8
                          ? DesignTokens.success
                          : DesignTokens.warning,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text('12h', style: TextStyle(color: DesignTokens.textSubtle, fontSize: 11)),
            ],
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: () => notifier.nextStep(),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Review & Submit',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              style: FilledButton.styleFrom(
                backgroundColor: DesignTokens.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Option {
  final String value, emoji, label;
  const _Option(
      {required this.value, required this.emoji, required this.label});
}

class _ChoiceField extends StatelessWidget {
  final String emoji, title, value;
  final List<_Option> options;
  final ValueChanged<String> onChanged;

  const _ChoiceField({
    required this.emoji,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: DesignTokens.textStrong,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: options.map((opt) {
            final isSelected = value == opt.value;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(opt.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [
                              DesignTokens.primary,
                              DesignTokens.primaryDark,
                            ],
                          )
                        : null,
                    color: isSelected ? null : DesignTokens.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? DesignTokens.primary
                          : DesignTokens.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color:
                                  DesignTokens.primary.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(opt.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(
                        opt.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white
                              : DesignTokens.textStrong,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
