import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models.dart';
import '../../core/theme.dart';
import '../../shared/widgets/data_table_card.dart';
import 'users_provider.dart';

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersProvider);
    final notifier = ref.read(usersProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('User Management',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w700))
                        .animate()
                        .fadeIn(duration: 400.ms),
                    Text(
                      '${state.total} total users registered',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.lightTextMuted),
                    ).animate().fadeIn(delay: 100.ms),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => notifier.load(),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Refresh'),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Summary chips ──────────────────────────────────────────────
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _SummaryChip(
                  label: 'Total',
                  value: state.total,
                  color: AppColors.primary),
              _SummaryChip(
                  label: 'Active',
                  value: state.users
                      .where((u) => u.isActive)
                      .length,
                  color: AppColors.success),
              _SummaryChip(
                  label: 'Inactive',
                  value: state.users
                      .where((u) => !u.isActive)
                      .length,
                  color: AppColors.error),
            ],
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 20),

          // ── Table ──────────────────────────────────────────────────────
          DataTableCard(
            title: 'All Users',
            isLoading: state.isLoading,
            totalRows: state.total,
            currentPage: state.page,
            pageSize: state.pageSize,
            onPageChanged: (p) => notifier.goToPage(p),
            searchBar: SearchField(
              controller: _searchCtrl,
              hint: 'Search by name or email...',
              onChanged: (v) {
                if (v.isEmpty || v.length >= 2) {
                  notifier.setSearch(v);
                }
              },
            ),
            filters: [
              _RoleDropdown(
                value: state.roleFilter,
                onChanged: notifier.setRoleFilter,
              ),
              _ActiveDropdown(
                value: state.activeFilter,
                onChanged: notifier.setActiveFilter,
              ),
            ],
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Role')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Joined')),
              DataColumn(label: Text('Last Login')),
              DataColumn(label: Text('Actions')),
            ],
            rows: state.users
                .map((u) => DataRow(cells: [
                      DataCell(_UserNameCell(user: u)),
                      DataCell(Text(u.email,
                          style:
                              Theme.of(context).textTheme.bodySmall)),
                      DataCell(_RoleChip(role: u.role)),
                      DataCell(StatusBadge(active: u.isActive)),
                      DataCell(Text(
                          DateFormat('MMM d, y').format(u.createdAt),
                          style:
                              Theme.of(context).textTheme.bodySmall)),
                      DataCell(Text(
                          u.lastLogin != null
                              ? DateFormat('MMM d').format(u.lastLogin!)
                              : 'Never',
                          style:
                              Theme.of(context).textTheme.bodySmall)),
                      DataCell(
                          _ActionButtons(user: u, notifier: notifier)),
                    ]))
                .toList(),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _SummaryChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$value',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: color)),
            const SizedBox(width: 6),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: color)),
          ],
        ),
      );
}

class _UserNameCell extends StatelessWidget {
  final AdminUser user;
  const _UserNameCell({required this.user});

  @override
  Widget build(BuildContext context) {
    final initials = user.fullName.isNotEmpty
        ? user.fullName[0].toUpperCase()
        : 'U';
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.accentSurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(initials,
                style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 12)),
          ),
        ),
        const SizedBox(width: 10),
        Text(user.fullName,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String role;
  const _RoleChip({required this.role});

  Color get _color => switch (role) {
        'super_admin' => AppColors.riskCritical,
        'admin' => AppColors.error,
        'doctor' => AppColors.info,
        _ => AppColors.primary,
      };

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(role.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _color)),
      );
}

class _ActionButtons extends StatelessWidget {
  final AdminUser user;
  final UsersNotifier notifier;
  const _ActionButtons({required this.user, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Toggle active / inactive
        Tooltip(
          message: user.isActive ? 'Deactivate' : 'Activate',
          child: IconButton(
            icon: Icon(
              user.isActive
                  ? Icons.pause_circle_outline_rounded
                  : Icons.play_circle_outline_rounded,
              size: 18,
              color: user.isActive ? AppColors.warning : AppColors.success,
            ),
            onPressed: () async {
              await notifier.updateStatus(user.id, !user.isActive);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(user.isActive
                      ? '${user.fullName} deactivated'
                      : '${user.fullName} activated'),
                  backgroundColor:
                      user.isActive ? AppColors.warning : AppColors.success,
                  duration: const Duration(seconds: 2),
                ));
              }
            },
          ),
        ),
        // Delete
        Tooltip(
          message: 'Delete user',
          child: IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                size: 18, color: AppColors.error),
            onPressed: () => _confirmDelete(context),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext pageContext) async {
    // Use the dialog's own context (dlgCtx) for Navigator.pop —
    // never the outer page context which may be stale by the time
    // the async delete completes.
    final confirmed = await showDialog<bool>(
      context: pageContext,
      builder: (dlgCtx) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Delete "${user.fullName}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dlgCtx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final ok = await notifier.deleteUser(user.id);
    if (pageContext.mounted) {
      ScaffoldMessenger.of(pageContext).showSnackBar(SnackBar(
        content: Text(ok
            ? '${user.fullName} deleted successfully'
            : 'Failed to delete user. Try again.'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
        duration: const Duration(seconds: 3),
      ));
    }
  }
}

class _RoleDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const _RoleDropdown({this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          hint: const Text('All roles', style: TextStyle(fontSize: 13)),
          items: [
            const DropdownMenuItem(value: null, child: Text('All roles')),
            ...['patient', 'doctor', 'admin', 'super_admin'].map(
              (r) => DropdownMenuItem(
                  value: r,
                  child: Text(r.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(fontSize: 13))),
            ),
          ],
          onChanged: onChanged,
          isDense: true,
        ),
      ),
    );
  }
}

class _ActiveDropdown extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?> onChanged;
  const _ActiveDropdown({this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<bool?>(
          value: value,
          hint: const Text('All status', style: TextStyle(fontSize: 13)),
          items: const [
            DropdownMenuItem(value: null, child: Text('All status')),
            DropdownMenuItem(value: true, child: Text('Active')),
            DropdownMenuItem(value: false, child: Text('Inactive')),
          ],
          onChanged: onChanged,
          isDense: true,
        ),
      ),
    );
  }
}
