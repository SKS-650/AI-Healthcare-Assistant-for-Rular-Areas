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

class _UsersPageState extends ConsumerState<UsersPage>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late TabController _tab;
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersProvider);
    final notifier = ref.read(usersProvider.notifier);
    final active = state.users.where((u) => u.isActive).length;
    final inactive = state.users.where((u) => !u.isActive).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        _buildHeader(context, state, notifier),
        const SizedBox(height: 20),
        // Stats
        Wrap(spacing: 12, runSpacing: 8, children: [
          _chip('Total', state.total, AppColors.primary),
          _chip('Active', active, AppColors.success),
          _chip('Inactive', inactive, AppColors.error),
          _chip('Doctors',
              state.users.where((u) => u.role == 'doctor').length,
              AppColors.info),
          _chip('Admins',
              state.users.where((u) => u.role.contains('admin')).length,
              AppColors.accent),
        ]).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 20),
        // Bulk actions bar
        if (_selected.isNotEmpty)
          _BulkActionBar(
            selected: _selected,
            onClear: () => setState(() => _selected.clear()),
            notifier: notifier,
          ).animate().slideY(begin: -0.5, duration: 200.ms),
        if (_selected.isNotEmpty) const SizedBox(height: 12),
        // Table
        DataTableCard(
          title: 'All Users',
          isLoading: state.isLoading,
          totalRows: state.total,
          currentPage: state.page,
          pageSize: state.pageSize,
          onPageChanged: (p) => notifier.goToPage(p),
          headerAction: _ExportButton(),
          searchBar: SearchField(
            controller: _searchCtrl,
            hint: 'Search by name or email...',
            onChanged: (v) {
              if (v.isEmpty || v.length >= 2) notifier.setSearch(v);
            },
          ),
          filters: [
            _RoleDropdown(value: state.roleFilter, onChanged: notifier.setRoleFilter),
            _ActiveDropdown(value: state.activeFilter, onChanged: notifier.setActiveFilter),
          ],
          columns: const [
            DataColumn(label: Text('')), // checkbox
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Activity')),
            DataColumn(label: Text('Joined')),
            DataColumn(label: Text('Last Login')),
            DataColumn(label: Text('Actions')),
          ],
          rows: state.users.map((u) => _buildRow(context, u, notifier)).toList(),
        ).animate().fadeIn(delay: 200.ms),
      ]),
    );
  }

  Widget _buildHeader(BuildContext context, UsersState state,
      UsersNotifier notifier) {
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('User Management',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700))
              .animate()
              .fadeIn(duration: 400.ms),
          Text('${state.total} registered users · full CRUD control',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.lightTextMuted))
              .animate()
              .fadeIn(delay: 100.ms),
        ]),
      ),
      const SizedBox(width: 12),
      OutlinedButton.icon(
        onPressed: () => _showAddUserDialog(context, notifier),
        icon: const Icon(Icons.person_add_rounded, size: 16),
        label: const Text('Add User'),
      ),
      const SizedBox(width: 8),
      FilledButton.icon(
        onPressed: () => notifier.load(),
        icon: const Icon(Icons.refresh_rounded, size: 16),
        label: const Text('Refresh'),
        style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
      ),
    ]).animate().fadeIn(duration: 400.ms);
  }

  DataRow _buildRow(
      BuildContext context, AdminUser u, UsersNotifier notifier) {
    final isSelected = _selected.contains(u.id);
    return DataRow(
      selected: isSelected,
      onSelectChanged: (v) =>
          setState(() => v! ? _selected.add(u.id) : _selected.remove(u.id)),
      cells: [
        DataCell(Checkbox(
          value: isSelected,
          onChanged: (v) =>
              setState(() => v! ? _selected.add(u.id) : _selected.remove(u.id)),
        )),
        DataCell(_NameCell(user: u)),
        DataCell(Text(u.email,
            style: Theme.of(context).textTheme.bodySmall)),
        DataCell(_RoleChip(role: u.role)),
        DataCell(StatusBadge(active: u.isActive)),
        DataCell(_ActivityCell(
            conversations: u.totalConversations,
            emergencies: u.totalEmergencyAssessments)),
        DataCell(Text(DateFormat('MMM d, y').format(u.createdAt),
            style: Theme.of(context).textTheme.bodySmall)),
        DataCell(Text(
            u.lastLogin != null
                ? DateFormat('MMM d').format(u.lastLogin!)
                : 'Never',
            style: Theme.of(context).textTheme.bodySmall)),
        DataCell(_UserActions(user: u, notifier: notifier)),
      ],
    );
  }

  Widget _chip(String label, int value, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('$value',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 18, color: color)),
          const SizedBox(width: 6),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: color)),
        ]),
      );

  void _showAddUserDialog(BuildContext context, UsersNotifier notifier) {
    showDialog(
      context: context,
      builder: (_) => _AddUserDialog(notifier: notifier),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _NameCell extends StatelessWidget {
  final AdminUser user;
  const _NameCell({required this.user});
  @override
  Widget build(BuildContext context) {
    final initials = user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U';
    return Row(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: AppColors.accentSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text(initials,
            style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
                fontSize: 12))),
      ),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        Text(user.fullName,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w500)),
        if (user.phone != null)
          Text(user.phone!,
              style: Theme.of(context).textTheme.labelSmall),
      ]),
    ]);
  }
}

