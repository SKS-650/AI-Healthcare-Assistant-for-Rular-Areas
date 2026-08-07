import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../shared/widgets/data_table_card.dart';
import '../../shared/widgets/stat_card.dart';
import 'authentication_provider.dart';

class AuthenticationPage extends ConsumerStatefulWidget {
  const AuthenticationPage({super.key});

  @override
  ConsumerState<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends ConsumerState<AuthenticationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _sessionSearchCtrl = TextEditingController();
  final _tokenSearchCtrl = TextEditingController();
  final _otpSearchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _sessionSearchCtrl.dispose();
    _tokenSearchCtrl.dispose();
    _otpSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authManagementProvider);
    final notifier = ref.read(authManagementProvider.notifier);
    final s = state.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Authentication Management',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700))
                  .animate()
                  .fadeIn(duration: 400.ms),
              Text('Manage sessions, tokens, OTP logs and verification status',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.lightTextMuted))
                  .animate()
                  .fadeIn(delay: 100.ms),
            ]),
          ),
          FilledButton.icon(
            onPressed: () => notifier.loadAll(),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Refresh'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ]).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 20),

        // Stats
        LayoutBuilder(builder: (context, cst) {
          final cols = cst.maxWidth > 900 ? 4 : cst.maxWidth > 600 ? 2 : 1;
          return GridView.count(
            crossAxisCount: cols,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              StatCard(
                title: 'Active Sessions',
                value: '${s.activeSessions}',
                subtitle: 'Currently logged-in users',
                icon: Icons.devices_rounded,
                color: AppColors.primary,
                animDelay: 0,
              ),
              StatCard(
                title: 'Active Tokens',
                value: '${s.activeTokens}',
                subtitle: 'Valid refresh tokens',
                icon: Icons.token_rounded,
                color: AppColors.accent,
                animDelay: 80,
              ),
              StatCard(
                title: 'Pending OTPs',
                value: '${s.pendingOtps}',
                subtitle: 'Unused OTP codes',
                icon: Icons.dialpad_rounded,
                color: AppColors.warning,
                animDelay: 160,
              ),
              StatCard(
                title: 'Unverified Emails',
                value: '${s.unverifiedEmails}',
                subtitle: 'Awaiting verification',
                icon: Icons.mark_email_unread_rounded,
                color: AppColors.error,
                animDelay: 240,
              ),
            ],
          );
        }),
        const SizedBox(height: 24),

        // Tabs
        Card(
          child: Column(children: [
            TabBar(
              controller: _tab,
              tabs: const [
                Tab(text: 'Active Sessions'),
                Tab(text: 'Refresh Tokens'),
                Tab(text: 'OTP Logs'),
              ],
              labelColor: AppColors.primary,
              indicatorColor: AppColors.primary,
            ),
            SizedBox(
              height: 600,
              child: TabBarView(
                controller: _tab,
                children: [
                  _SessionsTab(
                    state: state,
                    notifier: notifier,
                    searchCtrl: _sessionSearchCtrl,
                  ),
                  _TokensTab(
                    state: state,
                    notifier: notifier,
                    searchCtrl: _tokenSearchCtrl,
                  ),
                  _OtpLogsTab(
                    state: state,
                    notifier: notifier,
                    searchCtrl: _otpSearchCtrl,
                  ),
                ],
              ),
            ),
          ]),
        ).animate().fadeIn(delay: 300.ms),
      ]),
    );
  }
}

// ── Sessions Tab ──────────────────────────────────────────────────────────────

class _SessionsTab extends StatelessWidget {
  final AuthManagementState state;
  final AuthManagementNotifier notifier;
  final TextEditingController searchCtrl;

