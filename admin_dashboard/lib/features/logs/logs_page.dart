import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/api.dart';
import '../../core/models.dart';
import '../../core/theme.dart';
import '../../shared/widgets/data_table_card.dart';

class _LogsState {
  final bool isLoading; final String? error;
  final List<ActivityLog> logs; final int total, page;
  final String? moduleFilter, severityFilter;
  const _LogsState({
    this.isLoading = false, this.error, this.logs = const [],
    this.total = 0, this.page = 1, this.moduleFilter, this.severityFilter,
  });
  _LogsState copyWith({
    bool? isLoading, String? error, List<ActivityLog>? logs,
    int? total, int? page, String? moduleFilter, String? severityFilter,
    bool clearModule = false, bool clearSeverity = false,
  }) => _LogsState(
    isLoading: isLoading ?? this.isLoading, error: error,
    logs: logs ?? this.logs, total: total ?? this.total, page: page ?? this.page,
    moduleFilter: clearModule ? null : (moduleFilter ?? this.moduleFilter),
    severityFilter: clearSeverity ? null : (severityFilter ?? this.severityFilter),
  );
}

class _LogsNotifier extends StateNotifier<_LogsState> {
  _LogsNotifier() : super(const _LogsState()) { load(); }
  Future<void> load({int? page}) async {
    state = state.copyWith(isLoading: true, page: page ?? state.page);
    try {
      final params = <String, dynamic>{'page': state.page, 'page_size': 50};
      if (state.moduleFilter != null) params['module'] = state.moduleFilter;
      if (state.severityFilter != null) params['severity'] = state.severityFilter;
      final resp = await ApiClient.instance.get('/admin/logs', queryParameters: params);
      final data = resp.data as Map<String, dynamic>;
      state = state.copyWith(
        isLoading: false,
        logs: (data['logs'] as List).cast<Map<String, dynamic>>().map(ActivityLog.fromJson).toList(),
        total: data['total'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ApiResult.fromError(e).error);
    }
  }
  void setModule(String? v) {
    state = v == null ? state.copyWith(clearModule: true, page: 1) : state.copyWith(moduleFilter: v, page: 1);
    load();
  }
  void setSeverity(String? v) {
    state = v == null ? state.copyWith(clearSeverity: true, page: 1) : state.copyWith(severityFilter: v, page: 1);
    load();
  }
  void goToPage(int p) => load(page: p);
}

final _logsProvider = StateNotifierProvider<_LogsNotifier, _LogsState>((ref) => _LogsNotifier());

class LogsPage extends ConsumerWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_logsProvider);
    final notifier = ref.read(_logsProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Activity Logs', style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700)).animate().fadeIn(duration: 400.ms),
            Text('Admin action audit trail',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.lightTextMuted))
                .animate().fadeIn(delay: 100.ms),
          ])),
          FilledButton.icon(
            onPressed: () => notifier.load(),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Refresh'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ]),
        const SizedBox(height: 24),

        DataTableCard(
          title: 'System Logs',
          isLoading: state.isLoading,
          totalRows: state.total, currentPage: state.page, pageSize: 50,
          onPageChanged: notifier.goToPage,
          filters: [
            _ModuleFilter(value: state.moduleFilter, onChanged: notifier.setModule),
            const SizedBox(width: 4),
            _SeverityFilter(value: state.severityFilter, onChanged: notifier.setSeverity),
          ],
          columns: const [
            DataColumn(label: Text('Time')),
            DataColumn(label: Text('Admin')),
            DataColumn(label: Text('Action')),
            DataColumn(label: Text('Module')),
            DataColumn(label: Text('Target')),
            DataColumn(label: Text('Severity')),
            DataColumn(label: Text('IP')),
          ],
          rows: state.logs.map((log) => DataRow(cells: [
            DataCell(Text(DateFormat('MMM d HH:mm:ss').format(log.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'))),
            DataCell(Text(log.adminName ?? log.adminId?.substring(0, 8) ?? '—',
                style: Theme.of(context).textTheme.bodySmall)),
            DataCell(SizedBox(width: 160,
                child: Text(log.action, style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(fontFamily: 'monospace'), overflow: TextOverflow.ellipsis))),
            DataCell(_ModuleChip(module: log.module)),
            DataCell(Text(log.targetId?.substring(0, 8) ?? log.description ?? '—',
                style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
            DataCell(_SeverityBadge(severity: log.severity)),
            DataCell(Text(log.ipAddress ?? '—', style: Theme.of(context).textTheme.labelSmall)),
          ])).toList(),
        ).animate().fadeIn(delay: 200.ms),
      ]),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final String severity;
  const _SeverityBadge({required this.severity});
  Color get _color => switch (severity) {
    'critical' => AppColors.riskCritical,
    'error' => AppColors.error,
    'warning' => AppColors.warning,
    _ => AppColors.info,
  };
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
    child: Text(severity.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _color)),
  );
}

class _ModuleChip extends StatelessWidget {
  final String module;
  const _ModuleChip({required this.module});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: AppColors.accentSurface, borderRadius: BorderRadius.circular(6)),
    child: Text(module, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accent)),
  );
}

class _ModuleFilter extends StatelessWidget {
  final String? value; final ValueChanged<String?> onChanged;
  const _ModuleFilter({this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => DropdownButtonHideUnderline(
    child: DropdownButton<String?>(
      value: value, isDense: true,
      hint: const Text('All modules', style: TextStyle(fontSize: 13)),
      items: [
        const DropdownMenuItem(value: null, child: Text('All modules')),
        ...['users', 'education', 'settings', 'emergency', 'auth'].map(
          (m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 13)))),
      ],
      onChanged: onChanged,
    ),
  );
}

class _SeverityFilter extends StatelessWidget {
  final String? value; final ValueChanged<String?> onChanged;
  const _SeverityFilter({this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => DropdownButtonHideUnderline(
    child: DropdownButton<String?>(
      value: value, isDense: true,
      hint: const Text('All severity', style: TextStyle(fontSize: 13)),
      items: [
        const DropdownMenuItem(value: null, child: Text('All severity')),
        ...['info', 'warning', 'error', 'critical'].map(
          (s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))),
      ],
      onChanged: onChanged,
    ),
  );
}
