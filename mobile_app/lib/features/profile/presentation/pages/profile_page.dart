import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../authentication/presentation/providers/authentication_provider.dart';

// ── State model ───────────────────────────────────────────────────────────────

class _ProfileData {
  String name;
  String age;
  String gender;
  String bloodGroup;
  String phone;
  String village;
  String chronicConditions;
  String allergies;
  String currentMedications;
  String emergencyContact;
  String smoking;
  String alcohol;
  String exercise;
  String sleep;

  _ProfileData({
    this.name = 'Ramesh Kumar',
    this.age = '34',
    this.gender = 'Male',
    this.bloodGroup = 'O Positive',
    this.phone = '+91 98765 43210',
    this.village = 'Rampur, UP',
    this.chronicConditions = 'Hypertension',
    this.allergies = 'None known',
    this.currentMedications = 'Amlodipine 5mg',
    this.emergencyContact = 'Sita Devi • +91 87654 32109',
    this.smoking = 'Never',
    this.alcohol = 'Occasional',
    this.exercise = 'Medium',
    this.sleep = '7 hours/night',
  });

  _ProfileData copyWith({
    String? name, String? age, String? gender, String? bloodGroup,
    String? phone, String? village, String? chronicConditions,
    String? allergies, String? currentMedications, String? emergencyContact,
    String? smoking, String? alcohol, String? exercise, String? sleep,
  }) => _ProfileData(
    name: name ?? this.name, age: age ?? this.age,
    gender: gender ?? this.gender, bloodGroup: bloodGroup ?? this.bloodGroup,
    phone: phone ?? this.phone, village: village ?? this.village,
    chronicConditions: chronicConditions ?? this.chronicConditions,
    allergies: allergies ?? this.allergies,
    currentMedications: currentMedications ?? this.currentMedications,
    emergencyContact: emergencyContact ?? this.emergencyContact,
    smoking: smoking ?? this.smoking, alcohol: alcohol ?? this.alcohol,
    exercise: exercise ?? this.exercise, sleep: sleep ?? this.sleep,
  );
}

