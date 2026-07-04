import 'package:flutter/material.dart';

class VoiceInputButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onPressed;

  const VoiceInputButton({
    super.key,
    required this.isListening,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: isListening ? Colors.red : Theme.of(context).primaryColor,
      onPressed: onPressed,
      child: Icon(
        isListening ? Icons.stop : Icons.mic,
        color: Colors.white,
      ),
    );
  }
}