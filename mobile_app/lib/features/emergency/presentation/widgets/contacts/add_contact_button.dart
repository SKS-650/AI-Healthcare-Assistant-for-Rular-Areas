import 'package:flutter/material.dart';

class AddContactButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AddContactButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.person_add_alt_1_rounded),
      label: const Text('Add Contact'),
    );
  }
}