class _ActivityCell extends StatelessWidget {
  final int conversations;
  final int emergencies;
  const _ActivityCell(
      {required this.conversations, required this.emergencies});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: '$conversations chats',
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.chat_bubble_rounded,
                  size: 12, color: AppColors.accent),
              const SizedBox(width: 3),
              Text('$conversations',
                  style: Theme.of(context).textTheme.labelSmall),
            ]),
          ),
          const SizedBox(width: 10),
          Tooltip(
            message: '$emergencies emergency checks',
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.emergency_rounded,
                  size: 12, color: AppColors.error),
              const SizedBox(width: 3),
              Text('$emergencies',
                  style: Theme.of(context).textTheme.labelSmall),
            ]),
          ),
        ],
      );
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
          color: _color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(role.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, color: _color)),
      );
}

class _ExportButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: () => _showExportDialog(context),
        icon: const Icon(Icons.download_rounded, size: 14),
        label: const Text('Export', style: TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero),
      );

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Users'),
        content: const Text(
            'Export user data as CSV or JSON. The file will include all user fields.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton.icon(
            icon: const Icon(Icons.file_download_rounded, size: 16),
            label: const Text('Export CSV'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }
}

class _UserActions extends StatelessWidget {
  final AdminUser user;
  final UsersNotifier notifier;
  const _UserActions({required this.user, required this.notifier});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Tooltip(
          message: 'View Details',
          child: IconButton(
            icon: const Icon(Icons.visibility_rounded,
                size: 16, color: AppColors.primary),
            onPressed: () => _showUserDetails(context),
          ),
        ),
        Tooltip(
          message: user.isActive ? 'Deactivate' : 'Activate',
          child: IconButton(
            icon: Icon(
                user.isActive
                    ? Icons.pause_circle_outline_rounded
                    : Icons.play_circle_outline_rounded,
                size: 16,
                color: user.isActive ? AppColors.warning : AppColors.success),
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
        Tooltip(
          message: 'Change Role',
          child: IconButton(
            icon: const Icon(Icons.admin_panel_settings_rounded,
                size: 16, color: AppColors.accent),
            onPressed: () => _showRoleDialog(context),
          ),
        ),
        Tooltip(
          message: 'Delete',
          child: IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                size: 16, color: AppColors.error),
            onPressed: () => _confirmDelete(context),
          ),
        ),
      ]);

  void _showUserDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('User Details',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                _detailRow(context, 'Full Name', user.fullName),
                _detailRow(context, 'Email', user.email),
                _detailRow(context, 'Phone', user.phone ?? 'Not set'),
                _detailRow(context, 'Role', user.role.replaceAll('_', ' ').toUpperCase()),
                _detailRow(context, 'Status', user.isActive ? 'Active' : 'Inactive'),
                _detailRow(context, 'Email Verified', user.emailVerified ? 'Yes' : 'No'),
                _detailRow(context, 'Language', user.language.toUpperCase()),
                _detailRow(context, 'Chat Sessions', '${user.totalConversations}'),
                _detailRow(context, 'Emergency Checks', '${user.totalEmergencyAssessments}'),
                _detailRow(context, 'Joined',
                    DateFormat('MMMM d, y').format(user.createdAt)),
                if (user.lastLogin != null)
                  _detailRow(context, 'Last Login',
                      DateFormat('MMMM d, y HH:mm').format(user.lastLogin!)),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.lightTextMuted,
                    fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ]),
      );

  void _showRoleDialog(BuildContext context) {
    String selectedRole = user.role;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('Change Role — ${user.fullName}'),
          content: DropdownButtonFormField<String>(
            value: selectedRole,
            items: ['patient', 'doctor', 'admin', 'super_admin']
                .map((r) => DropdownMenuItem(
                    value: r,
                    child: Text(r.replaceAll('_', ' ').toUpperCase())))
                .toList(),
            onChanged: (v) => setState(() => selectedRole = v!),
            decoration: const InputDecoration(labelText: 'Role'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await notifier.updateRole(user.id, selectedRole);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Role updated'),
                      backgroundColor: AppColors.success));
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext pageContext) async {
    final confirmed = await showDialog<bool>(
      context: pageContext,
      builder: (dlgCtx) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Delete "${user.fullName}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dlgCtx, false),
              child: const Text('Cancel')),
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
            ? '${user.fullName} deleted'
            : 'Failed to delete user'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ));
    }
  }
}

