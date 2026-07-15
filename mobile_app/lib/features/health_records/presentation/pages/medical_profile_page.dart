import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/medical_profile.dart';
import '../providers/health_records_provider.dart';

class MedicalProfilePage extends ConsumerStatefulWidget {
  const MedicalProfilePage({super.key});

  @override
  ConsumerState<MedicalProfilePage> createState() => _MedicalProfilePageState();
}

class _MedicalProfilePageState extends ConsumerState<MedicalProfilePage> {
  // Form controllers
  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;

  String? _bloodGroup;
  String? _smokingStatus;
  String? _alcoholStatus;
  String? _activityLevel;

  // Tag-based lists
  List<String> _allergies    = [];
  List<String> _chronicDiseases = [];
  List<String> _medications  = [];
  List<String> _familyHistory = [];

  bool _editing = false;
  bool _saving  = false;

  // _bloodGroups is used by _VitalsCard via _bloodGroupList constant defined there.
  // Kept here for reference; _VitalsCard uses its own copy.
  // ignore: unused_field
  static const _bloodGroups = ['A+', 'A−', 'B+', 'B−', 'O+', 'O−', 'AB+', 'AB−'];
  static const _smokingOpts = [
    ('never',   '🚭 Never'),
    ('former',  '🔴 Former'),
    ('current', '🚬 Current'),
  ];
  static const _alcoholOpts = [
    ('never',      '🚫 Never'),
    ('occasional', '🍷 Occasional'),
    ('regular',    '🍺 Regular'),
  ];
  static const _activityOpts = [
    ('sedentary', '🪑 Sedentary'),
    ('moderate',  '🚶 Moderate'),
    ('active',    '🏃 Active'),
  ];

  @override
  void initState() {
    super.initState();
    final p = ref.read(healthRecordsControllerProvider).medicalProfile;
    _heightCtrl = TextEditingController(
        text: p?.heightCm?.toStringAsFixed(0) ?? '');
    _weightCtrl = TextEditingController(
        text: p?.weightKg?.toStringAsFixed(1) ?? '');
    _bloodGroup    = p?.bloodGroup;
    _smokingStatus = p?.smokingStatus;
    _alcoholStatus = p?.alcoholStatus;
    _activityLevel = p?.activityLevel;
    _allergies       = List.from(p?.allergies ?? []);
    _chronicDiseases = List.from(p?.chronicDiseases ?? []);
    _medications     = List.from(p?.currentMedications ?? []);
    _familyHistory   = List.from(p?.familyHistory ?? []);
  }

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  // ── BMI computed from current input ────────────────────────────────────

