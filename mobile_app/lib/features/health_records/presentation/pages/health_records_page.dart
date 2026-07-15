import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../controllers/health_records_state.dart';
import '../providers/health_records_provider.dart';
import 'lab_reports_page.dart';
import 'medical_history_page.dart';
import 'medical_images_page.dart';
import 'medical_profile_page.dart';
import 'medical_records_page.dart';
import 'medical_timeline_page.dart';
import 'prescriptions_page.dart';
import 'search_records_page.dart';
import 'upload_report_page.dart';

class HealthRecordsPage extends ConsumerWidget {
  const HealthRecordsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(healthRecordsControllerProvider);

    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: switch (state.status) {
        HealthRecordsStatus.initial ||
        HealthRecordsStatus.loading =>
          const _LoadingSkeleton(),
        HealthRecordsStatus.failure => _ErrorBody(
            message: state.errorMessage ?? 'Failed to load health records.',
            onRetry: () =>
                ref.read(healthRecordsControllerProvider.notifier).loadAll(),
          ),
        _ => _LoadedBody(state: state),
      },
    );
  }
}

// ─── Loaded body ──────────────────────────────────────────────────────────────

class _LoadedBody extends ConsumerWidget {
  final HealthRecordsState state;
  const _LoadedBody({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: DesignTokens.primary,
      onRefresh: () =>
          ref.read(healthRecordsControllerProvider.notifier).loadAll(),
      child: CustomScrollView(
        slivers: [
          _PHRSliverAppBar(state: state),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryStatsRow(state: state),
                const SizedBox(height: 8),
                _QuickNavGrid(state: state),
                const SizedBox(height: 4),
                _RecentTimelineSection(state: state),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SliverAppBar with health hero card ──────────────────────────────────────

class _PHRSliverAppBar extends StatelessWidget {
  final HealthRecordsState state;
  const _PHRSliverAppBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final profile = state.medicalProfile;
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: DesignTokens.background,
      foregroundColor: DesignTokens.textStrong,
      elevation: 0,
      scrolledUnderElevation: 1,
      actions: [
        IconButton(
          tooltip: 'Search',
          icon: const Icon(Icons.search_rounded),
          onPressed: () => _push(context, const SearchRecordsPage()),
        ),
        IconButton(
          tooltip: 'Upload',
          icon: const Icon(Icons.upload_file_rounded),
          onPressed: () => _push(context, const UploadReportPage()),
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF926EFF), Color(0xFF4F94FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          '📋 Health Records',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          profile?.bloodGroup != null
                              ? '🩸 ${profile!.bloodGroup}  •  '
                                  '📏 ${profile.heightCm?.toStringAsFixed(0) ?? '--'} cm  •  '
                                  '⚖️ ${profile.weightKg?.toStringAsFixed(1) ?? '--'} kg'
                              : 'Your Personal Health Record',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _push(context, const MedicalProfilePage()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_outline_rounded,
                              color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text('Profile',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        title: const Text(
          '📋 Health Records',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: DesignTokens.textStrong),
        ),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
      ),
    );
  }
}

// ─── Stats row ────────────────────────────────────────────────────────────────

class _SummaryStatsRow extends StatelessWidget {
  final HealthRecordsState state;
  const _SummaryStatsRow({required this.state});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _Stat('🩺', '${state.medicalHistory.length}', 'History',
          DesignTokens.primary),
      _Stat('💊', '${state.prescriptions.length}', 'Rx',
          DesignTokens.green),
      _Stat('🩻', '${state.medicalImages.length}', 'Scans',
          DesignTokens.blue),
      _Stat('🧪', '${state.labReports.length}', 'Labs',
          DesignTokens.orange),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        border: Border.all(color: DesignTokens.border),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: stats
            .map((s) => Expanded(
                  child: _StatCell(stat: s)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2),
                ))
            .toList(),
      ),
    );
  }
}

class _Stat {
  final String emoji, value, label;
  final Color color;
  const _Stat(this.emoji, this.value, this.label, this.color);
}

class _StatCell extends StatelessWidget {
  final _Stat stat;
  const _StatCell({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(stat.emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          stat.value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: stat.color,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(stat.label,
            style: const TextStyle(
                fontSize: 11,
                color: DesignTokens.textMuted,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ─── Quick nav grid ───────────────────────────────────────────────────────────

class _QuickNavGrid extends StatelessWidget {
  final HealthRecordsState state;
  const _QuickNavGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _NavAction('🩺', 'Medical\nHistory', DesignTokens.primary,
          () => _push(context, const MedicalHistoryPage())),
      _NavAction('💊', 'Prescriptions', DesignTokens.green,
          () => _push(context, const PrescriptionsPage())),
      _NavAction('🩻', 'Scans &\nImages', DesignTokens.blue,
          () => _push(context, const MedicalImagesPage())),
      _NavAction('🧪', 'Lab\nReports', DesignTokens.orange,
          () => _push(context, const LabReportsPage())),
      _NavAction('📅', 'Timeline', DesignTokens.pink,
          () => _push(context, const MedicalTimelinePage())),
      _NavAction('📄', 'All\nRecords', DesignTokens.teal,
          () => _push(context, const MedicalRecordsPage())),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              '⚡ Quick Access',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textStrong,
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: actions
                .asMap()
                .entries
                .map((e) => _NavCard(action: e.value)
                    .animate(delay: (e.key * 60).ms)
                    .fadeIn(duration: 350.ms)
                    .scale(begin: const Offset(0.85, 0.85)))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _NavAction {
  final String emoji, label;
  final Color color;
  final VoidCallback onTap;
  const _NavAction(this.emoji, this.label, this.color, this.onTap);
}

class _NavCard extends StatelessWidget {
  final _NavAction action;
  const _NavCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: action.color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: action.color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(action.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: action.color,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Recent Timeline section ──────────────────────────────────────────────────

class _RecentTimelineSection extends StatelessWidget {
  final HealthRecordsState state;
  const _RecentTimelineSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final events = state.timelineEvents.take(5).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 12),
            child: Row(
              children: [
                const Text(
                  '📅 Recent Activity',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: DesignTokens.textStrong),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _push(context, const MedicalTimelinePage()),
                  child: const Text(
                    'See all →',
                    style: TextStyle(
                        color: DesignTokens.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          if (events.isEmpty)
            _EmptyTimelineCard()
          else
            ...events.asMap().entries.map((e) {
              final event = e.value;
              return _TimelineEventCard(event: event)
                  .animate(delay: (e.key * 70).ms)
                  .fadeIn(duration: 350.ms)
                  .slideX(begin: 0.1);
            }),
        ],
      ),
    );
  }
}

class _EmptyTimelineCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.border),
      ),
      child: const Center(
        child: Column(
          children: [
            Text('📭', style: TextStyle(fontSize: 36)),
            SizedBox(height: 8),
            Text(
              'No health events yet',
              style: TextStyle(
                  color: DesignTokens.textMuted,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4),
            Text(
              'Add medical history or upload a prescription to get started.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: DesignTokens.textSubtle, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineEventCard extends StatelessWidget {
  final dynamic event;
  const _TimelineEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(event.eventType as String);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                event.emoji as String,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: DesignTokens.textStrong,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((event.description as String?) != null &&
                    (event.description as String).isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    event.description as String,
                    style: const TextStyle(
                        fontSize: 11, color: DesignTokens.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            DateFormat('d MMM').format(event.eventDate as DateTime),
            style: const TextStyle(
                fontSize: 11,
                color: DesignTokens.textSubtle,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
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

// ─── Loading skeleton ─────────────────────────────────────────────────────────

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: DesignTokens.border,
      highlightColor: DesignTokens.surface,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 120),
          const _SkeletonBox(height: 96, radius: 20),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: List.generate(
                6, (_) => const _SkeletonBox(height: double.infinity, radius: 16)),
          ),
          const SizedBox(height: 16),
          ...List.generate(
              4,
              (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: _SkeletonBox(height: 60, radius: 14),
                  )),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  final double radius;
  const _SkeletonBox({required this.height, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ─── Error body ───────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😔', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            const Text(
              'Could not load records',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.textStrong),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: DesignTokens.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                  backgroundColor: DesignTokens.primary,
                  foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

void _push(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
