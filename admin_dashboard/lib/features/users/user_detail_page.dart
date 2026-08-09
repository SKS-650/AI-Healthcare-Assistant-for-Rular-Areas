import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models.dart';
import '../../core/theme.dart';
import 'user_detail_provider.dart';
import 'users_provider.dart';

// ── Page entry point ──────────────────────────────────────────────────────────

class UserDetailPage extends ConsumerStatefulWidget {
  final String userId;
  const UserDetailPage({super.key, required this.userId});

  @override
  ConsumerState<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends ConsumerState<UserDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  static const _tabs = [
    Tab(icon: Icon(Icons.person_rounded, size: 16), text: 'Profile'),
    Tab(icon: Icon(Icons.edit_rounded, size: 16), text: 'Edit'),
    Tab(icon: Icon(Icons.chat_bubble_rounded, size: 16), text: 'Chats'),
    Tab(icon: Icon(Icons.emergency_rounded, size: 16), text: 'Emergency'),
    Tab(icon: Icon(Icons.monitor_heart_rounded, size: 16), text: 'Symptoms'),
    Tab(icon: Icon(Icons.devices_rounded, size: 16), text: 'Sessions'),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabs.length, vsync: this);
    _tab.addListener(_onTabChange);
  }

  void _onTabChange() {
    if (_tab.indexIsChanging) return;
    final notifier = ref.read(userDetailProvider(widget.userId).notifier);
    switch (_tab.index) {
      case 2:
        final s = ref.read(userDetailProvider(widget.userId));
        if (s.conversations.isEmpty) notifier.loadConversations();
      case 3:
        final s = ref.read(userDetailProvider(widget.userId));
        if (s.emergencies.isEmpty) notifier.loadEmergencies();
      case 4:
        final s = ref.read(userDetailProvider(widget.userId));
        if (s.symptomChecks.isEmpty) notifier.loadSymptomChecks();
      case 5:
        final s = ref.read(userDetailProvider(widget.userId));
        if (s.sessions.isEmpty) notifier.loadSessions();
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userDetailProvider(widget.userId));
    final user = state.user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(children: [
        _Header(userId: widget.userId, user: user),
        if (state.error != null)
          _ErrorBanner(message: state.error!),
        _TabBar(controller: _tab, tabs: _tabs),
        Expanded(
          child: state.isLoading && user == null
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tab,
                  children: [
                    _ProfileTab(userId: widget.userId),
                    _EditTab(userId: widget.userId),
                    _ChatsTab(userId: widget.userId),
                    _EmergencyTab(userId: widget.userId),
                    _SymptomsTab(userId: widget.userId),
                    _SessionsTab(userId: widget.userId),
                  ],
                ),
        ),
      ]),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends ConsumerWidget {
  final String userId;
  final AdminUser? user;
  const _Header({required this.userId, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final u = user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      color: bg,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Back + title row
        Row(children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back to Users',
          ),
          const SizedBox(width: 8),
          Text('User Detail',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const Spacer(),
          if (u != null) ...[
            _QuickAction(
              label: u.isActive ? 'Deactivate' : 'Activate',
              icon: u.isActive
                  ? Icons.pause_circle_outline_rounded
                  : Icons.play_circle_outline_rounded,
              color: u.isActive ? AppColors.warning : AppColors.success,
              onTap: () => _toggleStatus(context, ref, u),
            ),
            const SizedBox(width: 8),
            _QuickAction(
              label: 'Delete',
              icon: Icons.delete_outline_rounded,
              color: AppColors.error,
              onTap: () => _confirmDelete(context, ref, u),
            ),
          ],
        ]),
        if (u != null) ...[
          const SizedBox(height: 16),
          Row(children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.accent.withValues(alpha: 0.15),
              child: Text(
                u.fullName.isNotEmpty
                    ? u.fullName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(u.fullName,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text(u.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.lightTextMuted)),
              ]),
            ),
            _StatusBadge(isActive: u.isActive),
            const SizedBox(width: 10),
            _RoleBadge(role: u.role),
          ]),
          const SizedBox(height: 16),
        ],
      ]),
    ).animate().fadeIn(duration: 350.ms);
  }

  Future<void> _toggleStatus(
      BuildContext ctx, WidgetRef ref, AdminUser u) async {
    final notifier = ref.read(userDetailProvider(userId).notifier);
    final err = await notifier.updateStatus(!u.isActive);
    if (ctx.mounted) {
      _snack(ctx, err ?? '${u.fullName} ${!u.isActive ? "activated" : "deactivated"}',
          err == null ? AppColors.success : AppColors.error);
    }
  }

  Future<void> _confirmDelete(
      BuildContext ctx, WidgetRef ref, AdminUser u) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (d) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Permanently delete "${u.fullName}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: const Text('Cancel')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.pop(d, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true || !ctx.mounted) return;
    final deleted =
        await ref.read(usersProvider.notifier).deleteUser(userId);
    if (ctx.mounted) {
      _snack(ctx, deleted ? 'User deleted' : 'Failed to delete',
          deleted ? AppColors.success : AppColors.error);
      if (deleted) Navigator.of(ctx).pop();
    }
  }
}