  const _SessionsTab({
    required this.state,
    required this.notifier,
    required this.searchCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final sessions = state.sessions;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: DataTableCard(
        title: 'Active User Sessions',
        isLoading: state.isLoading,
        totalRows: state.sessionsTotal,
        currentPage: state.sessionsPage,
        pageSize: state.pageSize,
        onPageChanged: (p) => notifier.loadSessions(page: p),
        searchBar: SearchField(
          controller: searchCtrl,
          hint: 'Search by user or IP...',
        ),
        columns: const [
          DataColumn(label: Text('User')),
          DataColumn(label: Text('IP Address')),
          DataColumn(label: Text('Device')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Last Active')),
          DataColumn(label: Text('Expires')),
          DataColumn(label: Text('Actions')),
        ],
        rows: sessions.map((s) {
          final isExpired = s.expiresAt != null
              ? DateTime.tryParse(s.expiresAt!)?.isBefore(DateTime.now()) ?? false
              : false;
          return DataRow(cells: [
            DataCell(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(s.userName ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                Text(s.userEmail ?? s.userId,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppColors.lightTextMuted)),
              ],
            )),
            DataCell(Text(s.ipAddress ?? '—',
                style: Theme.of(context).textTheme.bodySmall)),
            DataCell(SizedBox(
              width: 160,
              child: Text(
                _truncateDevice(s.deviceInfo),
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            )),
            DataCell(StatusBadge(
              active: s.isActive && !isExpired,
              activeLabel: 'Active',
              inactiveLabel: isExpired ? 'Expired' : 'Revoked',
            )),
            DataCell(Text(
              s.lastActiveAt != null
                  ? _fmtDate(s.lastActiveAt!)
                  : '—',
              style: Theme.of(context).textTheme.bodySmall,
            )),
            DataCell(Text(
              s.expiresAt != null ? _fmtDate(s.expiresAt!) : '—',
              style: Theme.of(context).textTheme.bodySmall,
            )),
            DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
              Tooltip(
                message: 'Revoke Session',
                child: IconButton(
                  icon: const Icon(Icons.logout_rounded, size: 16, color: AppColors.error),
                  onPressed: () => _confirmRevoke(context, s, notifier),
                ),
              ),
              Tooltip(
                message: 'Revoke All for User',
                child: IconButton(
                  icon: const Icon(Icons.person_off_rounded, size: 16, color: AppColors.warning),
                  onPressed: () => _confirmRevokeAll(context, s, notifier),
                ),
              ),
            ])),
          ]);
        }).toList(),
      ),
    );
  }

  String _truncateDevice(String? d) {
    if (d == null || d.isEmpty) return '—';
    return d.length > 40 ? '${d.substring(0, 40)}...' : d;
  }

  String _fmtDate(String iso) {
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return iso;
    return DateFormat('MMM d, HH:mm').format(dt);
  }

  void _confirmRevoke(
      BuildContext context, AdminSession s, AuthManagementNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke Session'),
        content: Text('Revoke session for ${s.userName ?? s.userId}? They will be logged out.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await notifier.revokeSession(s.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? 'Session revoked' : 'Failed to revoke'),
                  backgroundColor: ok ? AppColors.success : AppColors.error,
                ));
              }
            },
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
  }

  void _confirmRevokeAll(
      BuildContext context, AdminSession s, AuthManagementNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke All Sessions'),
        content: Text(
            'Revoke ALL sessions for ${s.userName ?? s.userId}? This will force logout on all devices.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await notifier.revokeAllUserSessions(s.userId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? 'All sessions revoked' : 'Failed'),
                  backgroundColor: ok ? AppColors.success : AppColors.error,
                ));
              }
            },
            child: const Text('Revoke All'),
          ),
        ],
      ),
    );
  }
}

// ── Tokens Tab ────────────────────────────────────────────────────────────────

class _TokensTab extends StatelessWidget {
  final AuthManagementState state;
  final AuthManagementNotifier notifier;
  final TextEditingController searchCtrl;