  double? get _computedBmi {
    final h = double.tryParse(_heightCtrl.text);
    final w = double.tryParse(_weightCtrl.text);
    if (h == null || h == 0 || w == null) return null;
    return w / ((h / 100) * (h / 100));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(healthRecordsControllerProvider);
    final profile = state.medicalProfile;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Row(children: [
          Text('🧬', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Text('Medical Profile',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: DesignTokens.textStrong)),
        ]),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: DesignTokens.primary),
              tooltip: 'Edit profile',
              onPressed: () => setState(() => _editing = true),
            )
          else
            TextButton(
              onPressed: () => setState(() => _editing = false),
              child: const Text('Cancel',
                  style: TextStyle(color: DesignTokens.textMuted)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero vitals card
            _VitalsCard(
              profile: profile,
              editing: _editing,
              heightCtrl: _heightCtrl,
              weightCtrl: _weightCtrl,
              bloodGroup: _bloodGroup,
              computedBmi: _computedBmi,
              onBloodGroupChanged: (v) => setState(() => _bloodGroup = v),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 16),

            // Lifestyle
            _SectionCard(
              emoji: '🌿',
              title: 'Lifestyle',
              child: Column(
                children: [
                  _SelectRow(
                    label: 'Smoking',
                    icon: '🚬',
                    value: _smokingStatus,
                    options: _smokingOpts,
                    editing: _editing,
                    onChanged: (v) => setState(() => _smokingStatus = v),
                  ),
                  const Divider(height: 1),
                  _SelectRow(
                    label: 'Alcohol',
                    icon: '🍷',
                    value: _alcoholStatus,
                    options: _alcoholOpts,
                    editing: _editing,
                    onChanged: (v) => setState(() => _alcoholStatus = v),
                  ),
                  const Divider(height: 1),
                  _SelectRow(
                    label: 'Activity',
                    icon: '🏃',
                    value: _activityLevel,
                    options: _activityOpts,
                    editing: _editing,
                    onChanged: (v) => setState(() => _activityLevel = v),
                  ),
                ],
              ),
            ).animate(delay: 80.ms).fadeIn(duration: 350.ms),

            const SizedBox(height: 16),

            // Allergies
            _TagSection(
              emoji: '⚠️',
              title: 'Allergies',
              color: DesignTokens.danger,
              tags: _allergies,
              editing: _editing,
              addLabel: 'Add allergy',
              onAdd: (v) => setState(() => _allergies.add(v)),
              onRemove: (v) => setState(() => _allergies.remove(v)),
            ).animate(delay: 120.ms).fadeIn(duration: 350.ms),

            const SizedBox(height: 12),

            // Chronic diseases
            _TagSection(
              emoji: '💊',
              title: 'Chronic Conditions',
              color: DesignTokens.orange,
              tags: _chronicDiseases,
              editing: _editing,
              addLabel: 'Add condition',
              onAdd: (v) => setState(() => _chronicDiseases.add(v)),
              onRemove: (v) => setState(() => _chronicDiseases.remove(v)),
            ).animate(delay: 160.ms).fadeIn(duration: 350.ms),

            const SizedBox(height: 12),

            // Medications
            _TagSection(
              emoji: '💉',
              title: 'Current Medications',
              color: DesignTokens.primary,
              tags: _medications,
              editing: _editing,
              addLabel: 'Add medication',
              onAdd: (v) => setState(() => _medications.add(v)),
              onRemove: (v) => setState(() => _medications.remove(v)),
            ).animate(delay: 200.ms).fadeIn(duration: 350.ms),

            const SizedBox(height: 12),

            // Family history
            _TagSection(
              emoji: '👨‍👩‍👧',
              title: 'Family Medical History',
              color: DesignTokens.pink,
              tags: _familyHistory,
              editing: _editing,
              addLabel: 'Add family history',
              onAdd: (v) => setState(() => _familyHistory.add(v)),
              onRemove: (v) => setState(() => _familyHistory.remove(v)),
            ).animate(delay: 240.ms).fadeIn(duration: 350.ms),
          ],
        ),
      ),

      // Save FAB
      floatingActionButton: _editing
          ? FloatingActionButton.extended(
              onPressed: _saving ? null : _save,
              backgroundColor: DesignTokens.primary,
              foregroundColor: Colors.white,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save_rounded),
              label: Text(_saving ? 'Saving…' : 'Save Profile',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            )
          : null,
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final existing =
        ref.read(healthRecordsControllerProvider).medicalProfile;

    final updated = MedicalProfile(
      id:                 existing?.id ?? '',
      userId:             existing?.userId ?? 'local',
      bloodGroup:         _bloodGroup,
      heightCm:           double.tryParse(_heightCtrl.text),
      weightKg:           double.tryParse(_weightCtrl.text),
      bmi:                _computedBmi,
      smokingStatus:      _smokingStatus,
      alcoholStatus:      _alcoholStatus,
      activityLevel:      _activityLevel,
      allergies:          List.unmodifiable(_allergies),
      chronicDiseases:    List.unmodifiable(_chronicDiseases),
      currentMedications: List.unmodifiable(_medications),
      familyHistory:      List.unmodifiable(_familyHistory),
      vaccinationHistory: existing?.vaccinationHistory ?? const [],
      createdAt:          existing?.createdAt ?? DateTime.now(),
      updatedAt:          DateTime.now(),
    );

    final ok = await ref
        .read(healthRecordsControllerProvider.notifier)
        .saveProfile(updated);

    if (mounted) {
      setState(() {
        _saving  = false;
        _editing = !ok;
      });
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Profile saved successfully'),
          backgroundColor: DesignTokens.green,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }
}

// ─── Vitals card ──────────────────────────────────────────────────────────────

class _VitalsCard extends StatelessWidget {
  final MedicalProfile? profile;
  final bool editing;
  final TextEditingController heightCtrl;
  final TextEditingController weightCtrl;
  final String? bloodGroup;
  final double? computedBmi;
  final void Function(String?) onBloodGroupChanged;

  const _VitalsCard({
    required this.profile,
    required this.editing,
    required this.heightCtrl,
    required this.weightCtrl,
    required this.bloodGroup,
    required this.computedBmi,
    required this.onBloodGroupChanged,
  });

  static const _bloodGroupList = [
    'A+', 'A−', 'B+', 'B−', 'O+', 'O−', 'AB+', 'AB−'
  ];

  @override
  Widget build(BuildContext context) {
    final bmi = computedBmi ?? profile?.bmi;
    final bmiLabel = _bmiLabel(bmi);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF926EFF), Color(0xFF4F94FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        boxShadow: [
          BoxShadow(
              color: DesignTokens.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Text('🧬', style: TextStyle(fontSize: 24)),
            SizedBox(width: 10),
            Text('Health Vitals',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 20),
          // Editable / view vitals
          if (editing)
            _EditVitals(
              heightCtrl: heightCtrl,
              weightCtrl: weightCtrl,
              bloodGroup: bloodGroup,
              onBloodGroupChanged: onBloodGroupChanged,
              bloodGroups: _bloodGroupList,
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _VitalCell('🩸', 'Blood Group',
                    bloodGroup ?? profile?.bloodGroup ?? '--'),
                _VitalCell('📏', 'Height',
                    profile?.heightCm != null
                        ? '${profile!.heightCm!.toStringAsFixed(0)} cm'
                        : '--'),
                _VitalCell('⚖️', 'Weight',
                    profile?.weightKg != null
                        ? '${profile!.weightKg!.toStringAsFixed(1)} kg'
                        : '--'),
                _VitalCell(
                    '📊',
                    'BMI',
                    bmi != null
                        ? '${bmi.toStringAsFixed(1)} ($bmiLabel)'
                        : '--'),
              ],
            ),
        ],
      ),
    );
  }

  String _bmiLabel(double? bmi) {
    if (bmi == null) return '';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }
}

