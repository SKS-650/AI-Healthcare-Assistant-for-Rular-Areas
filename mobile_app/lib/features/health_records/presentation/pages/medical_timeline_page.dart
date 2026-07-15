import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/timeline_event.dart';
import '../providers/health_records_provider.dart';

class MedicalTimelinePage extends ConsumerStatefulWidget {
  const MedicalTimelinePage({super.key});

  @override
  ConsumerState<MedicalTimelinePage> createState() =>
      _MedicalTimelinePageState();
}

class _MedicalTimelinePageState extends ConsumerState<MedicalTimelinePage> {
  String? _activeFilter;

  static const _filters = [
    (null,                   'All',         '📋'),
    ('medical_history',      'History',     '🩺'),
    ('prescription',         'Prescription','💊'),
    ('medical_image',        'Scans',       '🩻'),
    ('symptom_assessment',   'Symptoms',    '🤒'),
    ('chat_conversation',    'AI Chat',     '💬'),
    ('emergency_assessment', 'Emergency',   '🚨'),
  ];

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(
      healthRecordsControllerProvider.select((s) => s.timelineEvents),
    );

    final filtered = _activeFilter == null
        ? events
        : events.where((e) => e.eventType == _activeFilter).toList();

    // Group by year + month
    final grouped = _groupByYearMonth(filtered);

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Row(children: [
          Text('📅', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Text('Medical Timeline',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: DesignTokens.textStrong)),
        ]),
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final isActive = _activeFilter == f.$1;
                return FilterChip(
                  label: Text('${f.$3} ${f.$2}'),
                  selected: isActive,
                  onSelected: (_) {
                    setState(() => _activeFilter = f.$1);
                    ref
                        .read(healthRecordsControllerProvider.notifier)
                        .loadTimelineFiltered(f.$1);
                  },
                  selectedColor:
                      DesignTokens.primary.withValues(alpha: 0.15),
                  checkmarkColor: DesignTokens.primary,
                  labelStyle: TextStyle(
                    color: isActive
                        ? DesignTokens.primary
                        : DesignTokens.textMuted,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: isActive
                        ? DesignTokens.primary.withValues(alpha: 0.4)
                        : DesignTokens.border,
                  ),
                  backgroundColor: DesignTokens.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  showCheckmark: false,
                );
              },
            ),
          ),

          // Timeline
          Expanded(
            child: filtered.isEmpty
                ? _EmptyTimeline()
                : ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    itemCount: grouped.length,
                    itemBuilder: (_, i) =>
                        _TimelineGroup(group: grouped[i], groupIndex: i),
                  ),
          ),
        ],
      ),
    );
  }

  List<_EventGroup> _groupByYearMonth(List<TimelineEvent> events) {
    final Map<String, List<TimelineEvent>> map = {};
    for (final e in events) {
      final key = DateFormat('MMMM yyyy').format(e.eventDate);
      map.putIfAbsent(key, () => []).add(e);
    }
    return map.entries
        .map((e) => _EventGroup(monthLabel: e.key, events: e.value))
        .toList();
  }
}

class _EventGroup {
  final String monthLabel;
  final List<TimelineEvent> events;
  const _EventGroup({required this.monthLabel, required this.events});
}

// ─── Timeline group (one month) ───────────────────────────────────────────────

class _TimelineGroup extends StatelessWidget {
  final _EventGroup group;
  final int groupIndex;
  const _TimelineGroup({required this.group, required this.groupIndex});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [DesignTokens.primary, DesignTokens.blue],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                group.monthLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 1,
                color: DesignTokens.border,
              ),
            ),
            const SizedBox(width: 8),
            Text('${group.events.length} event${group.events.length == 1 ? '' : 's'}',
                style: const TextStyle(
                    fontSize: 11, color: DesignTokens.textSubtle)),
          ]),
        )
            .animate(delay: (groupIndex * 50).ms)
            .fadeIn(duration: 300.ms),

        // Events in this group
        ...group.events.asMap().entries.map((entry) => _TimelineTile(
              event: entry.value,
              isLast: entry.key == group.events.length - 1,
              delay: (groupIndex * 50 + entry.key * 60).ms,
            )),
      ],
    );
  }
}

// ─── Single timeline tile ─────────────────────────────────────────────────────

class _TimelineTile extends StatelessWidget {
  final TimelineEvent event;
  final bool isLast;
  final Duration delay;
  const _TimelineTile(
      {required this.event, required this.isLast, required this.delay});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(event.eventType);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline column (dot + line)
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: color.withValues(alpha: 0.4), width: 2),
                  ),
                  child: Center(
                    child: Text(event.emoji,
                        style: const TextStyle(fontSize: 16)),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            color.withValues(alpha: 0.4),
                            color.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Content card
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: DesignTokens.surface,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: color.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                        color: color.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: DesignTokens.textStrong,
                              letterSpacing: -0.2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _TypeBadge(event.typeLabel, color),
                    ]),
                    if (event.description != null &&
                        event.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        event.description!,
                        style: const TextStyle(
                            fontSize: 12,
                            color: DesignTokens.textMuted,
                            height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.access_time_rounded,
                          size: 12, color: DesignTokens.textSubtle),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('d MMM yyyy').format(event.eventDate),
                        style: const TextStyle(
                            fontSize: 11,
                            color: DesignTokens.textSubtle,
                            fontWeight: FontWeight.w500),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 350.ms)
        .slideX(begin: 0.06);
  }

  Color _colorFor(String type) {
    const map = {
      'medical_history':      DesignTokens.primary,
      'prescription':         DesignTokens.green,
      'medical_image':        DesignTokens.blue,
      'symptom_assessment':   DesignTokens.orange,
      'chat_conversation':    DesignTokens.teal,
      'emergency_assessment': DesignTokens.danger,
    };
    return map[type] ?? DesignTokens.primary;
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TypeBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color)),
      );
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📅', style: TextStyle(fontSize: 56)),
              SizedBox(height: 16),
              Text('No Timeline Events',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: DesignTokens.textStrong)),
              SizedBox(height: 8),
              Text(
                'Your complete health story will appear here as you add records.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: DesignTokens.textMuted, height: 1.5),
              ),
            ],
          ),
        ),
      );
}
