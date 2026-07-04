import 'package:flutter/material.dart';

class AttachmentButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AttachmentButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Attach',
      onPressed: onPressed,
      icon: const Icon(Icons.attach_file_rounded),
    );
  }
}
