import 'package:flutter/material.dart';

class ReportAttachment extends StatelessWidget {
  final String fileName;

  const ReportAttachment({super.key, required this.fileName});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.attach_file),
      title: Text(fileName),
      trailing: const Icon(Icons.download_outlined),
    );
  }
}