// ── Page ──────────────────────────────────────────────────────────────────────

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _editing = false;
  bool _saving = false;
  late _ProfileData _data;
  late _ProfileData _draft;

  // Controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _villageCtrl;
  late final TextEditingController _chronicCtrl;
  late final TextEditingController _allergiesCtrl;
  late final TextEditingController _medsCtrl;
  late final TextEditingController _emergencyCtrl;
  late final TextEditingController _sleepCtrl;

  static const _genders = ['Male', 'Female', 'Non-binary', 'Prefer not to say'];
  static const _bloodGroups = ['A Positive', 'A Negative', 'B Positive', 'B Negative',
    'O Positive', 'O Negative', 'AB Positive', 'AB Negative'];
  static const _smokingOpts = ['Never', 'Occasionally', 'Regularly', 'Quit'];
  static const _alcoholOpts = ['Never', 'Occasional', 'Moderate', 'Regular'];
  static const _exerciseOpts = ['None', 'Light', 'Medium', 'Active', 'Athlete'];

  @override
  void initState() {
    super.initState();
    _data = _ProfileData();
    _draft = _data.copyWith();
    _initControllers();
  }

  void _initControllers() {
    _nameCtrl      = TextEditingController(text: _draft.name);
    _ageCtrl       = TextEditingController(text: _draft.age);
    _phoneCtrl     = TextEditingController(text: _draft.phone);
    _villageCtrl   = TextEditingController(text: _draft.village);
    _chronicCtrl   = TextEditingController(text: _draft.chronicConditions);
    _allergiesCtrl = TextEditingController(text: _draft.allergies);
    _medsCtrl      = TextEditingController(text: _draft.currentMedications);
    _emergencyCtrl = TextEditingController(text: _draft.emergencyContact);
    _sleepCtrl     = TextEditingController(text: _draft.sleep);
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _ageCtrl, _phoneCtrl, _villageCtrl,
        _chronicCtrl, _allergiesCtrl, _medsCtrl, _emergencyCtrl, _sleepCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _startEditing() {
    _draft = _data.copyWith();
    _nameCtrl.text      = _draft.name;
    _ageCtrl.text       = _draft.age;
    _phoneCtrl.text     = _draft.phone;
    _villageCtrl.text   = _draft.village;
    _chronicCtrl.text   = _draft.chronicConditions;
    _allergiesCtrl.text = _draft.allergies;
    _medsCtrl.text      = _draft.currentMedications;
    _emergencyCtrl.text = _draft.emergencyContact;
    _sleepCtrl.text     = _draft.sleep;
    setState(() => _editing = true);
  }

  void _cancelEditing() {
    FocusScope.of(context).unfocus();
    setState(() { _editing = false; _draft = _data.copyWith(); });
  }

  Future<void> _saveChanges() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    // Simulate network save
    await Future.delayed(const Duration(milliseconds: 800));
    _data = _draft.copyWith(
      name: _nameCtrl.text.trim(),
      age: _ageCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      village: _villageCtrl.text.trim(),
      chronicConditions: _chronicCtrl.text.trim(),
      allergies: _allergiesCtrl.text.trim(),
      currentMedications: _medsCtrl.text.trim(),
      emergencyContact: _emergencyCtrl.text.trim(),
      sleep: _sleepCtrl.text.trim(),
    );
    setState(() { _saving = false; _editing = false; });
    if (mounted) {
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

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authControllerProvider).user;
    final displayName = authUser?.name ?? _data.name;

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
        title: const Row(
          children: [
            Text('👤', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('My Profile', style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800,
              color: DesignTokens.textStrong,
            )),
          ],
        ),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: DesignTokens.primary, size: 20),
              tooltip: 'Edit profile',
              onPressed: _startEditing,
            )
          else ...[
            TextButton(
              onPressed: _saving ? null : _cancelEditing,
              child: const Text('Cancel', style: TextStyle(color: DesignTokens.textMuted)),
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(displayName),
                  _buildStats(),
                  const SizedBox(height: 24),
                  _buildPersonalSection(),
                  const SizedBox(height: 24),
                  _buildMedicalSection(),
                  const SizedBox(height: 24),
                  _buildLifestyleSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            // Floating Save button when editing
            if (_editing)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: _SaveBar(saving: _saving, onSave: _saveChanges),
              ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(String displayName) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DesignTokens.primary, DesignTokens.primaryDark],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(
          color: DesignTokens.primary.withValues(alpha: 0.35),
          blurRadius: 24, offset: const Offset(0, 10),
        )],
      ),
      child: Row(
        children: [
          Stack(children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
              ),
              child: const Center(child: Text('👤', style: TextStyle(fontSize: 36))),
            ),
            if (_editing)
              Positioned(
                right: 0, bottom: 0,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: DesignTokens.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 13),
                  ),
                ),
              )
            else
              Positioned(
                right: 0, bottom: 0,
                child: Container(
                  width: 22, height: 22,
                  decoration: const BoxDecoration(color: DesignTokens.success, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                ),
              ),
          ]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_data.name, style: const TextStyle(
                  color: Colors.white, fontSize: 20,
                  fontWeight: FontWeight.w900, letterSpacing: -0.3,
                )),
                const SizedBox(height: 4),
                Text('Age ${_data.age} • ${_data.gender} • Blood: ${_data.bloodGroup.split(' ').first}${_data.bloodGroup.contains('Pos') ? '+' : '-'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.location_on_rounded, size: 12, color: Colors.white70),
                  const SizedBox(width: 3),
                  Expanded(child: Text(_data.village,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    overflow: TextOverflow.ellipsis)),
                ]),
              ],
            ),
          ),
          if (_editing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Editing', style: TextStyle(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  // ── Stats ───────────────────────────────────────────────────────────────────

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(children: [
        _StatCard(emoji: '❤️', label: 'Health Score', value: '78/100'),
        const SizedBox(width: 10),
        _StatCard(emoji: '🧬', label: 'Predictions', value: '12'),
        const SizedBox(width: 10),
        _StatCard(emoji: '📋', label: 'Records', value: '5'),
      ]),
    );
  }

  // ── Personal section ────────────────────────────────────────────────────────

  Widget _buildPersonalSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionHeader(emoji: '👤', title: 'Personal Information', editing: _editing),
      const SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: [
          _EditableRow(label: 'Full Name', emoji: '👤', editing: _editing,
            controller: _nameCtrl, staticValue: _data.name,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
          _EditableRow(label: 'Age', emoji: '🎂', editing: _editing,
            controller: _ageCtrl, staticValue: '${_data.age} years',
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              final n = int.tryParse(v);
              if (n == null || n < 1 || n > 120) return 'Invalid age';
              return null;
            }),
          _DropdownRow(label: 'Gender', emoji: '⚧️', editing: _editing,
            value: _draft.gender, options: _genders,
            staticValue: _data.gender,
            onChanged: (v) => setState(() => _draft = _draft.copyWith(gender: v))),
          _DropdownRow(label: 'Blood Group', emoji: '🩸', editing: _editing,
            value: _draft.bloodGroup, options: _bloodGroups,
            staticValue: _data.bloodGroup,
            onChanged: (v) => setState(() => _draft = _draft.copyWith(bloodGroup: v))),
          _EditableRow(label: 'Phone', emoji: '📱', editing: _editing,
            controller: _phoneCtrl, staticValue: _data.phone,
            keyboardType: TextInputType.phone),
          _EditableRow(label: 'Village', emoji: '🏡', editing: _editing,
            controller: _villageCtrl, staticValue: _data.village),
        ]),
      ),
    ]);
  }

  // ── Medical section ─────────────────────────────────────────────────────────

  Widget _buildMedicalSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionHeader(emoji: '🏥', title: 'Medical Information', editing: _editing),
      const SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: [
          _EditableRow(label: 'Chronic Conditions', emoji: '💊', editing: _editing,
            controller: _chronicCtrl, staticValue: _data.chronicConditions),
          _EditableRow(label: 'Allergies', emoji: '⚠️', editing: _editing,
            controller: _allergiesCtrl, staticValue: _data.allergies),
          _EditableRow(label: 'Current Medications', emoji: '💉', editing: _editing,
            controller: _medsCtrl, staticValue: _data.currentMedications),
          _EditableRow(label: 'Emergency Contact', emoji: '📞', editing: _editing,
            controller: _emergencyCtrl, staticValue: _data.emergencyContact),
        ]),
      ),
    ]);
  }

  // ── Lifestyle section ───────────────────────────────────────────────────────

  Widget _buildLifestyleSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionHeader(emoji: '🏃', title: 'Lifestyle', editing: _editing),
      const SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: [
          _DropdownRow(label: 'Smoking', emoji: '🚭', editing: _editing,
            value: _draft.smoking, options: _smokingOpts,
            staticValue: _data.smoking,
            onChanged: (v) => setState(() => _draft = _draft.copyWith(smoking: v))),
          _DropdownRow(label: 'Alcohol', emoji: '🥛', editing: _editing,
            value: _draft.alcohol, options: _alcoholOpts,
            staticValue: _data.alcohol,
            onChanged: (v) => setState(() => _draft = _draft.copyWith(alcohol: v))),
          _DropdownRow(label: 'Exercise', emoji: '🏋️', editing: _editing,
            value: _draft.exercise, options: _exerciseOpts,
            staticValue: _data.exercise,
            onChanged: (v) => setState(() => _draft = _draft.copyWith(exercise: v))),
          _EditableRow(label: 'Sleep', emoji: '😴', editing: _editing,
            controller: _sleepCtrl, staticValue: _data.sleep),
        ]),
      ),
    ]);
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String emoji, label, value;
  const _StatCard({required this.emoji, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: DesignTokens.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DesignTokens.border),
          boxShadow: [BoxShadow(
            color: DesignTokens.primary.withValues(alpha: 0.05),
            blurRadius: 8, offset: const Offset(0, 3),
          )],
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(
            fontWeight: FontWeight.w900, fontSize: 16,
            color: DesignTokens.textStrong, letterSpacing: -0.5,
          )),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(
            color: DesignTokens.textMuted, fontSize: 10, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String emoji, title;
  final bool editing;
  const _SectionHeader({required this.emoji, required this.title, this.editing = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w800,
          color: DesignTokens.textStrong, letterSpacing: -0.3,
        )),
        if (editing) ...[
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
    );
  }
}

