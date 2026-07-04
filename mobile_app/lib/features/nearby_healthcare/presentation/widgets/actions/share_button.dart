import 'package:flutter/material.dart';

class ShareButton extends StatelessWidget {
  final String label;

  const ShareButton({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Share',
      icon: const Icon(Icons.ios_share_outlined),
      onPressed: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Share $label')));
      },
    );
  }
}
