import 'package:flutter/material.dart';

class UploadProgress extends StatelessWidget {
  const UploadProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          LinearProgressIndicator(),
          SizedBox(height: 8),
          Text('Uploading report...'),
        ],
      ),
    );
  }
}
