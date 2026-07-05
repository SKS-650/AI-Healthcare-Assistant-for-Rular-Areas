import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../routing/route_names.dart';
import '../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/user.dart';
import '../controllers/authentication_state.dart';
import '../providers/authentication_provider.dart';
import '../widgets/common/auth_background.dart';
import '../widgets/common/auth_text_field.dart';
import '../widgets/common/loading_overlay.dart';
import '../widgets/common/primary_auth_button.dart';

class ProfileCompletionPage extends ConsumerStatefulWidget {
  const ProfileCompletionPage({super.key});

  @override
  ConsumerState<ProfileCompletionPage> createState() =>
      _ProfileCompletionPageState();
}

class _ProfileCompletionPageState
    extends ConsumerState<ProfileCompletionPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String? _selectedGender;
  String? _selectedLanguage;
  int? _selectedAge;

  UserEntity? _user;

  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  final _genders = ['Male', 'Female', 'Non-binary', 'Prefer not to say'];
  final _languages = [
    'English', 'Hindi', 'Bengali', 'Telugu', 'Marathi',
    'Tamil', 'Gujarati', 'Kannada', 'Punjabi', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is UserEntity && _user == null) {
      _user = args;
      _nameCtrl.text = args.name ?? '';
      _phoneCtrl.text = args.phone ?? '';
      // Normalize gender value to match the display list (title-case)
      _selectedGender = _normalizeGender(args.gender);
      // Normalize language: map locale codes ('en') to display names ('English')
      _selectedLanguage = _normalizeLanguage(args.language);
      _selectedAge = args.age;
    }
    // Fallback: check controller state
    _user ??= ref.read(authControllerProvider).user;
  }

  /// Maps a raw gender string (any case) to the display value in [_genders],
  /// or returns null if it doesn't match any entry.
  String? _normalizeGender(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final lower = raw.toLowerCase();
    for (final g in _genders) {
      if (g.toLowerCase() == lower) return g;
    }
    return null;
  }

  /// Maps a language locale code or full name to the display value in
  /// [_languages], or returns null if nothing matches.
  String? _normalizeLanguage(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    // Check direct match first (already a display name)
    if (_languages.contains(raw)) return raw;
    // Map common locale codes to display names
    const codeToName = {
      'en': 'English', 'hi': 'Hindi', 'bn': 'Bengali', 'te': 'Telugu',
      'mr': 'Marathi', 'ta': 'Tamil', 'gu': 'Gujarati', 'kn': 'Kannada',
      'pa': 'Punjabi',
    };
    final mapped = codeToName[raw.toLowerCase()];
    if (mapped != null && _languages.contains(mapped)) return mapped;
    return null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final userId = _user?.id;
    if (userId == null) return;

    await ref.read(authControllerProvider.notifier).completeProfile(
          userId: userId,
          name: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
          gender: _selectedGender,
          age: _selectedAge,
          language: _selectedLanguage,
        );
  }

  int get _completionPercent {
    int filled = 0;
    if (_nameCtrl.text.isNotEmpty) filled++;
    if (_phoneCtrl.text.isNotEmpty) filled++;
    if (_selectedGender != null) filled++;
    if (_selectedAge != null) filled++;
    if (_selectedLanguage != null) filled++;
    return ((filled / 5) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    ref.listen<AuthenticationState>(authControllerProvider, (prev, next) {
      if (next.isSuccess &&
          next.user != null &&
          next.user!.isProfileComplete) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteNames.home,
          (r) => false,
        );
      }
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Profile update failed'),
            backgroundColor: DesignTokens.danger,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        ref.read(authControllerProvider.notifier).clearError();
      }
    });

    return LoadingOverlay(
      isLoading: state.isLoading,
      child: Scaffold(
        body: AuthBackground(
          child: SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // ── Header ────────────────────────────────────────
                        _buildHeader(),

                        const SizedBox(height: 24),

                        // ── Progress ──────────────────────────────────────
                        _CompletionProgress(percent: _completionPercent),

                        const SizedBox(height: 32),

                        // ── Full Name ─────────────────────────────────────
                        _SectionLabel(label: 'Full Name *'),
                        const SizedBox(height: 8),
                        AuthTextField(
                          controller: _nameCtrl,
                          label: 'Full Name',
                          hint: 'John Doe',
                          prefixIcon: Icons.person_outline_rounded,
                          keyboardType: TextInputType.name,
                          onChanged: (_) => setState(() {}),
                        ),

                        const SizedBox(height: 16),

                        // ── Phone ─────────────────────────────────────────
                        _SectionLabel(label: 'Phone Number'),
                        const SizedBox(height: 8),
                        AuthTextField(
                          controller: _phoneCtrl,
                          label: 'Phone Number',
                          hint: '+91 9876543210',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          onChanged: (_) => setState(() {}),
                        ),

                        const SizedBox(height: 20),

                        // ── Gender ────────────────────────────────────────
                        _SectionLabel(label: 'Gender'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _genders.map((g) {
                            final selected = _selectedGender == g;
                            return GestureDetector(
                              onTap: () {
                                setState(() => _selectedGender = g);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? DesignTokens.primaryContainer
                                      : DesignTokens.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? DesignTokens.primary
                                        : DesignTokens.border,
                                    width: selected ? 1.5 : 1,
                                  ),
                                ),
                                child: Text(
                                  g,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: selected
                                        ? DesignTokens.primaryDark
                                        : DesignTokens.textMuted,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),

                        // ── Age ───────────────────────────────────────────
                        _SectionLabel(label: 'Age'),
                        const SizedBox(height: 10),
                        _AgeSelector(
                          selected: _selectedAge,
                          onSelected: (a) {
                            setState(() => _selectedAge = a);
                          },
                        ),

                        const SizedBox(height: 20),

                        // ── Language ──────────────────────────────────────
                        _SectionLabel(label: 'Preferred Language'),
                        const SizedBox(height: 10),
                        _LanguageDropdown(
                          languages: _languages,
                          selected: _selectedLanguage,
                          onSelected: (l) {
                            setState(() => _selectedLanguage = l);
                          },
                        ),

                        const SizedBox(height: 36),

                        // ── Submit ────────────────────────────────────────
                        PrimaryAuthButton(
                          label: 'Complete Profile',
                          onPressed: state.isLoading ? null : _submit,
                          isLoading: state.isLoading,
                          icon: Icons.check_circle_rounded,
                        ),

                        const SizedBox(height: 12),

                        // ── Skip ──────────────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () =>
                                Navigator.of(context).pushNamedAndRemoveUntil(
                              RouteNames.home,
                              (r) => false,
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: DesignTokens.textMuted,
                            ),
                            child: const Text(
                              'Skip for now',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [DesignTokens.primaryDark, DesignTokens.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: DesignTokens.primary.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Center(
            child: Text('🧑‍⚕️', style: TextStyle(fontSize: 26)),
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Complete Profile',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: DesignTokens.textStrong,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Help us personalise your experience',
                style: TextStyle(
                  fontSize: 13,
                  color: DesignTokens.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: DesignTokens.textStrong,
        letterSpacing: 0.1,
      ),
    );
  }
}

class _CompletionProgress extends StatelessWidget {
  final int percent;
  const _CompletionProgress({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DesignTokens.primaryContainer, DesignTokens.primaryMuted],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile $percent% complete',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: DesignTokens.primaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent / 100,
                    minHeight: 6,
                    backgroundColor:
                        DesignTokens.primary.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation(
                        DesignTokens.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '$percent%',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: DesignTokens.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AgeSelector extends StatelessWidget {
  final int? selected;
  final ValueChanged<int> onSelected;
  const _AgeSelector({required this.selected, required this.onSelected});

  static const _ranges = [
    (label: 'Under 18', value: 16),
    (label: '18–25', value: 21),
    (label: '26–35', value: 30),
    (label: '36–50', value: 42),
    (label: '51–65', value: 57),
    (label: '65+', value: 70),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _ranges.map((r) {
        final isSelected = selected == r.value;
        return GestureDetector(
          onTap: () => onSelected(r.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? DesignTokens.primaryContainer
                  : DesignTokens.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isSelected ? DesignTokens.primary : DesignTokens.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              r.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? DesignTokens.primaryDark
                    : DesignTokens.textMuted,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _LanguageDropdown extends StatelessWidget {
  final List<String> languages;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _LanguageDropdown({
    required this.languages,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          hint: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Select language',
              style: TextStyle(
                color: DesignTokens.textSubtle,
                fontSize: 15,
              ),
            ),
          ),
          isExpanded: true,
          icon: const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.keyboard_arrow_down_rounded,
                color: DesignTokens.textMuted),
          ),
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          items: languages
              .map((l) => DropdownMenuItem(
                    value: l,
                    child: Text(
                      l,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: DesignTokens.textStrong,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: onSelected,
        ),
      ),
    );
  }
}