class _BulkActionBar extends StatelessWidget {
  final Set<String> selected;
  final VoidCallback onClear;
  final UsersNotifier notifier;
  const _BulkActionBar(
      {required this.selected,
      required this.onClear,
      required this.notifier});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          Text('${selected.length} selected',
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
          const SizedBox(width: 16),
          _bulkBtn(context, 'Activate', AppColors.success,
              Icons.play_circle_rounded, 'activate'),
          const SizedBox(width: 8),
          _bulkBtn(context, 'Deactivate', AppColors.warning,
              Icons.pause_circle_rounded, 'deactivate'),
          const SizedBox(width: 8),
          _bulkBtn(context, 'Delete', AppColors.error,
              Icons.delete_rounded, 'delete'),
          const Spacer(),
          TextButton(onPressed: onClear, child: const Text('Clear')),
        ]),
      );

  Widget _bulkBtn(BuildContext context, String label, Color color,
      IconData icon, String action) =>
      OutlinedButton.icon(
        icon: Icon(icon, size: 14, color: color),
        label: Text(label, style: TextStyle(color: color, fontSize: 12)),
        style: OutlinedButton.styleFrom(
            side: BorderSide(color: color),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: Size.zero),
        onPressed: () => _confirmBulk(context, action),
      );

  Future<void> _confirmBulk(BuildContext context, String action) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Bulk ${action.toUpperCase()}'),
        content: Text(
            'Apply "$action" to ${selected.length} users? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor:
                    action == 'delete' ? AppColors.error : AppColors.primary),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await notifier.bulkAction(
      userIds: selected.toList(),
      action: action,
    );

    onClear();

    if (context.mounted) {
      final msg = result?['message'] as String? ??
          'Bulk $action applied to ${selected.length} users';
      final failed = result?['failed_count'] as int? ?? 0;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(failed > 0 ? '$msg ($failed failed)' : msg),
        backgroundColor: failed > 0 ? AppColors.warning : AppColors.success,
      ));
    }
  }
}

class _AddUserDialog extends StatefulWidget {
  final UsersNotifier notifier;
  const _AddUserDialog({required this.notifier});
  @override
  State<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<_AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  String _role = 'patient';
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Add New User',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.error, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!,
                          style: const TextStyle(
                              color: AppColors.error, fontSize: 13))),
                    ]),
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Full Name *'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email *'),
                  validator: (v) =>
                      v!.isEmpty || !v.contains('@') ? 'Valid email required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  decoration: const InputDecoration(labelText: 'Password *'),
                  obscureText: true,
                  validator: (v) =>
                      v!.length < 8 ? 'Min 8 characters' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  decoration:
                      const InputDecoration(labelText: 'Phone (optional)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: ['patient', 'doctor', 'admin']
                      .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(r.replaceAll('_', ' ').toUpperCase())))
                      .toList(),
                  onChanged: (v) => setState(() => _role = v!),
                ),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white))
                          : const Text('Create User'),
                    ),
                  ),
                ]),
              ]),
            ),
          ),
        ),
      );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    final (result, errMsg) = await widget.notifier.createUser(
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      role: _role,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${result['message'] ?? 'User created successfully'}'),
        backgroundColor: AppColors.success,
      ));
    } else {
      setState(() => _error = errMsg ?? 'Failed to create user. Check the details and try again.');
    }
  }
}

class _RoleDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const _RoleDropdown({this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 40,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: value,
            hint: const Text('All roles', style: TextStyle(fontSize: 13)),
            items: [
              const DropdownMenuItem(value: null, child: Text('All roles')),
              ...['patient', 'doctor', 'admin', 'super_admin'].map((r) =>
                  DropdownMenuItem(
                      value: r,
                      child: Text(r.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(fontSize: 13)))),
            ],
            onChanged: onChanged,
            isDense: true,
          ),
        ),
      );
}

class _ActiveDropdown extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?> onChanged;
  const _ActiveDropdown({this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => SizedBox(
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
