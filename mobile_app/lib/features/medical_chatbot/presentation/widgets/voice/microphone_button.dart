import 'package:flutter/material.dart';

class MicrophoneButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onPressed;

  const MicrophoneButton({
    super.key,
    required this.isListening,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 96,
      child: IconButton.filled(
        tooltip: isListening ? 'Stop listening' : 'Start listening',
        onPressed: onPressed,
        iconSize: 42,
        icon: Icon(isListening ? Icons.stop_rounded : Icons.mic_rounded),
      ),
    );
  }
}
