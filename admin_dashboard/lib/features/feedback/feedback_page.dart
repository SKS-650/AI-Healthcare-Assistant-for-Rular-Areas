import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../shared/widgets/data_table_card.dart';
import '../../shared/widgets/stat_card.dart';
import 'feedback_provider.dart';

class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({super.key});
  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedbackProvider);
    final notifier = ref.read(feedbackProvider.notifier);
    final s = state.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          _buildHeader(context, notifier),
          const SizedBox(height: 20),
          // ── Stats grid ────────────────────────────────────────────────
          _buildStatsGrid(context, s),
          const SizedBox(height: 20),
          // ── Category + Priority breakdown ─────────────────────────────
          if (s.total > 0) ...[
            _buildBreakdownRow(context, s),
            const SizedBox(height: 20),
          ],
          // ── Error ─────────────────────────────────────────────────────
          if (state.error != null)
            _ErrorBanner(message: state.error!, onRetry: notifier.reload),
          // ── Table ─────────────────────────────────────────────────────
          _buildTable(context, state, notifier),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FeedbackNotifier notifier) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('User Feedback',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700))
                  .animate()
                  .fadeIn(duration: 400.ms),
              Text('Review, manage and respond to user-submitted feedback',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.lightTextMuted))
                  .animate()
                  .fadeIn(delay: 100.ms),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: notifier.reload,
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text('Refresh'),
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildStatsGrid(BuildContext context, FeedbackStats s) {
    return LayoutBuilder(builder: (ctx, cst) {
      final cols = cst.maxWidth > 900 ? 4 : cst.maxWidth > 600 ? 3 : 2;
      return GridView.count(
        crossAxisCount: cols,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          StatCard(
            title: 'Total Feedback',
            value: '${s.total}',
            subtitle: '+${s.todayCount} today',
            icon: Icons.feedback_rounded,
            color: AppColors.primary,
            animDelay: 0,
          ),
          StatCard(
            title: 'Pending Review',
            value: '${s.pending}',
            subtitle: 'Awaiting action',
            icon: Icons.pending_actions_rounded,
            color: AppColors.warning,
            animDelay: 80,
          ),
          StatCard(
            title: 'Resolved',
            value: '${s.resolved}',
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
            animDelay: 160,
          ),
          StatCard(
            title: 'Avg Rating',
            value: s.avgRating > 0 ? s.avgRating.toStringAsFixed(1) : '—',
            subtitle: 'Out of 5 stars',
            icon: Icons.star_rounded,
            color: AppColors.accent,
            animDelay: 240,
          ),
          StatCard(
            title: 'In Progress',
            value: '${s.inProgress}',
            icon: Icons.timelapse_rounded,
            color: AppColors.info,
            animDelay: 320,
          ),
          StatCard(
            title: 'This Week',
            value: '${s.thisWeekCount}',
            icon: Icons.calendar_view_week_rounded,
            color: AppColors.primaryLight,
            animDelay: 400,
          ),
          StatCard(
            title: 'Reviewed',
            value: '${s.reviewed}',
            icon: Icons.rate_review_rounded,
            color: AppColors.accentLight,
            animDelay: 480,
          ),
          StatCard(
            title: 'Dismissed',
            value: '${s.dismissed}',
            icon: Icons.cancel_rounded,
            color: AppColors.lightTextMuted,
            animDelay: 560,
          ),
        ],
      );
    });
  }

  Widget _buildBreakdownRow(BuildContext context, FeedbackStats s) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _BreakdownCard(title: 'By Category', data: s.byCategory, colorMap: _categoryColors)),
        const SizedBox(width: 16),
        Expanded(child: _BreakdownCard(title: 'By Priority', data: s.byPriority, colorMap: _priorityColors)),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildTable(BuildContext context, FeedbackState state, FeedbackNotifier notifier) {
    return DataTableCard(
      title: 'All Feedback',
      isLoading: state.isLoading,
      totalRows: state.total,
      currentPage: state.page,
      pageSize: state.pageSize,
      onPageChanged: notifier.goToPage,
      searchBar: SearchField(
        controller: _searchCtrl,
        hint: 'Search by title or message...',
        onChanged: (v) { if (v.isEmpty || v.length >= 2) notifier.setSearch(v); },
      ),
      filters: [
        _DropFilter<String?>(
          value: state.categoryFilter,
          hint: 'All categories',
          items: [null, 'general', 'bug_report', 'feature_request', 'chatbot',
              'emergency', 'health_records', 'symptom_checker', 'ui_ux', 'performance', 'other'],
          labelOf: (v) => v == null ? 'All categories' : v.replaceAll('_', ' ').toUpperCase(),
          onChanged: notifier.setCategoryFilter,
        ),
        _DropFilter<String?>(
          value: state.statusFilter,
          hint: 'All statuses',
          items: [null, 'pending', 'reviewed', 'in_progress', 'resolved', 'dismissed'],
          labelOf: (v) => v == null ? 'All statuses' : v.replaceAll('_', ' ').toUpperCase(),
          onChanged: notifier.setStatusFilter,
        ),
        _DropFilter<String?>(
          value: state.priorityFilter,
          hint: 'All priorities',
          items: [null, 'low', 'normal', 'high', 'critical'],
          labelOf: (v) => v == null ? 'All priorities' : v.toUpperCase(),
          onChanged: notifier.setPriorityFilter,
        ),
        _DropFilter<int?>(
          value: state.ratingFilter,
          hint: 'Any rating',
          items: [null, 1, 2, 3, 4, 5],
          labelOf: (v) => v == null ? 'Any rating' : '${'★' * v}',
          onChanged: notifier.setRatingFilter,
        ),
      ],
      columns: const [
        DataColumn(label: Text('User')),
        DataColumn(label: Text('Category')),
        DataColumn(label: Text('Rating')),
        DataColumn(label: Text('Title / Message')),
        DataColumn(label: Text('Module')),
        DataColumn(label: Text('Priority')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Platform')),
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Actions')),
      ],
      rows: state.items.map((fb) => _buildRow(context, fb, notifier)).toList(),
    ).animate().fadeIn(delay: 300.ms);
  }

  DataRow _buildRow(BuildContext context, FeedbackItem fb, FeedbackNotifier notifier) {
    return DataRow(cells: [
      DataCell(_UserCell(item: fb)),
      DataCell(_CategoryBadge(category: fb.category)),
      DataCell(_RatingStars(rating: fb.rating)),
      DataCell(SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (fb.title != null)
              Text(fb.title!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  overflow: TextOverflow.ellipsis),
            Text(fb.message,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
                maxLines: fb.title != null ? 1 : 2),
          ],
        ),
      )),
      DataCell(Text(fb.module ?? '—', style: Theme.of(context).textTheme.bodySmall)),
      DataCell(_PriorityBadge(priority: fb.priority)),
      DataCell(_StatusBadge(status: fb.status)),
      DataCell(_PlatformChip(platform: fb.platform)),
      DataCell(Text(DateFormat('MMM d, y').format(fb.createdAt),
          style: Theme.of(context).textTheme.bodySmall)),
      DataCell(_FeedbackActions(item: fb, notifier: notifier)),
    ]);
  }

  static const _categoryColors = {
    'bug_report': AppColors.error, 'feature_request': AppColors.accent,
    'chatbot': AppColors.info, 'emergency': AppColors.riskCritical,
    'health_records': AppColors.success, 'symptom_checker': AppColors.warning,
    'ui_ux': AppColors.primary, 'performance': AppColors.riskHigh,
    'general': AppColors.lightTextMuted, 'other': AppColors.lightTextLight,
  };

  static const _priorityColors = {
    'critical': AppColors.riskCritical, 'high': AppColors.riskHigh,
    'normal': AppColors.info, 'low': AppColors.riskLow,
  };
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _BreakdownCard extends StatelessWidget {
  final String title;
  final Map<String, int> data;
  final Map<String, Color> colorMap;
  const _BreakdownCard({required this.title, required this.data, required this.colorMap});

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0, (a, b) => a + b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (data.isEmpty)
              Text('No data yet', style: Theme.of(context).textTheme.bodySmall)
            else
              ...data.entries.map((e) {
                final color = colorMap[e.key] ?? AppColors.primary;
                final pct = total > 0 ? e.value / total : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Container(width: 10, height: 10,
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
                    const SizedBox(width: 8),
                    Expanded(child: Text(e.key.replaceAll('_', ' ').toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall)),
                    const SizedBox(width: 8),
                    SizedBox(width: 50,
                        child: LinearProgressIndicator(value: pct.toDouble(), minHeight: 6,
                            backgroundColor: color.withOpacity(0.15),
                            valueColor: AlwaysStoppedAnimation(color))),
                    const SizedBox(width: 8),
                    Text('${e.value}', style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                  ]),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _UserCell extends StatelessWidget {
  final FeedbackItem item;
  const _UserCell({required this.item});
  @override
  Widget build(BuildContext context) {
    if (item.isAnonymous) {
      return Row(children: [
        Container(width: 28, height: 28,
            decoration: BoxDecoration(color: AppColors.lightSurface2,
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.person_off_rounded, size: 14, color: AppColors.lightTextMuted)),
        const SizedBox(width: 8),
        Text('Anonymous', style: Theme.of(context).textTheme.bodySmall),
      ]);
    }
    final name = item.userName ?? 'Unknown';
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
      if (item.userEmail != null)
        Text(item.userEmail!, style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: AppColors.lightTextMuted)),
    ]);
  }
}