void _snack(BuildContext ctx, String msg, Color color) {
  ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color,
          duration: const Duration(seconds: 3)));
}

// ── Shared small widgets ──────────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 14, color: color),
        label: Text(label, style: TextStyle(color: color, fontSize: 12)),
        style: OutlinedButton.styleFrom(
            side: BorderSide(color: color.withValues(alpha: 0.5)),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: Size.zero),
      );
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});
  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: (isActive ? AppColors.success : AppColors.error)
              .withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(isActive ? 'Active' : 'Inactive',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.success : AppColors.error)),
      );
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});
  Color get _color => switch (role) {
        'super_admin' => AppColors.riskCritical,
        'admin' => AppColors.error,
        'doctor' => AppColors.info,
        _ => AppColors.primary,
      };
  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(role.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _color)),
      );
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: AppColors.errorSurface,
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(children: [
          const Icon(Icons.error_outline_rounded,
              size: 16, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
              child: Text(message,
                  style: const TextStyle(
                      color: AppColors.error, fontSize: 13))),
        ]),
      );
}

class _TabBar extends StatelessWidget {
  final TabController controller;
  final List<Tab> tabs;
  const _TabBar({required this.controller, required this.tabs});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color:
          isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: tabs,
        labelStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        dividerColor: isDark
            ? AppColors.darkBorder
            : AppColors.lightBorder,
      ),
    );
  }
}

Widget _infoRow(BuildContext context, String label, String value) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 160,
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
                        ?.copyWith(fontWeight: FontWeight.w500))),
          ]),
    );

Widget _sectionCard(BuildContext context,
    {required String title,
    required List<Widget> children}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: isDark
                ? AppColors.darkBorder
                : AppColors.lightBorder)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...children,
          ]),
    ),
  );
}

// ── Tab 0 — Profile ───────────────────────────────────────────────────────────

