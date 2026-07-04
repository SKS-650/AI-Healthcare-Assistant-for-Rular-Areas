import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/emergency_history.dart';
import '../providers/emergency_provider.dart';

class EmergencyHistoryPage extends ConsumerWidget {
  const EmergencyHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(emergencyControllerProvider);

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        foregroundColor: const Color(0xFF1A1035),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: DesignTokens.textStrong, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          children: [
            Text('ðŸ“‹', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text('Emergency History'),
          ],
        ),
      ),
      body: state.history.isEmpty
          ? const _EmptyHistory()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemCount: state.history.length,
              itemBuilder: (context, i) => _HistoryCard(history: state.history[i]),
            ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final EmergencyHistory history;
  const _HistoryCard({required this.history});

  @override
  Widget build(BuildContext context) {
    final isSos = history.event.sosSent;
    final color = isSos ? DesignTokens.danger : DesignTokens.warning;
    final bgColor = isSos ? DesignTokens.dangerContainer : DesignTokens.warningContainer;

    final dateStr = _formatDate(history.savedAt);
    final timeStr = _formatTime(history.savedAt);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                isSos ? 'ðŸ†˜' : 'âš ï¸',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        history.event.type.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: DesignTokens.textStrong,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isSos ? 'ðŸ†˜ SOS' : 'ðŸ” Detected',
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  history.actionTaken,
                  style: const TextStyle(
                    color: DesignTokens.textMuted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text('ðŸ“', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    Text(
                      history.event.location,
                      style: const TextStyle(
                        color: DesignTokens.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'ðŸ“… $dateStr â€¢ â° $timeStr',
                      style: const TextStyle(
                        color: DesignTokens.textSubtle,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ðŸ“‹', style: TextStyle(fontSize: 50)),
            SizedBox(height: 16),
            Text(
              'No emergency history',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: DesignTokens.textStrong,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'SOS alerts and emergency detections\nwill appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DesignTokens.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
