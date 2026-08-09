import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/timeline_event.dart';
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
        // failure and all other statuses → still show the loaded body.
        // A slim error banner is rendered inside _LoadedBody when errorMessage
        // is non-null, so the user sees partial data AND a retry option.
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
                // Non-blocking error banner — shows partial data below it
                if (state.errorMessage != null)
                  _ErrorBanner(
                    message: state.errorMessage!,
                    onRetry: () => ref
                        .read(healthRecordsControllerProvider.notifier)
                        .loadAll(),
                  ),
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
    final hasVitals = profile?.bloodGroup != null ||
        profile?.heightCm != null ||
        profile?.weightKg != null;

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      stretch: false,
      // The AppBar gradient background colour when collapsed/pinned
      backgroundColor: const Color(0xFF7B5CFF),
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 2,
      shadowColor: const Color(0xFF7B5CFF).withValues(alpha: 0.4),
      // ── Collapsed toolbar title (shown when pinned) ──────────────────────
      title: const Row(
        children: [
          Icon(Icons.medical_information_rounded, size: 20, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Health Records',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      // ── Action icons ─────────────────────────────────────────────────────
      actions: [
        IconButton(
          tooltip: 'Search records',
          icon: const Icon(Icons.search_rounded, color: Colors.white),
          onPressed: () => _push(context, const SearchRecordsPage()),
        ),
        IconButton(
          tooltip: 'Upload report',
          icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
          onPressed: () => _push(context, const UploadReportPage()),
        ),
        const SizedBox(width: 4),
      ],
      // ── Expanded hero area ───────────────────────────────────────────────
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _HeroBackground(
          hasVitals: hasVitals,
          profile: profile,
          onProfileTap: () => _push(context, const MedicalProfilePage()),
        ),
      ),
    );
  }
}

// ─── Hero gradient background ─────────────────────────────────────────────────

class _HeroBackground extends StatelessWidget {
  final bool hasVitals;
  final dynamic profile;
  final VoidCallback onProfileTap;
  const _HeroBackground({
    required this.hasVitals,
    required this.profile,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9B5DFF), Color(0xFF4F8AFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          // Top padding leaves room for the collapsed AppBar toolbar height (~56)
          // so the hero content sits in the expanded portion only.
          padding: const EdgeInsets.fromLTRB(20, 64, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Page heading ─────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Health Records',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hasVitals
                              ? 'Your personal health profile'
                              : 'Your Personal Health Record',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Profile button — always visible in expanded area
                  GestureDetector(
                    onTap: onProfileTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1.2),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_outline_rounded,
                              color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // ── Vitals chips row ─────────────────────────────────────────
              if (hasVitals) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (profile?.bloodGroup != null)
                      _VitalChip(
                          icon: Icons.water_drop_rounded,
                          label: profile!.bloodGroup!,
                          accent: const Color(0xFFFF6B8A)),
                    if (profile?.heightCm != null)
                      _VitalChip(
                          icon: Icons.straighten_rounded,
                          label:
                              '${profile!.heightCm!.toStringAsFixed(0)} cm',
                          accent: const Color(0xFF64C8FF)),
                    if (profile?.weightKg != null)
                      _VitalChip(
                          icon: Icons.monitor_weight_outlined,
                          label:
                              '${profile!.weightKg!.toStringAsFixed(1)} kg',
                          accent: const Color(0xFFA8FFD4)),
                    if (profile?.bmi != null)
                      _VitalChip(
                          icon: Icons.health_and_safety_rounded,
                          label: 'BMI ${profile!.bmi!.toStringAsFixed(1)}',
                          accent: const Color(0xFFFFD580)),
                  ],
                ),
              ] else ...[
                // Prompt when no profile is set
                GestureDetector(
                  onTap: onProfileTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_circle_outline_rounded,
                            color: Colors.white70, size: 15),
                        const SizedBox(width: 6),
                        Text(
                          'Set up your health profile',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Vital chip pill ──────────────────────────────────────────────────────────

class _VitalChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  const _VitalChip(
      {required this.icon, required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: accent),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
      _Stat('🔍', '${state.medicalImages.length}', 'Scans',
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
      _NavAction('🔍', 'Scans &\nImages', DesignTokens.blue,
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
  final TimelineEvent event;
  const _TimelineEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(event.eventType);
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
                event.emoji,
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
                  event.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: DesignTokens.textStrong,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (event.description != null &&
                    event.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    event.description!,
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
            DateFormat('d MMM').format(event.eventDate),
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

// ─── Error banner (non-blocking — content still renders below) ────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: DesignTokens.danger.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DesignTokens.danger.withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        const Text('⚠️', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 12,
              color: DesignTokens.danger,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: onRetry,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Retry',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: DesignTokens.danger)),
        ),
      ]),
    );
  }
}


void _push(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
