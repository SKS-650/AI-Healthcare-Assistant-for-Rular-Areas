import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class SleepSelector extends StatelessWidget {
  final int currentHours;
  final ValueChanged<int> onHoursChanged;

  const SleepSelector({
    super.key,
    required this.currentHours,
    required this.onHoursChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isOptimal = currentHours >= 7 && currentHours <= 9;
    final color = isOptimal ? DesignTokens.success : DesignTokens.warning;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('😴', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            const Expanded(
              child: Text('Average Sleep Duration',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: DesignTokens.textStrong)),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$currentHours hrs/night',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.15),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.12),
            trackHeight: 5,
          ),
          child: Slider(
            value: currentHours.toDouble(),
            min: 3.0,
            max: 12.0,
            divisions: 9,
            label: '$currentHours hrs',
            onChanged: (v) => onHoursChanged(v.toInt()),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('3h',
                style: TextStyle(
                    color: DesignTokens.textSubtle,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
            Text(
              isOptimal ? '✅ Optimal sleep' : '⚠️ Suboptimal sleep',
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w700),
            ),
            const Text('12h',
                style: TextStyle(
                    color: DesignTokens.textSubtle,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
