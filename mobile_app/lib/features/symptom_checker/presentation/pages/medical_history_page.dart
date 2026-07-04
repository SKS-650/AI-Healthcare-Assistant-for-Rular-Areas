import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../providers/symptom_provider.dart';

class MedicalHistoryPage extends ConsumerStatefulWidget {
  const MedicalHistoryPage({super.key});

  @override
  ConsumerState<MedicalHistoryPage> createState() =>
      _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends ConsumerState<MedicalHistoryPage> {
  final _conditionCtrl = TextEditingController();
  final _allergyCtrl = TextEditingController();
  final _medCtrl = TextEditingController();

  @override
  void dispose() {
    _conditionCtrl.dispose();
    _allergyCtrl.dispose();
    _medCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              color: DesignTokens.orangeContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: DesignTokens.orange.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Text('🏥', style: TextStyle(fontSize: 22)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Share existing conditions, allergies and medications for a more accurate result.',
                    style: TextStyle(
                      color: Color(0xFF7C2D12),
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

          _ChipInputSection(
            emoji: '💊',
            title: 'Chronic Conditions',
            hint: 'e.g., Diabetes, Hypertension',
            chips: state.chronicConditions,
            controller: _conditionCtrl,
            chipColor: DesignTokens.danger,
            onAdd: () {
              final val = _conditionCtrl.text.trim();
              if (val.isNotEmpty) {
                final updated = [...state.chronicConditions, val];
                notifier.updateMedicalHistory(conditions: updated);
                _conditionCtrl.clear();
              }
            },
            onRemove: (item) {
              final updated = state.chronicConditions
                  .where((c) => c != item)
                  .toList();
              notifier.updateMedicalHistory(conditions: updated);
            },
          ),

          const SizedBox(height: 20),

          _ChipInputSection(
            emoji: '⚠️',
            title: 'Allergies',
            hint: 'e.g., Penicillin, Sulfa drugs',
            chips: state.allergies,
            controller: _allergyCtrl,
            chipColor: DesignTokens.warning,
            onAdd: () {
              final val = _allergyCtrl.text.trim();
              if (val.isNotEmpty) {
                final updated = [...state.allergies, val];
                notifier.updateMedicalHistory(allergies: updated);
                _allergyCtrl.clear();
              }
            },
            onRemove: (item) {
              final updated =
                  state.allergies.where((a) => a != item).toList();
              notifier.updateMedicalHistory(allergies: updated);
            },
          ),

          const SizedBox(height: 20),

          _ChipInputSection(
            emoji: '💉',
            title: 'Current Medications',
            hint: 'e.g., Metformin 500mg',
            chips: state.currentMedications,
            controller: _medCtrl,
            chipColor: DesignTokens.blue,
            onAdd: () {
              final val = _medCtrl.text.trim();
              if (val.isNotEmpty) {
                final updated = [...state.currentMedications, val];
                notifier.updateMedicalHistory(medications: updated);
                _medCtrl.clear();
              }
            },
            onRemove: (item) {
              final updated =
                  state.currentMedications.where((m) => m != item).toList();
              notifier.updateMedicalHistory(medications: updated);
            },
          ),

          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DesignTokens.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Text('ℹ️', style: TextStyle(fontSize: 14)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Leave blank if none. This information is private and never shared.',
                    style: TextStyle(
                        color: DesignTokens.textMuted,
                        fontSize: 12,
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: () => notifier.nextStep(),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Next: Lifestyle',
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

class _ChipInputSection extends StatelessWidget {
  final String emoji, title, hint;
  final List<String> chips;
  final TextEditingController controller;
  final Color chipColor;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  const _ChipInputSection({
    required this.emoji,
    required this.title,
    required this.hint,
    required this.chips,
    required this.controller,
    required this.chipColor,
    required this.onAdd,
    required this.onRemove,
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
        Container(
          decoration: BoxDecoration(
            color: DesignTokens.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: DesignTokens.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    hintStyle: const TextStyle(
                        color: DesignTokens.textSubtle, fontSize: 13),
                  ),
                  onSubmitted: (_) => onAdd(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilledButton(
                  onPressed: onAdd,
                  style: FilledButton.styleFrom(
                    backgroundColor: chipColor,
                    minimumSize: const Size(50, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Icon(Icons.add_rounded, size: 18),
                ),
              ),
            ],
          ),
        ),
        if (chips.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: chips.map((item) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: chipColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: chipColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item,
                      style: TextStyle(
                        color: chipColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () => onRemove(item),
                      child: Icon(Icons.close_rounded,
                          size: 13, color: chipColor),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