class _ProfileTab extends ConsumerWidget {
  final String userId;
  const _ProfileTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userDetailProvider(userId));
    final u = state.user;
    if (u == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final fmt = DateFormat('MMM d, yyyy HH:mm');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionCard(context, title: 'Account Information', children: [
          _infoRow(context, 'Full Name', u.fullName),
          _infoRow(context, 'Email', u.email),
          _infoRow(context, 'Phone', u.phone ?? 'Not set'),
          _infoRow(context, 'Role',
              u.role.replaceAll('_', ' ').toUpperCase()),
          _infoRow(context, 'Language', u.language.toUpperCase()),
          _infoRow(context, 'Status',
              u.isActive ? 'Active' : 'Inactive'),
          _infoRow(context, 'Email Verified',
              u.emailVerified ? 'Yes' : 'No'),
        ]),
        _sectionCard(context, title: 'Activity Summary', children: [
          _infoRow(context, 'Chat Conversations',
              '${u.totalConversations}'),
          _infoRow(context, 'Emergency Assessments',
              '${u.totalEmergencyAssessments}'),
          _infoRow(context, 'Joined',
              DateFormat('MMMM d, yyyy').format(u.createdAt)),
          if (u.lastLogin != null)
            _infoRow(context, 'Last Login',
                fmt.format(u.lastLogin!)),
        ]),
        _sectionCard(context, title: 'Quick Controls', children: [
          Wrap(spacing: 10, runSpacing: 10, children: [
            _ControlButton(
              label:
                  u.isActive ? 'Deactivate Account' : 'Activate Account',
              icon: u.isActive
                  ? Icons.pause_circle_rounded
                  : Icons.play_circle_rounded,
              color:
                  u.isActive ? AppColors.warning : AppColors.success,
              onTap: () => _toggleStatus(context, ref, u),
            ),
            _ControlButton(
              label: 'Change Role',
              icon: Icons.admin_panel_settings_rounded,
              color: AppColors.accent,
              onTap: () => _changeRole(context, ref, u),
            ),
            _ControlButton(
              label: 'Reset Password',
              icon: Icons.lock_reset_rounded,
              color: AppColors.warning,
              onTap: () => _resetPassword(context, ref),
            ),
            _ControlButton(
              label: 'Revoke Sessions',
              icon: Icons.logout_rounded,
              color: AppColors.error,
              onTap: () => _revokeSessions(context, ref, u),
            ),
          ]),
        ]),
      ]).animate().fadeIn(delay: 50.ms),
    );
  }

  Future<void> _toggleStatus(
      BuildContext ctx, WidgetRef ref, AdminUser u) async {
    final err = await ref
        .read(userDetailProvider(userId).notifier)
        .updateStatus(!u.isActive);
    if (ctx.mounted) {
      _snack(ctx,
          err ??
              '${u.fullName} ${!u.isActive ? "activated" : "deactivated"}',
          err == null ? AppColors.success : AppColors.error);
    }
  }

  Future<void> _changeRole(
      BuildContext ctx, WidgetRef ref, AdminUser u) async {
    String role = u.role;
    final confirmed = await showDialog<String>(
      context: ctx,
      builder: (d) => StatefulBuilder(
        builder: (d, setState) => AlertDialog(
          title: Text('Change Role — ${u.fullName}'),
          content: DropdownButtonFormField<String>(
            value: role,
            items: ['patient', 'doctor', 'admin', 'super_admin']
                .map((r) => DropdownMenuItem(
                    value: r,
                    child: Text(
                        r.replaceAll('_', ' ').toUpperCase())))
                .toList(),
            onChanged: (v) => setState(() => role = v!),
            decoration:
                const InputDecoration(labelText: 'New Role'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(d),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(d, role),
                child: const Text('Save')),
          ],
        ),
      ),
    );
    if (confirmed == null || !ctx.mounted) return;
    final err = await ref
        .read(userDetailProvider(userId).notifier)
        .updateRole(confirmed);
    if (ctx.mounted) {
      _snack(ctx, err ?? 'Role updated to $confirmed',
          err == null ? AppColors.success : AppColors.error);
    }
  }

  Future<void> _resetPassword(
      BuildContext ctx, WidgetRef ref) async {
    final ctrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (d) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(
              labelText: 'New Password (min 6 chars)',
              border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: const Text('Cancel')),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.warning),
              onPressed: () => Navigator.pop(d, true),
              child: const Text('Reset')),
        ],
      ),
    );
    ctrl.dispose();
    if (confirmed != true || !ctx.mounted) return;
    final err = await ref
        .read(userDetailProvider(userId).notifier)
        .resetPassword(ctrl.text.trim());
    if (ctx.mounted) {
      _snack(ctx, err ?? 'Password reset successfully',
          err == null ? AppColors.success : AppColors.error);
    }
  }

  Future<void> _revokeSessions(
      BuildContext ctx, WidgetRef ref, AdminUser u) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (d) => AlertDialog(
        title: const Text('Revoke All Sessions'),
        content: Text(
            'Force-logout ${u.fullName} from all devices? They will need to sign in again.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: const Text('Cancel')),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error),
              onPressed: () => Navigator.pop(d, true),
              child: const Text('Revoke All')),
        ],
      ),
    );
    if (ok != true || !ctx.mounted) return;
    final msg = await ref
        .read(userDetailProvider(userId).notifier)
        .revokeSessions();
    if (ctx.mounted) {
      _snack(ctx, msg ?? 'Sessions revoked',
          msg != null ? AppColors.success : AppColors.error);
    }
  }
}