class _RatingStars extends StatelessWidget {
  final int? rating;
  const _RatingStars({this.rating});
  @override
  Widget build(BuildContext context) {
    if (rating == null) return Text('—', style: Theme.of(context).textTheme.bodySmall);
    return Row(mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (i) => Icon(
          i < rating! ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 12,
          color: i < rating! ? AppColors.warning : AppColors.lightTextLight,
        )));
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge({required this.category});
  static const _colors = {
    'bug_report': AppColors.error, 'feature_request': AppColors.accent,
    'chatbot': AppColors.info, 'emergency': AppColors.riskCritical,
    'health_records': AppColors.success, 'symptom_checker': AppColors.warning,
    'ui_ux': AppColors.primary, 'performance': AppColors.riskHigh,
    'general': AppColors.lightTextMuted,
  };
  @override
  Widget build(BuildContext context) {
    final color = _colors[category] ?? AppColors.lightTextMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(category.replaceAll('_', ' ').toUpperCase(),
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;
  const _PriorityBadge({required this.priority});
  Color get _color => switch (priority) {
        'critical' => AppColors.riskCritical, 'high' => AppColors.riskHigh,
        'low' => AppColors.riskLow, _ => AppColors.info,
      };
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
        child: Text(priority.toUpperCase(),
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _color)),
      );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  Color get _color => switch (status) {
        'resolved' => AppColors.success, 'in_progress' => AppColors.info,
        'reviewed' => AppColors.accent, 'dismissed' => AppColors.lightTextMuted,
        _ => AppColors.warning, // pending
      };
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
        child: Text(status.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _color)),
      );
}

