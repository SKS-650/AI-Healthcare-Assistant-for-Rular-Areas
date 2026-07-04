import 'package:flutter/material.dart';

class MedicationInput extends StatefulWidget {
  final List<String> initialMedications;
  final Function(List<String>) onMedicationsChanged;

  const MedicationInput({
    super.key,
    required this.initialMedications,
    required this.onMedicationsChanged,
  });

  @override
  State<MedicationInput> createState() => _MedicationInputState();
}

class _MedicationInputState extends State<MedicationInput> {
  final TextEditingController _medicationController = TextEditingController();

  void _submitMedication() {
    final text = _medicationController.text.trim();
    if (text.isNotEmpty && !widget.initialMedications.contains(text)) {
      final updatedList = [...widget.initialMedications, text];
      widget.onMedicationsChanged(updatedList);
    }
    _medicationController.clear();
  }

  void _removeMedication(String name) {
    final updatedList = widget.initialMedications.where((med) => med != name).toList();
    widget.onMedicationsChanged(updatedList);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _medicationController,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitMedication(),
          decoration: InputDecoration(
            labelText: 'Active Prescriptions / Supplements',
            hintText: 'Enter medicine name (e.g., Metformin 500mg)',
            prefixIcon: const Icon(Icons.medication_liquid),
            suffixIcon: IconButton(
              icon: const Icon(Icons.arrow_forward_rounded),
              onPressed: _submitMedication,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (widget.initialMedications.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: const Text(
              'No medications added yet.',
              style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.initialMedications.length,
            itemBuilder: (context, index) {
              final medication = widget.initialMedications[index];
              return Card(
                color: Colors.grey[50],
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.circle, size: 8, color: Theme.of(context).primaryColor),
                  title: Text(
                    medication,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: () => _removeMedication(medication),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  void dispose() {
    _medicationController.dispose();
    super.dispose();
  }
}