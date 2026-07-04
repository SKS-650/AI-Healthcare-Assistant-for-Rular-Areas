import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../routing/route_names.dart';
import '../../../../../shared/design_system/design_tokens.dart';
import '../../../authentication/presentation/providers/authentication_provider.dart';
import '../providers/user_profile_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _editing = false;

  final _nameCtrl       = TextEditingController();
  final _phoneCtrl      = TextEditingController();
  final _occupationCtrl = TextEditingController();
  final _bioCtrl        = TextEditingController();
  final _heightCtrl     = TextEditingController();
  final _weightCtrl     = TextEditingController();
  final _allergiesCtrl  = TextEditingController();
  final _chronicCtrl    = TextEditingController();
  final _medsCtrl       = TextEditingController();
  final _notesCtrl      = TextEditingController();

  String? _gender;
  String? _bloodGroup;
  String? _maritalStatus;
  bool _smokingStatus     = false;
  bool _alcoholConsumption = false;

  static const _genders     = ['male', 'female', 'non-binary', 'prefer not to say'];
  static const _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  static const _maritalOpts = ['single', 'married', 'divorced', 'widowed'];

  @override
  void initState() {
    super.initState();
    // Load real data when page opens
    Future.microtask(() => ref.read(userProfileProvider.notifier).loadProfile());
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _phoneCtrl, _occupationCtrl, _bioCtrl,
      _heightCtrl, _weightCtrl, _allergiesCtrl, _chronicCtrl,
      _medsCtrl, _notesCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  /// Populate controllers from the loaded profile data.
  void _populateFromProfile(UserFullProfile p) {
    _nameCtrl.text       = p.fullName;
    _phoneCtrl.text      = p.phone ?? '';
    _occupationCtrl.text = p.occupation ?? '';
    _bioCtrl.text        = p.bio ?? '';
    _heightCtrl.text     = p.heightCm?.toString() ?? '';
    _weightCtrl.text     = p.weightKg?.toString() ?? '';
    _allergiesCtrl.text  = p.allergies.join(', ');
    _chronicCtrl.text    = p.chronicDiseases.join(', ');
    _medsCtrl.text       = p.currentMedications.join(', ');
    _notesCtrl.text      = p.medicalNotes ?? '';
    _gender              = _genders.contains(p.gender) ? p.gender : null;
    _bloodGroup          = _bloodGroups.contains(p.bloodGroup) ? p.bloodGroup : null;
    _maritalStatus       = _maritalOpts.contains(p.maritalStatus) ? p.maritalStatus : null;
    _smokingStatus       = p.smokingStatus;
    _alcoholConsumption  = p.alcoholConsumption;
  }

  void _startEditing(UserFullProfile p) {
    _populateFromProfile(p);
    setState(() => _editing = true);
  }

  void _cancelEditing() {
    FocusScope.of(context).unfocus();
    setState(() => _editing = false);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await ref.read(userProfileProvider.notifier).saveProfile(
      fullName:           _nameCtrl.text.trim(),
      phone:              _phoneCtrl.text.trim(),
      gender:             _gender,
      bloodGroup:         _bloodGroup,
      heightCm:           double.tryParse(_heightCtrl.text.trim()),
      weightKg:           double.tryParse(_weightCtrl.text.trim()),
      occupation:         _occupationCtrl.text.trim(),
      maritalStatus:      _maritalStatus,
      bio:                _bioCtrl.text.trim(),
      allergies:          _splitList(_allergiesCtrl.text),
      chronicDiseases:    _splitList(_chronicCtrl.text),
      currentMedications: _splitList(_medsCtrl.text),
      smokingStatus:      _smokingStatus,
      alcoholConsumption: _alcoholConsumption,
      medicalNotes:       _notesCtrl.text.trim(),
    );

    if (ok && mounted) {
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text('Profile updated successfully!'),
        ]),
        backgroundColor: DesignTokens.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  static List<String> _splitList(String raw) =>
      raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  // ── Logout ──────────────────────────────────────────────────────────────────

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: DesignTokens.danger),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await ref.read(authControllerProvider.notifier).logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.login, (r) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileProvider);

    // Respond to save errors
    ref.listen<UserProfileState>(userProfileProvider, (_, next) {
      if (next.error != null && !next.isSaving) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error!),
          backgroundColor: DesignTokens.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    });

    final p = profileState.profile;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: _editing ? _cancelEditing : () => Navigator.of(context).pop(),
              )
            : null,
        title: const Row(children: [
          Text('👤', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Text('My Profile', style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w800, color: DesignTokens.textStrong,
          )),
        ]),
        actions: [
          if (!_editing) ...[
            if (p != null)
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: DesignTokens.primary, size: 20),
                tooltip: 'Edit profile',
                onPressed: () => _startEditing(p),
              ),
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: DesignTokens.danger, size: 20),
              tooltip: 'Sign out',
              onPressed: _logout,
            ),
          ] else ...[
            TextButton(
              onPressed: profileState.isSaving ? null : _cancelEditing,
              child: const Text('Cancel', style: TextStyle(color: DesignTokens.textMuted)),
            ),
          ],
        ],
      ),
      body: _buildBody(profileState),
    );
  }

  Widget _buildBody(UserProfileState profileState) {
    if (profileState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: DesignTokens.primary),
      );
    }

    if (profileState.error != null && profileState.profile == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(profileState.error!, textAlign: TextAlign.center,
              style: const TextStyle(color: DesignTokens.textMuted, fontSize: 15)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.read(userProfileProvider.notifier).loadProfile(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(backgroundColor: DesignTokens.primary),
            ),
          ]),
        ),
      );
    }

    final p = profileState.profile;
    if (p == null) return const SizedBox.shrink();

    return Form(
      key: _formKey,
      child: Stack(children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(bottom: _editing ? 90 : 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildHeader(p),
            const SizedBox(height: 20),
            _buildSection('👤', 'Personal', [
              _field('Full Name', _nameCtrl, editing: _editing,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
              _field('Phone', _phoneCtrl, editing: _editing,
                keyboardType: TextInputType.phone),
              _field('Occupation', _occupationCtrl, editing: _editing),
              _dropdown('Gender', _genders, _gender, editing: _editing,
                onChanged: (v) => setState(() => _gender = v)),
              _dropdown('Marital Status', _maritalOpts, _maritalStatus, editing: _editing,
                onChanged: (v) => setState(() => _maritalStatus = v)),
              _field('Bio', _bioCtrl, editing: _editing, maxLines: 2),
            ]),
            const SizedBox(height: 20),
            _buildSection('🩺', 'Health Details', [
              _dropdown('Blood Group', _bloodGroups, _bloodGroup, editing: _editing,
                onChanged: (v) => setState(() => _bloodGroup = v)),
              _field('Height (cm)', _heightCtrl, editing: _editing,
                keyboardType: TextInputType.number),
              _field('Weight (kg)', _weightCtrl, editing: _editing,
                keyboardType: TextInputType.number),
            ]),
            const SizedBox(height: 20),
            _buildSection('💊', 'Medical Info', [
              _field('Allergies', _allergiesCtrl, editing: _editing,
                hint: 'e.g. Penicillin, Dust'),
              _field('Chronic Diseases', _chronicCtrl, editing: _editing,
                hint: 'e.g. Diabetes Type 2'),
              _field('Current Medications', _medsCtrl, editing: _editing,
                hint: 'e.g. Metformin 500mg'),
              _field('Notes', _notesCtrl, editing: _editing, maxLines: 2),
              if (_editing) ...[
                _toggle('Smoking', _smokingStatus,
                  onChanged: (v) => setState(() => _smokingStatus = v)),
                _toggle('Alcohol', _alcoholConsumption,
                  onChanged: (v) => setState(() => _alcoholConsumption = v)),
              ] else ...[
                _infoRow('🚭', 'Smoking', p.smokingStatus ? 'Yes' : 'No'),
                _infoRow('🥛', 'Alcohol', p.alcoholConsumption ? 'Yes' : 'No'),
              ],
            ]),
            const SizedBox(height: 16),
            _buildAccountInfo(p),
            const SizedBox(height: 32),
          ]),
        ),
        if (_editing)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _SaveBar(saving: profileState.isSaving, onSave: _save),
          ),
      ]),
    );
  }

  // ── Header card ─────────────────────────────────────────────────────────────

  Widget _buildHeader(UserFullProfile p) {
    final initials = p.fullName.trim().split(' ') is List
        ? (() {
            final parts = p.fullName.trim().split(' ');
            return parts.length >= 2
                ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
                : p.fullName.substring(0, p.fullName.length >= 2 ? 2 : 1).toUpperCase();
          })()
        : '??';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DesignTokens.primary, DesignTokens.primaryDark],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(
          color: DesignTokens.primary.withValues(alpha: 0.35),
          blurRadius: 20, offset: const Offset(0, 8),
        )],
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          child: Text(initials, style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.fullName, style: const TextStyle(
            color: Colors.white, fontSize: 20,
            fontWeight: FontWeight.w900, letterSpacing: -0.3)),
          const SizedBox(height: 3),
          Text(p.email, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          if (p.phone != null && p.phone!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(p.phone!, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
          if (p.role != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(p.role!.toUpperCase(), style: const TextStyle(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700,
                letterSpacing: 0.8)),
            ),
          ],
        ])),
      ]),
    );
  }

  // ── Section wrapper ──────────────────────────────────────────────────────────

  Widget _buildSection(String emoji, String title, List<Widget> children) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w800,
            color: DesignTokens.textStrong, letterSpacing: -0.2)),
          if (_editing) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: DesignTokens.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('editable', style: TextStyle(
                fontSize: 10, color: DesignTokens.primary, fontWeight: FontWeight.w700)),
            ),
          ],
        ]),
      ),
      const SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: children),
      ),
    ]);
  }

  // ── Account info (read-only) ─────────────────────────────────────────────────

  Widget _buildAccountInfo(UserFullProfile p) {
    return _buildSection('🔐', 'Account Info', [
      if (p.bloodGroup != null) _infoRow('🩸', 'Blood Group', p.bloodGroup!),
      if (p.gender != null) _infoRow('⚧️', 'Gender', p.gender!),
      if (p.maritalStatus != null) _infoRow('💍', 'Marital Status', p.maritalStatus!),
      if (p.occupation != null) _infoRow('💼', 'Occupation', p.occupation!),
      if (p.heightCm != null) _infoRow('📏', 'Height', '${p.heightCm} cm'),
      if (p.weightKg != null) _infoRow('⚖️', 'Weight', '${p.weightKg} kg'),
      if (p.bio != null && p.bio!.isNotEmpty) _infoRow('📝', 'Bio', p.bio!),
    ]);
  }

  // ── Reusable field widgets ───────────────────────────────────────────────────

  Widget _field(
    String label,
    TextEditingController ctrl, {
    required bool editing,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    if (!editing) {
      final value = ctrl.text.trim();
      if (value.isEmpty) return const SizedBox.shrink();
      return _infoRow('', label, value);
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(fontSize: 14, color: DesignTokens.textStrong),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: DesignTokens.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: DesignTokens.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: DesignTokens.primary.withValues(alpha: 0.4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: DesignTokens.primary, width: 1.8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: DesignTokens.danger),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: DesignTokens.danger, width: 1.8),
          ),
          labelStyle: const TextStyle(color: DesignTokens.textMuted, fontSize: 13),
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    List<String> options,
    String? value, {
    required bool editing,
    required ValueChanged<String?> onChanged,
  }) {
    if (!editing) {
      if (value == null || value.isEmpty) return const SizedBox.shrink();
      return _infoRow('', label, value);
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: DropdownButtonFormField<String>(
        value: options.contains(value) ? value : null,
        items: options.map((o) => DropdownMenuItem(
          value: o,
          child: Text(o, style: const TextStyle(fontSize: 14)),
        )).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: DesignTokens.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: DesignTokens.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: DesignTokens.primary.withValues(alpha: 0.4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: DesignTokens.primary, width: 1.8),
          ),
          labelStyle: const TextStyle(color: DesignTokens.textMuted, fontSize: 13),
        ),
        dropdownColor: DesignTokens.surface,
        borderRadius: BorderRadius.circular(14),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: DesignTokens.primary),
      ),
    );
  }

  Widget _toggle(String label, bool value, {required ValueChanged<bool> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DesignTokens.primary.withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        Text(label, style: const TextStyle(
          fontSize: 14, color: DesignTokens.textStrong, fontWeight: FontWeight.w600)),
        const Spacer(),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: DesignTokens.primary,
        ),
      ]),
    );
  }

  Widget _infoRow(String emoji, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DesignTokens.border),
      ),
      child: Row(children: [
        if (emoji.isNotEmpty) ...[
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
        ],
        Expanded(child: Text(label, style: const TextStyle(
          color: DesignTokens.textMuted, fontSize: 13, fontWeight: FontWeight.w500))),
        Flexible(child: Text(value, style: const TextStyle(
          fontWeight: FontWeight.w700, fontSize: 13, color: DesignTokens.textStrong),
          textAlign: TextAlign.end, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}

// ── Save bar ───────────────────────────────────────────────────────────────────

class _SaveBar extends StatelessWidget {
  final bool saving;
  final VoidCallback onSave;
  const _SaveBar({required this.saving, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 20, offset: const Offset(0, -6),
        )],
        border: Border(top: BorderSide(color: DesignTokens.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: saving ? null : const LinearGradient(
              colors: [DesignTokens.primary, DesignTokens.primaryDark],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            color: saving ? DesignTokens.border : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: saving ? [] : [BoxShadow(
              color: DesignTokens.primary.withValues(alpha: 0.35),
              blurRadius: 14, offset: const Offset(0, 5),
            )],
          ),
          child: FilledButton(
            onPressed: saving ? null : onSave,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: saving
                ? const SizedBox.square(dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.white)))
                : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.save_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ]),
          ),
        ),
      ),
    );
  }
}