class _ControlButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ControlButton(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16, color: color),
        label: Text(label,
            style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
            side: BorderSide(color: color.withValues(alpha: 0.5)),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10)),
      );
}

// ── Tab 1 — Edit Profile ──────────────────────────────────────────────────────

class _EditTab extends ConsumerStatefulWidget {
  final String userId;
  const _EditTab({required this.userId});
  @override
  ConsumerState<_EditTab> createState() => _EditTabState();
}

class _EditTabState extends ConsumerState<_EditTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _language = 'en';
  bool _emailVerified = false;
  bool _phoneVerified = false;
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _populate(AdminUser u) {
    if (_loaded) return;
    _nameCtrl.text = u.fullName;
    _phoneCtrl.text = u.phone ?? '';
    _language = u.language;
    _emailVerified = u.emailVerified;
    _phoneVerified = false;
    _loaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userDetailProvider(widget.userId));
    final u = state.user;
    if (u != null) _populate(u);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          _sectionCard(context,
              title: 'Edit Profile Details',
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_rounded)),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Name is required'
                          : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Phone (optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone_rounded)),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _language,
                  decoration: const InputDecoration(
                      labelText: 'Language',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.language_rounded)),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                    DropdownMenuItem(value: 'ne', child: Text('Nepali')),
                    DropdownMenuItem(value: 'es', child: Text('Spanish')),
                    DropdownMenuItem(value: 'fr', child: Text('French')),
                  ],
                  onChanged: (v) => setState(() => _language = v!),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Email Verified',
                          style: TextStyle(fontSize: 13)),
                      value: _emailVerified,
                      onChanged: (v) =>
                          setState(() => _emailVerified = v!),
                      controlAffinity:
                          ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Phone Verified',
                          style: TextStyle(fontSize: 13)),
                      value: _phoneVerified,
                      onChanged: (v) =>
                          setState(() => _phoneVerified = v!),
                      controlAffinity:
                          ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ]),
              ]),
          _sectionCard(context,
              title: 'Force Reset Password',
              children: [
                _ResetPasswordCard(userId: widget.userId),
              ]),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white))
                  : const Icon(Icons.save_rounded, size: 18),
              label: Text(
                  _saving ? 'Saving…' : 'Save Changes'),
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: _saving ? null : () => _save(context),
            ),
          ),
        ]).animate().fadeIn(delay: 50.ms),
      ),
    );
  }

  Future<void> _save(BuildContext ctx) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final err = await ref
        .read(userDetailProvider(widget.userId).notifier)
        .updateProfile(
          fullName: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim().isEmpty
              ? null
              : _phoneCtrl.text.trim(),
          language: _language,
          emailVerified: _emailVerified,
          phoneVerified: _phoneVerified,
        );
    setState(() => _saving = false);
    if (ctx.mounted) {
      _snack(ctx, err ?? 'Profile saved successfully',
          err == null ? AppColors.success : AppColors.error);
    }
  }
}

class _ResetPasswordCard extends ConsumerStatefulWidget {
  final String userId;
  const _ResetPasswordCard({required this.userId});
  @override
  ConsumerState<_ResetPasswordCard> createState() =>
      _ResetPasswordCardState();
}

