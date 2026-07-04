import 'package:flutter/material.dart';

class CallButton extends StatelessWidget {
  final String phoneNumber;

  const CallButton({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: 'Call',
      icon: const Icon(Icons.call_outlined),
      onPressed: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Call $phoneNumber')));
      },
    );
  }
}
