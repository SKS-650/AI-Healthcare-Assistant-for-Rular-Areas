import 'package:flutter/material.dart';

import '../../../domain/entities/medical_record.dart';

class SearchResultCard extends StatelessWidget {
  final MedicalRecord record;
  final VoidCallback? onTap;

  const SearchResultCard({super.key, required this.record, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.manage_search),
        title: Text(record.title),
        subtitle: Text(
          record.summary,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
