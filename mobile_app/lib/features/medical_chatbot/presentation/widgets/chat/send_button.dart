import 'package:flutter/material.dart';

class SendButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const SendButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      tooltip: 'Send',
      onPressed: onPressed,
      icon: const Icon(Icons.send_rounded),
    );
  }
}
