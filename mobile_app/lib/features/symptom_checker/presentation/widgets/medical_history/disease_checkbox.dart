import 'package:flutter/material.dart';

class DiseaseCheckbox extends StatelessWidget {
  final String diseaseName;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;

  const DiseaseCheckbox({
    super.key,
    required this.diseaseName,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: CheckboxListTile(
        title: Text(
          diseaseName,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        value: isChecked,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}