class _ResetPasswordCardState
    extends ConsumerState<_ResetPasswordCard> {
  final _pwCtrl = TextEditingController();
  bool _saving = false;
  bool _obscure = true;

  @override
  void dispose() {
    _pwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        TextField(
          controller: _pwCtrl,
          obscureText: _obscure,
          decoration: InputDecoration(
            labelText: 'New Password (min 6 chars)',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock_rounded),
            suffixIcon: IconButton(
              icon: Icon(
                  _obscure
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  size: 18),
              onPressed: () =>
                  setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            icon: _saving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white))
                : const Icon(Icons.lock_reset_rounded, size: 16),
            label:
                Text(_saving ? 'Resetting…' : 'Reset Password'),
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.warning),
            onPressed: _saving ? null : () => _reset(context),
          ),
        ),
      ]);

  Future<void> _reset(BuildContext ctx) async {
    final pw = _pwCtrl.text.trim();
    if (pw.length < 6) {
      _snack(ctx, 'Password must be at least 6 characters',
          AppColors.error);
      return;
    }
    setState(() => _saving = true);
    final err = await ref
        .read(userDetailProvider(widget.userId).notifier)
        .resetPassword(pw);
    setState(() => _saving = false);
    if (ctx.mounted) {
      if (err == null) _pwCtrl.clear();
      _snack(ctx, err ?? 'Password reset successfully',
          err == null ? AppColors.success : AppColors.error);
    }
  }
}

// ── Tab 2 — Chats ─────────────────────────────────────────────────────────────

class _ChatsTab extends ConsumerWidget {
  final String userId;
  const _ChatsTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userDetailProvider(userId));
    final notifier = ref.read(userDetailProvider(userId).notifier);

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(children: [
          Text(
            '${state.conversationsTotal} conversations',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 18),
            onPressed: () => notifier.loadConversations(),
            tooltip: 'Refresh',
          ),
        ]),
      ),
      Expanded(
        child: state.conversationsLoading
            ? const Center(child: CircularProgressIndicator())
            : state.conversations.isEmpty
                ? _EmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'No conversations yet')
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: state.conversations.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final c = state.conversations[i];
                      return _ChatTile(conv: c);
                    },
                  ),
      ),
      if (state.conversationsTotal > 15)
        _Pagination(
          current: state.conversationsPage,
          total: (state.conversationsTotal / 15).ceil(),
          onChanged: (p) => notifier.loadConversations(page: p),
        ),
    ]);
  }
}

class _ChatTile extends StatelessWidget {
  final UserConversation conv;
  const _ChatTile({required this.conv});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
              color: isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.chat_rounded,
                size: 18, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            Text(conv.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 3),
            Row(children: [
              _MiniChip('${conv.messageCount} msgs',
                  AppColors.accent),
              const SizedBox(width: 6),
              if (conv.emergencyCount > 0)
                _MiniChip(
                    '${conv.emergencyCount} 🚨',
                    AppColors.error),
              const SizedBox(width: 6),
              _MiniChip(conv.language.toUpperCase(),
                  AppColors.lightTextMuted),
            ]),
          ])),
          const SizedBox(width: 10),
          Text(
            DateFormat('MMM d, yy').format(conv.createdAt),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ]),
      ),
    );
  }
}

// ── Tab 3 — Emergency ─────────────────────────────────────────────────────────

class _EmergencyTab extends ConsumerWidget {
  final String userId;
  const _EmergencyTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userDetailProvider(userId));
    final notifier = ref.read(userDetailProvider(userId).notifier);

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(children: [
          Text('${state.emergenciesTotal} assessments',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 18),
            onPressed: () => notifier.loadEmergencies(),
            tooltip: 'Refresh',
          ),
        ]),
      ),
      Expanded(
        child: state.emergenciesLoading
            ? const Center(child: CircularProgressIndicator())
            : state.emergencies.isEmpty
                ? _EmptyState(
                    icon: Icons.health_and_safety_outlined,
                    label: 'No emergency assessments')
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: state.emergencies.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (ctx, i) =>
                        _EmergencyTile(e: state.emergencies[i]),
                  ),
      ),
      if (state.emergenciesTotal > 15)
        _Pagination(
          current: state.emergenciesPage,
          total: (state.emergenciesTotal / 15).ceil(),
          onChanged: (p) => notifier.loadEmergencies(page: p),
        ),
    ]);
  }
}

class _EmergencyTile extends StatelessWidget {
  final UserEmergency e;
  const _EmergencyTile({required this.e});