class _PlatformChip extends StatelessWidget {
  final String? platform;
  const _PlatformChip({this.platform});
  @override
  Widget build(BuildContext context) {
    if (platform == null) return Text('—', style: Theme.of(context).textTheme.bodySmall);
    final icon = switch (platform!.toLowerCase()) {
      'android' => Icons.android_rounded,
      'ios' => Icons.apple_rounded,
      _ => Icons.web_rounded,
    };
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: AppColors.lightTextMuted),
      const SizedBox(width: 4),
      Text(platform!.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
    ]);
  }
}

// ── Actions widget ────────────────────────────────────────────────────────────

class _FeedbackActions extends StatelessWidget {
  final FeedbackItem item;
  final FeedbackNotifier notifier;
  const _FeedbackActions({required this.item, required this.notifier});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Tooltip(message: 'View & Manage',
            child: IconButton(
              icon: const Icon(Icons.visibility_rounded, size: 16, color: AppColors.primary),
              onPressed: () => _showDetail(context),
            )),
        Tooltip(message: 'Quick Status',
            child: IconButton(
              icon: const Icon(Icons.edit_note_rounded, size: 16, color: AppColors.accent),
              onPressed: () => _showQuickEdit(context),
            )),
        Tooltip(message: 'Delete',
            child: IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
              onPressed: () => _confirmDelete(context),
            )),
      ]);

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _FeedbackDetailDialog(item: item, notifier: notifier),
    );
  }

  void _showQuickEdit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _QuickEditDialog(item: item, notifier: notifier),
    );
  }

  Future<void> _confirmDelete(BuildContext ctx) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (dlg) => AlertDialog(
        title: const Text('Delete Feedback'),
        content: const Text('This will permanently remove this feedback entry.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dlg, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(dlg, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final deleted = await notifier.deleteFeedback(item.id);
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(deleted ? 'Feedback deleted' : 'Failed to delete'),
        backgroundColor: deleted ? AppColors.success : AppColors.error,
      ));
    }
  }
}

// ── Detail dialog ─────────────────────────────────────────────────────────────

class _FeedbackDetailDialog extends StatelessWidget {
  final FeedbackItem item;
  final FeedbackNotifier notifier;
  const _FeedbackDetailDialog({required this.item, required this.notifier});

