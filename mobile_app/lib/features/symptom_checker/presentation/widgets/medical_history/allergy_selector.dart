import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class AllergySelector extends StatefulWidget {
  final List<String> selectedAllergies;
  final void Function(List<String>) onAllergiesChanged;

  const AllergySelector({
    super.key,
    required this.selectedAllergies,
    required this.onAllergiesChanged,
  });

  @override
  State<AllergySelector> createState() => _AllergySelectorState();
}

class _AllergySelectorState extends State<AllergySelector> {
  final TextEditingController _ctrl = TextEditingController();
  static const _presets = [
    'Penicillin', 'Sulfa Drugs', 'Aspirin', 'Nuts', 'Dairy', 'Latex'
  ];

  void _add(String allergy) {
    final clean = allergy.trim();
    if (clean.isNotEmpty &&
        !widget.selectedAllergies.contains(clean)) {
      widget.onAllergiesChanged([...widget.selectedAllergies, clean]);
    }
    _ctrl.clear();
  }

  void _remove(String allergy) {
    widget.onAllergiesChanged(
        widget.selectedAllergies.where((a) => a != allergy).toList());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input row
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
                  controller: _ctrl,
                  decoration: const InputDecoration(
                    hintText: 'e.g., Pollen, Penicillin...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    hintStyle: TextStyle(
                        color: DesignTokens.textSubtle, fontSize: 13),
                  ),
                  onSubmitted: _add,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilledButton(
                  onPressed: () => _add(_ctrl.text),
                  style: FilledButton.styleFrom(
                    backgroundColor: DesignTokens.warning,
                    minimumSize: const Size(44, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Icon(Icons.add_rounded, size: 18),
                ),
              ),
            ],
          ),
        ),

        if (widget.selectedAllergies.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.selectedAllergies.map((a) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: DesignTokens.dangerContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: DesignTokens.danger.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(a,
                        style: const TextStyle(
                            color: DesignTokens.danger,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () => _remove(a),
                      child: const Icon(Icons.close_rounded,
                          size: 13, color: DesignTokens.danger),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],

        const Text('Common presets:',
            style: TextStyle(
                fontSize: 12,
                color: DesignTokens.textMuted,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _presets.map((p) {
            final added = widget.selectedAllergies.contains(p);
            return GestureDetector(
              onTap: () => added ? _remove(p) : _add(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: added
                      ? DesignTokens.dangerContainer
                      : DesignTokens.surfaceMuted,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: added
                        ? DesignTokens.danger.withValues(alpha: 0.4)
                        : DesignTokens.border,
                  ),
                ),
                child: Text(p,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: added
                            ? DesignTokens.danger
                            : DesignTokens.textMuted)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