  Color get _riskColor => switch (e.riskLevel.toUpperCase()) {
        'CRITICAL' => AppColors.riskCritical,
        'HIGH'     => AppColors.riskHigh,
        'MEDIUM'   => AppColors.riskMedium,
        _          => AppColors.riskLow,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
              color: e.isEmergency
                  ? AppColors.error.withValues(alpha: 0.4)
                  : (isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder))),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: _riskColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6)),
              child: Text(e.riskLevel,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _riskColor)),
            ),
            const SizedBox(width: 8),
            if (e.isEmergency)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: AppColors.errorSurface,
                    borderRadius: BorderRadius.circular(6)),
                child: const Text('EMERGENCY',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error)),
              ),
            const Spacer(),
            Text(DateFormat('MMM d, yy HH:mm').format(e.createdAt),
                style: Theme.of(context).textTheme.labelSmall),
          ]),
          const SizedBox(height: 8),
          if (e.possibleEmergency != null)
            Text(e.possibleEmergency!,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: e.symptoms
                .take(6)
                .map((s) => _MiniChip(s, AppColors.primary))
                .toList(),
          ),
          if (e.age != null || e.gender != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                [
                  if (e.age != null) 'Age ${e.age}',
                  if (e.gender != null)
                    e.gender!.toUpperCase(),
                ].join(' · '),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          if (e.sosCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(children: [
                const Icon(Icons.sos_rounded,
                    size: 14, color: AppColors.error),
                const SizedBox(width: 4),
                Text('SOS triggered ${e.sosCount}×',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.error,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
        ]),
      ),
    );
  }
}

// ── Tab 4 — Symptoms ──────────────────────────────────────────────────────────

class _SymptomsTab extends ConsumerWidget {
  final String userId;
  const _SymptomsTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userDetailProvider(userId));
    final notifier = ref.read(userDetailProvider(userId).notifier);

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(children: [
          Text('${state.symptomChecksTotal} symptom checks',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 18),
            onPressed: () => notifier.loadSymptomChecks(),
            tooltip: 'Refresh',
          ),
        ]),
      ),
      Expanded(
        child: state.symptomChecksLoading
            ? const Center(child: CircularProgressIndicator())
            : state.symptomChecks.isEmpty
                ? _EmptyState(
                    icon: Icons.monitor_heart_outlined,
                    label: 'No symptom checks yet')
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: state.symptomChecks.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (ctx, i) =>
                        _SymptomTile(sc: state.symptomChecks[i]),
                  ),
      ),
      if (state.symptomChecksTotal > 15)
        _Pagination(
          current: state.symptomChecksPage,
          total: (state.symptomChecksTotal / 15).ceil(),
          onChanged: (p) => notifier.loadSymptomChecks(page: p),
        ),
    ]);
  }
}

class _SymptomTile extends StatelessWidget {
  final UserSymptomCheck sc;
  const _SymptomTile({required this.sc});

  Color get _riskColor => switch (sc.riskLevel.toUpperCase()) {
        'CRITICAL' => AppColors.riskCritical,
        'HIGH'     => AppColors.riskHigh,
        'MEDIUM'   => AppColors.riskMedium,
        _          => AppColors.riskLow,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
              color: isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: _riskColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6)),
              child: Text(sc.riskLevel,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _riskColor)),
            ),
            const SizedBox(width: 8),
            if (sc.isEmergency)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: AppColors.errorSurface,
                    borderRadius: BorderRadius.circular(6)),
                child: const Text('EMERGENCY',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error)),
              ),
            const Spacer(),
            Text(DateFormat('MMM d, yy').format(sc.createdAt),
                style: Theme.of(context).textTheme.labelSmall),
          ]),
          const SizedBox(height: 8),
          if (sc.predictedDisease != null)
            Row(children: [
              const Icon(Icons.local_hospital_rounded,
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(sc.predictedDisease!,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ),
              if (sc.confidence != null)
                Text(
                    '${(sc.confidence! * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.lightTextMuted)),
            ]),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: sc.symptoms
                .take(6)
                .map((s) => _MiniChip(s, AppColors.primary))
                .toList(),
          ),
          if (sc.age != null || sc.gender != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                [
                  if (sc.age != null) 'Age ${sc.age}',
                  if (sc.gender != null) sc.gender!.toUpperCase(),
                ].join(' · '),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
        ]),
      ),
    );
  }
}