class _VitalCell extends StatelessWidget {
  final String emoji, label, value;
  const _VitalCell(this.emoji, this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 10)),
        ],
      );
}

class _EditVitals extends StatelessWidget {
  final TextEditingController heightCtrl;
  final TextEditingController weightCtrl;
  final String? bloodGroup;
  final void Function(String?) onBloodGroupChanged;
  final List<String> bloodGroups;

  const _EditVitals({
    required this.heightCtrl,
    required this.weightCtrl,
    required this.bloodGroup,
    required this.onBloodGroupChanged,
    required this.bloodGroups,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Expanded(
            child: _WhiteField(
                controller: heightCtrl, label: 'Height (cm)'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _WhiteField(
                controller: weightCtrl, label: 'Weight (kg)'),
          ),
        ]),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: bloodGroup,
          hint: const Text('Blood Group',
              style: TextStyle(color: Colors.white70)),
          dropdownColor: const Color(0xFF6B47E8),
          style: const TextStyle(color: Colors.white),
          iconEnabledColor: Colors.white70,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.15),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
          ),
          onChanged: onBloodGroupChanged,
          items: bloodGroups
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
        ),
      ],
    );
  }
}

class _WhiteField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const _WhiteField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.15),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
        ),
      );
}

// ─── Section card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String emoji, title;
  final Widget child;
  const _SectionCard(
      {required this.emoji, required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: DesignTokens.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DesignTokens.border),
          boxShadow: [
            BoxShadow(
                color: DesignTokens.primary.withValues(alpha: 0.04),
                blurRadius: 8)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: DesignTokens.textStrong)),
              ]),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            child,
          ],
        ),
      );
}

// ─── Select row ───────────────────────────────────────────────────────────────

class _SelectRow extends StatelessWidget {
  final String label, icon;
  final String? value;
  final List<(String, String)> options;
  final bool editing;
  final void Function(String?) onChanged;

  const _SelectRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.editing,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final display =
        options.firstWhere((o) => o.$1 == value, orElse: () => ('', '—')).$2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
                fontSize: 14, color: DesignTokens.textStrong)),
        const Spacer(),
        if (!editing)
          Text(display,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.textMuted))
        else
          DropdownButton<String>(
            value: value,
            hint: const Text('Select',
                style: TextStyle(fontSize: 13)),
            underline: const SizedBox.shrink(),
            onChanged: onChanged,
            items: options
                .map((o) => DropdownMenuItem(
                    value: o.$1, child: Text(o.$2, style: const TextStyle(fontSize: 13))))
                .toList(),
          ),
      ]),
    );
  }
}

// ─── Tag section ──────────────────────────────────────────────────────────────

class _TagSection extends StatelessWidget {
  final String emoji, title, addLabel;
  final Color color;
  final List<String> tags;
  final bool editing;
  final void Function(String) onAdd;
  final void Function(String) onRemove;

  const _TagSection({
    required this.emoji,
    required this.title,
    required this.color,
    required this.tags,
    required this.editing,
    required this.addLabel,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.textStrong)),
            const Spacer(),
            if (editing)
              GestureDetector(
                onTap: () => _showAddDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: color, size: 14),
                      const SizedBox(width: 4),
                      Text('Add',
                          style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
          ]),
          if (tags.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'None recorded',
                style: TextStyle(
                    fontSize: 12, color: DesignTokens.textSubtle),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: tags
                    .map((tag) => _Tag(
                          tag: tag,
                          color: color,
                          editing: editing,
                          onRemove: () => onRemove(tag),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dctx) => AlertDialog(
        title: Text('$emoji $addLabel'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(hintText: addLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: color, foregroundColor: Colors.white),
            onPressed: () {
              final v = ctrl.text.trim();
              if (v.isNotEmpty) onAdd(v);
              Navigator.pop(dctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String tag;
  final Color color;
  final bool editing;
  final VoidCallback onRemove;
  const _Tag(
      {required this.tag,
      required this.color,
      required this.editing,
      required this.onRemove});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tag,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color)),
            if (editing) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onRemove,
                child: Icon(Icons.close_rounded, size: 14, color: color),
              ),
            ],
          ],
        ),
      );
}
