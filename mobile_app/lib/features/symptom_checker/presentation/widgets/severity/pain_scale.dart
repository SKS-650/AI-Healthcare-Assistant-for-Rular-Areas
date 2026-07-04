import 'package:flutter/material.dart';

class PainScale extends StatelessWidget {
  final double selectedValue;
  final ValueChanged<double> onSelected;

  const PainScale({
    super.key,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        final currentVal = ((index * 2) + 2).toDouble();
        final isSelected = selectedValue == currentVal;

        return InkWell(
          onTap: () => onSelected(currentVal),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${currentVal.toStringAsFixed(0)}+',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      }),
    );
  }
}