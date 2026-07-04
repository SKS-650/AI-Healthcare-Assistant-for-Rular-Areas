import 'package:flutter/material.dart';

class PreviousButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const PreviousButton({
    super.key,
    required this.onPressed,
    this.label = 'Back',
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}