// ── Tab 5 — Sessions ──────────────────────────────────────────────────────────

class _SessionsTab extends ConsumerWidget {
  final String userId;
  const _SessionsTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userDetailProvider(userId));
    final notifier = ref.read(userDetailProvider(userId).notifier);
    final user = state.user;

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${state.sessions.length} sessions',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            Text('${state.activeSessionCount} active',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.success)),
          ]),
          const Spacer(),
          if (state.activeSessionCount > 0 && user != null)
            OutlinedButton.icon(
              icon: const Icon(Icons.logout_rounded,
                  size: 14, color: AppColors.error),
              label: const Text('Revoke All',
                  style: TextStyle(
                      color: AppColors.error, fontSize: 12)),
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: AppColors.error),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  minimumSize: Size.zero),
              onPressed: () =>
                  _revokeAll(context, ref, user),
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 18),
            onPressed: () => notifier.loadSessions(),
            tooltip: 'Refresh',
          ),
        ]),
      ),
      Expanded(
        child: state.sessionsLoading
            ? const Center(child: CircularProgressIndicator())
            : state.sessions.isEmpty
                ? _EmptyState(
                    icon: Icons.devices_outlined,
                    label: 'No sessions found')
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: state.sessions.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (ctx, i) =>
                        _SessionTile(s: state.sessions[i]),
                  ),
      ),
    ]);
  }

  Future<void> _revokeAll(
      BuildContext ctx, WidgetRef ref, AdminUser u) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (d) => AlertDialog(
        title: const Text('Revoke All Sessions'),
        content: Text(
            'Force-logout ${u.fullName} from all devices?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: const Text('Cancel')),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error),
              onPressed: () => Navigator.pop(d, true),
              child: const Text('Revoke All')),
        ],
      ),
    );
    if (ok != true || !ctx.mounted) return;
    final msg = await ref
        .read(userDetailProvider(userId).notifier)
        .revokeSessions();
    if (ctx.mounted) {
      _snack(ctx, msg ?? 'Sessions revoked',
          msg != null ? AppColors.success : AppColors.error);
    }
  }
}

class _SessionTile extends StatelessWidget {
  final UserSession s;
  const _SessionTile({required this.s});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final device = s.deviceInfo ?? 'Unknown device';
    return Card(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
              color: s.isActive
                  ? AppColors.success.withValues(alpha: 0.35)
                  : (isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder))),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Icon(
            device.toLowerCase().contains('mobile') ||
                    device.toLowerCase().contains('android') ||
                    device.toLowerCase().contains('ios')
                ? Icons.smartphone_rounded
                : Icons.computer_rounded,
            size: 24,
            color: s.isActive
                ? AppColors.success
                : AppColors.lightTextMuted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(device,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
              const SizedBox(height: 3),
              Text(
                [
                  if (s.ipAddress != null) s.ipAddress!,
                  'Last: ${DateFormat("MMM d HH:mm").format(s.lastActiveAt)}',
                ].join(' · '),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: (s.isActive
                        ? AppColors.success
                        : AppColors.lightTextLight)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6)),
            child: Text(s.isActive ? 'Active' : 'Expired',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: s.isActive
                        ? AppColors.success
                        : AppColors.lightTextMuted)),
          ),
        ]),
      ),
    );
  }
}

// ── Shared micro-widgets ──────────────────────────────────────────────────────

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4)),
        child: Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color)),
      );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String label;
  const _EmptyState({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.lightTextLight),
            const SizedBox(height: 12),
            Text(label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightTextMuted)),
          ],
        ),
      );
}

class _Pagination extends StatelessWidget {
  final int current;
  final int total;
  final ValueChanged<int> onChanged;
  const _Pagination(
      {required this.current,
      required this.total,
      required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed:
                  current > 1 ? () => onChanged(current - 1) : null,
            ),
            Text('$current / $total',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: current < total
                  ? () => onChanged(current + 1)
                  : null,
            ),
          ],
        ),
      );
}
