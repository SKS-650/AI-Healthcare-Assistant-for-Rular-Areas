import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../providers/symptom_provider.dart';

class SymptomSelectionPage extends ConsumerWidget {
  const SymptomSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(symptomControllerProvider);
    final notifier = ref.read(symptomControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header card
        Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [DesignTokens.primary, DesignTokens.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: DesignTokens.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🩺 What are you feeling?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Select all symptoms you are\nexperiencing right now.',
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    '${state.selectedSymptoms.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'selected',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Symptom list
        Expanded(
          child: state.availableSymptoms.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                    color: DesignTokens.primary,
                    strokeWidth: 2.5,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  itemCount: state.availableSymptoms.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final symptom = state.availableSymptoms[index];
                    final isSelected = state.selectedSymptoms
                        .any((s) => s.symptom.id == symptom.id);
                    return _SymptomTile(
                      name: symptom.name,
                      category: symptom.category,
                      isSelected: isSelected,
                      onTap: () => notifier.toggleSymptomSelection(symptom),
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
              onPressed:
                  state.selectedSymptoms.isEmpty ? null : () => notifier.nextStep(),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(
                state.selectedSymptoms.isEmpty
                    ? 'Select at least one symptom'
                    : 'Next: Rate Severity (${state.selectedSymptoms.length} selected)',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: DesignTokens.primary,
                disabledBackgroundColor: DesignTokens.border,
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

class _SymptomTile extends StatelessWidget {
  final String name, category;
  final bool isSelected;
  final VoidCallback onTap;

  const _SymptomTile({
    required this.name,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  String _categoryEmoji(String cat) {
    switch (cat.toLowerCase()) {
      case 'respiratory': return '🫁';
      case 'digestive': return '🤢';
      case 'neurological': return '🧠';
      case 'cardiovascular': return '❤️';
      case 'musculoskeletal': return '🦴';
      case 'skin': return '🩹';
      case 'general': return '🌡️';
      case 'ent': return '👂';
      default: return '🩺';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignTokens.primaryContainer
              : DesignTokens.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? DesignTokens.primary.withValues(alpha: 0.5)
                : DesignTokens.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: DesignTokens.primary.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(_categoryEmoji(category),
                style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isSelected
                          ? DesignTokens.primaryDark
                          : DesignTokens.textStrong,
                    ),
                  ),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? DesignTokens.primary
                          : DesignTokens.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? Container(
                      key: const ValueKey('checked'),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: DesignTokens.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14),
                    )
                  : Container(
                      key: const ValueKey('unchecked'),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: DesignTokens.surfaceMuted,
                        shape: BoxShape.circle,
                        border: Border.all(color: DesignTokens.border),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