  @override
  Widget build(BuildContext context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580, maxHeight: 700),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  _CategoryBadge(category: item.category),
                  const SizedBox(width: 10),
                  Text('Feedback Details', style: Theme.of(context).textTheme.headlineSmall),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context)),
                ]),
                const Divider(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _row(context, 'Submitted by',
                          item.isAnonymous ? 'Anonymous' : (item.userName ?? 'Unknown')),
                      if (!item.isAnonymous && item.userEmail != null)
                        _row(context, 'Email', item.userEmail!),
                      _row(context, 'Category', item.category.replaceAll('_', ' ')),
                      if (item.module != null) _row(context, 'Module', item.module!),
                      if (item.rating != null)
                        _row(context, 'Rating', '${'★' * item.rating!}${'☆' * (5 - item.rating!)} (${item.rating}/5)'),
                      _row(context, 'Priority', item.priority.toUpperCase()),
                      _row(context, 'Status', item.status.replaceAll('_', ' ').toUpperCase()),
                      if (item.platform != null) _row(context, 'Platform', item.platform!),
                      if (item.appVersion != null) _row(context, 'App Version', item.appVersion!),
                      _row(context, 'Submitted', DateFormat('MMMM d, y HH:mm').format(item.createdAt)),
                      if (item.resolvedAt != null)
                        _row(context, 'Resolved', DateFormat('MMMM d, y HH:mm').format(item.resolvedAt!)),
                      const SizedBox(height: 12),
                      if (item.title != null) ...[
                        Text('Title', style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w700, color: AppColors.lightTextMuted)),
                        const SizedBox(height: 4),
                        Text(item.title!, style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                      ],
                      Text('Message', style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(fontWeight: FontWeight.w700, color: AppColors.lightTextMuted)),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.lightSurface2,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.lightBorder),
                        ),
                        child: Text(item.message, style: Theme.of(context).textTheme.bodyMedium),
                      ),
                      if (item.adminNotes != null) ...[
                        const SizedBox(height: 12),
                        Text('Admin Notes', style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w700, color: AppColors.lightTextMuted)),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.warningSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                          ),
                          child: Text(item.adminNotes!, style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ],
                    ]),
                  ),
                ),
                const Divider(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(context: context,
                          builder: (_) => _QuickEditDialog(item: item, notifier: notifier));
                    },
                    child: const Text('Edit Status'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                ]),
              ],
            ),
          ),
        ),
      );

  Widget _row(BuildContext context, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 130, child: Text(label,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.lightTextMuted, fontWeight: FontWeight.w600))),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(fontWeight: FontWeight.w500))),
        ]),
      );
}

// ── Quick edit dialog ─────────────────────────────────────────────────────────

class _QuickEditDialog extends StatefulWidget {
  final FeedbackItem item;
  final FeedbackNotifier notifier;
  const _QuickEditDialog({required this.item, required this.notifier});
  @override
  State<_QuickEditDialog> createState() => _QuickEditDialogState();
}

class _QuickEditDialogState extends State<_QuickEditDialog> {
  late String _status;
  late String _priority;
  late final TextEditingController _notesCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.item.status;
    _priority = widget.item.priority;
    _notesCtrl = TextEditingController(text: widget.item.adminNotes ?? '');
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text('Manage Feedback', style: Theme.of(context).textTheme.headlineSmall),
              if (widget.item.title != null) ...[
                const SizedBox(height: 6),
                Text(widget.item.title!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.lightTextMuted)),
              ],
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status', isDense: true),
                items: ['pending', 'reviewed', 'in_progress', 'resolved', 'dismissed']
                    .map((s) => DropdownMenuItem(value: s,
                        child: Text(s.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority', isDense: true),
                items: ['low', 'normal', 'high', 'critical']
                    .map((p) => DropdownMenuItem(value: p,
                        child: Text(p.toUpperCase(), style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (v) => setState(() => _priority = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Admin Notes (internal)',
                  hintText: 'Optional notes visible only to admins...',
                  isDense: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Changes'),
                )),
              ]),
            ]),
          ),
        ),
      );

  Future<void> _save() async {
    setState(() => _saving = true);
    final ok = await widget.notifier.updateFeedback(
      widget.item.id,
      status: _status,
      priority: _priority,
      adminNotes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Feedback updated successfully' : 'Failed to update'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ));
    }
  }
}

// ── Generic dropdown filter ───────────────────────────────────────────────────

class _DropFilter<T> extends StatelessWidget {
  final T value;
  final String hint;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;
  const _DropFilter({
    required this.value, required this.hint,
    required this.items, required this.labelOf, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 40,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            hint: Text(hint, style: const TextStyle(fontSize: 13)),
            items: items.map((v) => DropdownMenuItem<T>(value: v,
                child: Text(labelOf(v), style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: (v) => onChanged(v as T),
            isDense: true,
          ),
        ),
      );
}

// ── Error banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.errorSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(message,
              style: const TextStyle(color: AppColors.error, fontSize: 13))),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ]),
      );
}