/// Switches between a read-only row and a TextFormField when [editing].
class _EditableRow extends StatelessWidget {
  final String label, emoji, staticValue;
  final bool editing;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _EditableRow({
    required this.label,
    required this.emoji,
    required this.staticValue,
    required this.editing,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    if (!editing) {
      return _InfoRow(label: label, value: staticValue, emoji: emoji);
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DesignTokens.primary.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: validator,
              style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: DesignTokens.textStrong,
              ),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(
                  fontSize: 12, color: DesignTokens.textMuted, fontWeight: FontWeight.w500),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const Icon(Icons.edit_rounded, size: 14, color: DesignTokens.primary),
        ],
      ),
    );
  }
}

/// Switches between a read-only row and a DropdownButtonFormField when [editing].
class _DropdownRow extends StatelessWidget {
  final String label, emoji, staticValue, value;
  final bool editing;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _DropdownRow({
    required this.label,
    required this.emoji,
    required this.staticValue,
    required this.editing,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!editing) {
      return _InfoRow(label: label, value: staticValue, emoji: emoji);
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DesignTokens.primary.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: options.contains(value) ? value : options.first,
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: DesignTokens.textStrong)))).toList(),
              onChanged: onChanged,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(
                  fontSize: 12, color: DesignTokens.textMuted, fontWeight: FontWeight.w500),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: DesignTokens.primary, size: 20),
              dropdownColor: DesignTokens.surface,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Read-only info row (view mode).
class _InfoRow extends StatelessWidget {
  final String label, value, emoji;
  const _InfoRow({required this.label, required this.value, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DesignTokens.border),
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(
          color: DesignTokens.textMuted, fontSize: 13, fontWeight: FontWeight.w500))),
        Flexible(child: Text(value, style: const TextStyle(
          fontWeight: FontWeight.w700, fontSize: 13, color: DesignTokens.textStrong),
          textAlign: TextAlign.end, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}

/// Sticky save bar that floats above the bottom of the screen.
class _SaveBar extends StatelessWidget {
  final bool saving;
  final VoidCallback onSave;
  const _SaveBar({required this.saving, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16,
          12 + MediaQuery.of(context).padding.bottom),
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
                    Text('Save Changes', style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
                  ]),
          ),
        ),
      ),
    );
  }
}
