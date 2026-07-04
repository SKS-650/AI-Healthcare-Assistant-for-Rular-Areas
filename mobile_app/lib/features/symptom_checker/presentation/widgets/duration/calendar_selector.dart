import 'package:flutter/material.dart';

class CalendarSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const CalendarSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 90)),
          lastDate: DateTime.now(),
        );
        if (picked != null && picked != selectedDate) {
          onDateSelected(picked);
        }
      },
      icon: const Icon(Icons.calendar_month),
      label: Text(
        'Symptom Onset: ${selectedDate.toLocal().toString().split(' ')[0]}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}