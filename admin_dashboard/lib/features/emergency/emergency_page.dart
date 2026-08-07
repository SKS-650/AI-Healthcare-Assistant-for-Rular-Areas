import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models.dart';
import '../../core/theme.dart';
import '../../shared/widgets/data_table_card.dart';
import '../../shared/widgets/stat_card.dart';
import 'emergency_provider.dart';

class EmergencyPage extends ConsumerWidget {
  const EmergencyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(emergencyProvider);
    final notifier = ref.read(emergencyProvider.notifier);
    final s = state.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ────────────────────────────────────────────────────────
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Emergency Detection & SOS',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700))
                .animate().fadeIn(duration: 400.ms),
            Text('Real-time monitoring · SOS alerts · Risk configuration',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.lightTextMuted))
                .animate().fadeIn(delay: 100.ms),
          ])),
          if (s.todayCount > 0)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.errorSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3))),
              child: Row(children: [
                const Icon(Icons.crisis_alert_rounded, color: AppColors.error, size: 14),
                const SizedBox(width: 6),
                Text('${s.todayCount} today',
                    style: const TextStyle(color: AppColors.error,
                        fontWeight: FontWeight.w700, fontSize: 12)),
              ]),
            ).animate().fadeIn(delay: 200.ms),
          OutlinedButton.icon(
            onPressed: () => _showConfigDialog(context),
            icon: const Icon(Icons.settings_rounded, size: 16),
            label: const Text('Risk Config'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => notifier.load(),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Refresh'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ]).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 24),

        // ── Stats grid ────────────────────────────────────────────────────
        LayoutBuilder(builder: (context, cst) {
          final cols = cst.maxWidth > 900 ? 4 : cst.maxWidth > 600 ? 3 : 2;
          return GridView.count(
            crossAxisCount: cols, crossAxisSpacing: 16,
            mainAxisSpacing: 16, childAspectRatio: 1.6,
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            children: [
              StatCard(title: 'Total Cases', value: '${s.total}',
                  icon: Icons.emergency_rounded, color: AppColors.info, animDelay: 0),
              StatCard(title: 'Critical', value: '${s.critical}',
                  subtitle: 'Immediate attention',
                  icon: Icons.crisis_alert_rounded, color: AppColors.riskCritical, animDelay: 80),
              StatCard(title: 'High Risk', value: '${s.high}',
                  icon: Icons.warning_rounded, color: AppColors.riskHigh, animDelay: 160),
              StatCard(title: 'SOS Triggered', value: '${s.sosTriggered}',
                  icon: Icons.sos_rounded, color: AppColors.error, animDelay: 240),
              StatCard(title: 'This Week', value: '${s.thisWeek}',
                  icon: Icons.calendar_view_week_rounded, color: AppColors.warning, animDelay: 320),
              StatCard(title: 'Medium Risk', value: '${s.medium}',
                  icon: Icons.info_rounded, color: AppColors.riskMedium, animDelay: 400),
              StatCard(title: 'Low Risk', value: '${s.low}',
                  icon: Icons.check_circle_rounded, color: AppColors.riskLow, animDelay: 480),
              StatCard(title: 'Today', value: '${s.todayCount}',
                  subtitle: 'New assessments',
                  icon: Icons.today_rounded, color: AppColors.primary, animDelay: 560),
            ],
          );
        }),
        const SizedBox(height: 24),

        // ── Risk breakdown bar ────────────────────────────────────────────
        if (s.total > 0)
          _RiskBreakdownBar(stats: s).animate().fadeIn(delay: 200.ms),
        if (s.total > 0) const SizedBox(height: 24),

        // ── Filters + table ───────────────────────────────────────────────
        DataTableCard(
          title: 'Emergency Assessments',
          isLoading: state.isLoading,
          totalRows: state.total,
          currentPage: state.page,
          pageSize: state.pageSize,
          onPageChanged: notifier.goToPage,
          filters: [
            _RiskFilter(value: state.riskFilter, onChanged: notifier.setRiskFilter),
            _EmergencyFilter(value: state.isEmergencyFilter, onChanged: notifier.setEmergencyFilter),
          ],
          columns: const [
            DataColumn(label: Text('Patient')),
            DataColumn(label: Text('Risk Level')),
            DataColumn(label: Text('Score')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Symptoms')),
            DataColumn(label: Text('SOS')),
            DataColumn(label: Text('Actions')),
            DataColumn(label: Text('Date')),
          ],
          rows: state.items.map((e) => DataRow(
            color: WidgetStateProperty.resolveWith((_) {
              if (e.riskLevel == 'CRITICAL') return AppColors.riskCritical.withValues(alpha: 0.04);
              if (e.riskLevel == 'HIGH') return AppColors.riskHigh.withValues(alpha: 0.03);
              return null;
            }),
            cells: [
              DataCell(_PatientCell(item: e)),
              DataCell(RiskBadge(level: e.riskLevel)),
              DataCell(_ScoreBar(score: e.riskScore)),
              DataCell(SizedBox(width: 160,
                  child: Text(e.possibleEmergency ?? e.emergencyType ?? '—',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis))),
              DataCell(SizedBox(width: 180,
                  child: Text(
                      e.symptoms.take(3).join(', ') + (e.symptoms.length > 3 ? '...' : ''),
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis))),
              DataCell(e.sosRequired
                  ? const Icon(Icons.sos_rounded, color: AppColors.error, size: 20)
                  : const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 18)),
              DataCell(_EmergencyActions(item: e)),
              DataCell(Text(DateFormat('MMM d, HH:mm').format(e.createdAt),
                  style: Theme.of(context).textTheme.bodySmall)),
            ],
          )).toList(),
        ).animate().fadeIn(delay: 300.ms),
      ]),
    );
  }

  void _showConfigDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _EmergencyConfigDialog(
        notifier: ProviderScope.containerOf(ctx).read(emergencyProvider.notifier),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _RiskBreakdownBar extends StatelessWidget {
  final EmergencyStats stats;
  const _RiskBreakdownBar({required this.stats});
  @override
  Widget build(BuildContext context) {
    final total = stats.total;
    if (total == 0) return const SizedBox();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Risk Level Distribution',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(children: [
              _bar(stats.critical, total, AppColors.riskCritical),
              _bar(stats.high, total, AppColors.riskHigh),
              _bar(stats.medium, total, AppColors.riskMedium),
              _bar(stats.low, total, AppColors.riskLow),
            ]),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 16, children: [
            _legend(context, 'Critical', stats.critical, AppColors.riskCritical),
            _legend(context, 'High', stats.high, AppColors.riskHigh),
            _legend(context, 'Medium', stats.medium, AppColors.riskMedium),
            _legend(context, 'Low', stats.low, AppColors.riskLow),
          ]),
        ]),
      ),
    );
  }

  Widget _bar(int value, int total, Color color) => Expanded(
        flex: total > 0 ? (value * 1000 / total).round().clamp(1, 1000) : 1,
        child: Container(height: 16, color: color),
      );

  Widget _legend(BuildContext context, String label, int count, Color color) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 10, height: 10,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 5),
        Text('$label: $count',
            style: Theme.of(context).textTheme.labelSmall),
      ]);
}