  const _TokensTab({
    required this.state,
    required this.notifier,
    required this.searchCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = state.tokens;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: DataTableCard(
        title: 'Refresh Tokens',
        isLoading: state.isLoading,
        totalRows: state.tokensTotal,
        currentPage: state.tokensPage,
        pageSize: state.pageSize,
        onPageChanged: (p) => notifier.loadTokens(page: p),
        searchBar: SearchField(
          controller: searchCtrl,
          hint: 'Search by user or IP...',
        ),
        columns: const [
          DataColumn(label: Text('User')),
          DataColumn(label: Text('IP Address')),
          DataColumn(label: Text('Device')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Expires')),
          DataColumn(label: Text('Last Used')),
          DataColumn(label: Text('Actions')),
        ],
        rows: tokens.map((t) {
          final isExpired = DateTime.tryParse(t.expiresAt)?.isBefore(DateTime.now()) ?? false;
          return DataRow(cells: [
            DataCell(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t.userName ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                Text(t.userEmail ?? t.userId,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppColors.lightTextMuted)),
              ],
            )),
            DataCell(Text(t.ipAddress ?? '—',
                style: Theme.of(context).textTheme.bodySmall)),
            DataCell(SizedBox(
              width: 140,
              child: Text(
                t.deviceInfo != null && t.deviceInfo!.length > 35
                    ? '${t.deviceInfo!.substring(0, 35)}...'
                    : (t.deviceInfo ?? '—'),
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            )),
            DataCell(StatusBadge(
              active: !t.isRevoked && !isExpired,
              activeLabel: 'Valid',
              inactiveLabel: t.isRevoked ? 'Revoked' : 'Expired',
            )),
            DataCell(Text(
              _fmtDate(t.expiresAt),
              style: Theme.of(context).textTheme.bodySmall,
            )),
            DataCell(Text(
              t.lastUsedAt != null ? _fmtDate(t.lastUsedAt!) : 'Never',
              style: Theme.of(context).textTheme.bodySmall,
            )),
            DataCell(Tooltip(
              message: 'Revoke Token',
              child: IconButton(
                icon: const Icon(Icons.block_rounded, size: 16, color: AppColors.error),
                onPressed: t.isRevoked
                    ? null
                    : () async {
                        final ok = await notifier.revokeToken(t.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(ok ? 'Token revoked' : 'Failed'),
                            backgroundColor: ok ? AppColors.success : AppColors.error,
                          ));
                        }
                      },
              ),
            )),
          ]);
        }).toList(),
      ),
    );
  }

  String _fmtDate(String iso) {
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return iso;
    return DateFormat('MMM d, HH:mm').format(dt);
  }
}

// ── OTP Logs Tab ──────────────────────────────────────────────────────────────

class _OtpLogsTab extends StatelessWidget {
  final AuthManagementState state;
  final AuthManagementNotifier notifier;
  final TextEditingController searchCtrl;

  const _OtpLogsTab({
    required this.state,
    required this.notifier,
    required this.searchCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final otpLogs = state.otpLogs;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: DataTableCard(
        title: 'OTP Logs',
        isLoading: state.isLoading,
        totalRows: state.otpLogsTotal,
        currentPage: state.otpLogsPage,
        pageSize: state.pageSize,
        onPageChanged: (p) => notifier.loadOtpLogs(page: p),
        searchBar: SearchField(
          controller: searchCtrl,
          hint: 'Search by user or purpose...',
        ),
        columns: const [
          DataColumn(label: Text('User')),
          DataColumn(label: Text('Purpose')),
          DataColumn(label: Text('Attempts')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Expires')),
          DataColumn(label: Text('Created')),
        ],
        rows: otpLogs.map((o) {
          final isExpired = DateTime.tryParse(o.expiresAt)?.isBefore(DateTime.now()) ?? false;
          return DataRow(cells: [
            DataCell(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(o.userName ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                Text(o.userEmail ?? o.userId,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppColors.lightTextMuted)),
              ],
            )),
            DataCell(_PurposeBadge(purpose: o.purpose)),
            DataCell(Text('${o.attempts}',
                style: Theme.of(context).textTheme.bodySmall)),
            DataCell(StatusBadge(
              active: o.isUsed,
              activeLabel: 'Used',
              inactiveLabel: isExpired ? 'Expired' : 'Pending',
            )),
            DataCell(Text(
              _fmtDate(o.expiresAt),
              style: Theme.of(context).textTheme.bodySmall,
            )),
            DataCell(Text(
              _fmtDate(o.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            )),
          ]);
        }).toList(),
      ),
    );
  }

  String _fmtDate(String iso) {
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return iso;
    return DateFormat('MMM d, HH:mm').format(dt);
  }
}

class _PurposeBadge extends StatelessWidget {
  final String purpose;
  const _PurposeBadge({required this.purpose});

  @override
  Widget build(BuildContext context) {
    final color = switch (purpose.toLowerCase()) {
      'email_verification' => AppColors.info,
      'phone_verification' => AppColors.accent,
      'password_reset' => AppColors.warning,
      'login' => AppColors.success,
      _ => AppColors.lightTextMuted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        purpose.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
