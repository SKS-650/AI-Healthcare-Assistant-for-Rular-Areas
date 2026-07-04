import 'package:flutter/material.dart';

class UploadOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const UploadOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