class _PatientCell extends StatelessWidget {
  final EmergencyItem item;
  const _PatientCell({required this.item});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(item.userName ?? 'Anonymous',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
          if (item.age != null || item.gender != null)
            Text('${item.age ?? '?'}y / ${item.gender ?? '?'}',
                style: Theme.of(context).textTheme.labelSmall),
        ],
      );
}

class _ScoreBar extends StatelessWidget {
  final int score;
  const _ScoreBar({required this.score});
  Color get _color => score >= 85 ? AppColors.riskCritical
      : score >= 70 ? AppColors.riskHigh
      : score >= 50 ? AppColors.riskMedium
      : AppColors.riskLow;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(width: 60, height: 6,
            child: ClipRRect(borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: _color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(_color)))),
        const SizedBox(width: 6),
        Text('$score%', style: TextStyle(fontSize: 12,
            fontWeight: FontWeight.w700, color: _color)),
      ]);
}

class _EmergencyActions extends StatelessWidget {
  final EmergencyItem item;
  const _EmergencyActions({required this.item});
  @override
  Widget build(BuildContext context) => Tooltip(
        message: 'View Details',
        child: IconButton(
          icon: const Icon(Icons.visibility_rounded,
              size: 16, color: AppColors.primary),
          onPressed: () => _showDetails(context),
        ),
      );

  void _showDetails(BuildContext context) {
    showDialog(context: context, builder: (_) => Dialog(
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  RiskBadge(level: item.riskLevel),
                  const SizedBox(width: 10),
                  Text('Emergency Assessment',
                      style: Theme.of(context).textTheme.headlineSmall),
                ]),
                const SizedBox(height: 20),
                _row(context, 'Patient', item.userName ?? 'Anonymous'),
                _row(context, 'Age/Gender', '${item.age ?? '?'} / ${item.gender ?? '?'}'),
                _row(context, 'Risk Score', '${item.riskScore}%'),
                _row(context, 'Risk Level', item.riskLevel),
                _row(context, 'Emergency Type', item.emergencyType ?? '—'),
                _row(context, 'Possible Emergency', item.possibleEmergency ?? '—'),
                _row(context, 'SOS Required', item.sosRequired ? 'YES' : 'No'),
                _row(context, 'SOS Count', '${item.sosCount}'),
                const SizedBox(height: 12),
                Text('Symptoms', style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6,
                    children: item.symptoms.map((s) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.lightSurface2,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.lightBorder)),
                          child: Text(s, style: Theme.of(context).textTheme.labelSmall),
                        )).toList()),
                const SizedBox(height: 20),
                Align(alignment: Alignment.centerRight,
                    child: FilledButton(onPressed: () => Navigator.pop(context),
                        child: const Text('Close'))),
              ]))),
    ));
  }

  Widget _row(BuildContext context, String label, String value) =>
      Padding(padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            SizedBox(width: 150, child: Text(label,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.lightTextMuted))),
            Text(value, style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w600)),
          ]));
}

// ── Emergency Config Dialog (editable, saves to backend) ─────────────────────

