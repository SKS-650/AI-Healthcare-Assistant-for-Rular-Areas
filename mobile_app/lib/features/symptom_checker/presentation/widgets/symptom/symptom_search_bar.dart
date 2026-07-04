import 'package:flutter/material.dart';

class SymptomSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onVoicePressed;

  const SymptomSearchBar({
    super.key,
    required this.onChanged,
    this.onVoicePressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search symptoms (e.g., cough, headache)...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: onVoicePressed != null
            ? IconButton(
                icon: const Icon(Icons.mic, color: Colors.blue),
                onPressed: onVoicePressed,
              )
            : null,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}