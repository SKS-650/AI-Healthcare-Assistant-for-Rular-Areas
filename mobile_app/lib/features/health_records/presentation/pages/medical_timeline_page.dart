import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/health_records_provider.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/timeline/timeline_tile.dart';

class MedicalTimelinePage extends ConsumerWidget {
  const MedicalTimelinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeline = ref.watch(
      healthRecordsControllerProvider.select((state) => state.timeline),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Medical Timeline')),
      body: timeline.isEmpty
          ? const EmptyState(
              title: 'No timeline yet',
              message: 'Medical events will be organized by date here.',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: timeline.length,
              itemBuilder: (context, index) {
                return MedicalTimelineTile(
                  item: timeline[index],
                  isLast: index == timeline.length - 1,
                );
              },
            ),
    );
  }
}