class _EmergencyConfigDialog extends StatefulWidget {
  final EmergencyNotifier notifier;
  const _EmergencyConfigDialog({required this.notifier});
  @override
  State<_EmergencyConfigDialog> createState() => _EmergencyConfigDialogState();
}

class _EmergencyConfigDialogState extends State<_EmergencyConfigDialog> {
  bool _loading = true;
  bool _saving = false;
  late int _critical;
  late int _high;
  late int _medium;
  late int _autoSos;
  late bool _autoSosEnabled;
  late bool _notifyAdmin;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final cfg = await widget.notifier.loadConfig();
    if (mounted) {
      setState(() {
        _critical       = (cfg['critical_threshold'] as num?)?.toInt() ?? 90;
        _high           = (cfg['high_threshold'] as num?)?.toInt() ?? 75;
        _medium         = (cfg['medium_threshold'] as num?)?.toInt() ?? 50;
        _autoSos        = (cfg['auto_sos_threshold'] as num?)?.toInt() ?? 95;
        _autoSosEnabled = cfg['auto_sos_enabled'] as bool? ?? true;
        _notifyAdmin    = cfg['notify_admin_on_sos'] as bool? ?? true;
        _loading        = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _loading
                ? const SizedBox(height: 200,
                    child: Center(child: CircularProgressIndicator()))
                : Column(mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.settings_rounded, color: AppColors.error),
                    const SizedBox(width: 10),
                    Text('Emergency Risk Configuration',
                        style: Theme.of(context).textTheme.headlineSmall),
                  ]),
                  const SizedBox(height: 6),
                  Text('Risk thresholds determine how assessments are classified.',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: AppColors.lightTextMuted)),
                  const SizedBox(height: 20),
                  _thresholdRow(context, 'Critical Threshold (%)', _critical,
                      AppColors.riskCritical, (v) => setState(() => _critical = v)),
                  _thresholdRow(context, 'High Threshold (%)', _high,
                      AppColors.riskHigh, (v) => setState(() => _high = v)),
                  _thresholdRow(context, 'Medium Threshold (%)', _medium,
                      AppColors.riskMedium, (v) => setState(() => _medium = v)),
                  _thresholdRow(context, 'Auto SOS Threshold (%)', _autoSos,
                      AppColors.error, (v) => setState(() => _autoSos = v)),
                  const Divider(height: 24),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Auto-trigger SOS', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Automatically trigger SOS when threshold is exceeded',
                        style: TextStyle(fontSize: 12)),
                    value: _autoSosEnabled,
                    activeColor: AppColors.error,
                    onChanged: (v) => setState(() => _autoSosEnabled = v),
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Notify Admin on SOS', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Send admin notification when SOS is triggered',
                        style: TextStyle(fontSize: 12)),
                    value: _notifyAdmin,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _notifyAdmin = v),
                  ),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'))),
                    const SizedBox(width: 12),
                    Expanded(child: FilledButton(
                      onPressed: _saving ? null : _save,
                      style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                      child: _saving
                          ? const SizedBox(width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Save Config'),
                    )),
                  ]),
                ]),
          ),
        ),
      );

  Widget _thresholdRow(BuildContext context, String label, int value,
      Color color, ValueChanged<int> onChanged) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          const SizedBox(width: 12),
          SizedBox(
            width: 72,
            height: 40,
            child: TextFormField(
              initialValue: '$value',
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: color),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: color, width: 2),
                ),
              ),
              onChanged: (v) {
                final parsed = int.tryParse(v);
                if (parsed != null && parsed >= 0 && parsed <= 100) onChanged(parsed);
              },
            ),
          ),
        ]),
      );

  Future<void> _save() async {
    setState(() => _saving = true);
    final ok = await widget.notifier.updateConfig({
      'critical_threshold': _critical,
      'high_threshold': _high,
      'medium_threshold': _medium,
      'auto_sos_threshold': _autoSos,
      'auto_sos_enabled': _autoSosEnabled,
      'notify_admin_on_sos': _notifyAdmin,
    });
    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Emergency configuration saved' : 'Failed to save config'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ));
    }
  }
}

// ── Risk Filter ───────────────────────────────────────────────────────────────

class _RiskFilter extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const _RiskFilter({this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          hint: const Text('All risks', style: TextStyle(fontSize: 13)),
          items: [
            const DropdownMenuItem(value: null, child: Text('All risks')),
            ...['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'].map((r) =>
                DropdownMenuItem(value: r, child: Text(r,
                    style: const TextStyle(fontSize: 13)))),
          ],
          onChanged: onChanged, isDense: true,
        ),
      );
}

class _EmergencyFilter extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?> onChanged;
  const _EmergencyFilter({this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => DropdownButtonHideUnderline(
        child: DropdownButton<bool?>(
          value: value,
          hint: const Text('All types', style: TextStyle(fontSize: 13)),
          items: const [
            DropdownMenuItem(value: null, child: Text('All types')),
            DropdownMenuItem(value: true, child: Text('Emergency only')),
            DropdownMenuItem(value: false, child: Text('Non-emergency')),
          ],
          onChanged: onChanged, isDense: true,
        ),
      );
}
