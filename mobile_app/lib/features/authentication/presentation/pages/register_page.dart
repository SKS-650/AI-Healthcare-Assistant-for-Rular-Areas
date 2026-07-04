import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../routing/route_names.dart';
import '../../../../shared/design_system/design_tokens.dart';
import '../controllers/authentication_state.dart';
import '../providers/authentication_provider.dart';
import '../widgets/common/auth_background.dart';
import '../widgets/common/auth_text_field.dart';
import '../widgets/common/loading_overlay.dart';
import '../widgets/common/primary_auth_button.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;

  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

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
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  double get _passwordStrength {
    final p = _passwordCtrl.text;
    if (p.isEmpty) return 0;
    double s = 0;
    if (p.length >= 8) s += 0.25;
    if (p.length >= 12) s += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(p)) s += 0.25;
    if (RegExp(r'[0-9!@#\$%^&*]').hasMatch(p)) s += 0.25;
    return s;
  }

  Color get _strengthColor {
    final s = _passwordStrength;
    if (s <= 0.25) return DesignTokens.danger;
    if (s <= 0.5) return DesignTokens.warning;
    if (s <= 0.75) return DesignTokens.blue;
    return DesignTokens.success;
  }

  String get _strengthLabel {
    final s = _passwordStrength;
    if (s <= 0.25) return 'Weak';
    if (s <= 0.5) return 'Fair';
    if (s <= 0.75) return 'Good';
    return 'Strong';
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please agree to the Terms & Privacy Policy'),
          backgroundColor: DesignTokens.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    await ref.read(authControllerProvider.notifier).register(
          _nameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    ref.listen<AuthenticationState>(authControllerProvider, (prev, next) {
      if (next.isSuccess && next.user != null) {
        Navigator.of(context).pushReplacementNamed(
          RouteNames.profileCompletion,
          arguments: next.user,
        );
      }
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Registration failed'),
            backgroundColor: DesignTokens.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        const SizedBox(height: 16),
                        _BackButton(),
                        const SizedBox(height: 32),

                        // ── Header ────────────────────────────────────────
                        _buildHeader(),
                        const SizedBox(height: 32),

                        // ── Full Name ─────────────────────────────────────
                        _FieldLabel(label: 'Full Name'),
                        const SizedBox(height: 8),
                        AuthTextField(
                          controller: _nameCtrl,
                          focusNode: _nameFocus,
                          label: 'Full Name',
                          hint: 'John Doe',
                          prefixIcon: Icons.person_outline_rounded,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () =>
                              FocusScope.of(context).requestFocus(_emailFocus),
                        ),
                        const SizedBox(height: 16),

                        // ── Email ─────────────────────────────────────────
                        _FieldLabel(label: 'Email Address'),
                        const SizedBox(height: 8),
                        AuthTextField(
                          controller: _emailCtrl,
                          focusNode: _emailFocus,
                          label: 'Email Address',
                          hint: 'you@example.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () =>
                              FocusScope.of(context).requestFocus(_passwordFocus),
                        ),
                        const SizedBox(height: 16),

                        // ── Password ──────────────────────────────────────
                        _FieldLabel(label: 'Password'),
                        const SizedBox(height: 8),
                        AuthTextField(
                          controller: _passwordCtrl,
                          focusNode: _passwordFocus,
                          label: 'Password',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () =>
                              FocusScope.of(context).requestFocus(_confirmFocus),
                          onChanged: (_) => setState(() {}),
                          suffix: IconButton(
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                              color: DesignTokens.textMuted,
                            ),
                          ),
                        ),

                        // Password strength bar
                        if (_passwordCtrl.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _PasswordStrengthBar(
                            strength: _passwordStrength,
                            color: _strengthColor,
                            label: _strengthLabel,
                          ),
                        ],

                        const SizedBox(height: 16),

                        // ── Confirm Password ──────────────────────────────
                        _FieldLabel(label: 'Confirm Password'),
                        const SizedBox(height: 8),
                        AuthTextField(
                          controller: _confirmCtrl,
                          focusNode: _confirmFocus,
                          label: 'Confirm Password',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: _submit,
                          suffix: IconButton(
                            onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                              color: DesignTokens.textMuted,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Terms checkbox ────────────────────────────────
                        _TermsCheckbox(
                          value: _agreedToTerms,
                          onChanged: (v) =>
                              setState(() => _agreedToTerms = v ?? false),
                        ),

                        const SizedBox(height: 28),

                        // ── Register button ───────────────────────────────
                        PrimaryAuthButton(
                          label: 'Create Account',
                          onPressed: state.isLoading ? null : _submit,
                          isLoading: state.isLoading,
                          icon: Icons.person_add_rounded,
                        ),

                        const SizedBox(height: 28),

                        // ── Login link ────────────────────────────────────
                        Center(
                          child: Text.rich(
                            TextSpan(
                              text: 'Already have an account? ',
                              style: const TextStyle(
                                color: DesignTokens.textMuted,
                                fontSize: 14,
                              ),
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () =>
                                        Navigator.of(context).pushReplacementNamed(
                                            RouteNames.login),
                                    child: const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        color: DesignTokens.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            child: Text('✨', style: TextStyle(fontSize: 26)),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: DesignTokens.textStrong,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Join thousands getting smarter healthcare guidance',
          style: TextStyle(
            fontSize: 15,
            color: DesignTokens.textMuted,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// ── Helper sub-widgets ─────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: DesignTokens.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DesignTokens.border),
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          size: 20,
          color: DesignTokens.textStrong,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: DesignTokens.textStrong,
        letterSpacing: 0.1,
      ),
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  final double strength;
  final Color color;
  final String label;
  const _PasswordStrengthBar({
    required this.strength,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: strength,
              minHeight: 5,
              backgroundColor: DesignTokens.border,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  const _TermsCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => onChanged(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: value ? DesignTokens.primary : Colors.transparent,
              border: Border.all(
                color: value ? DesignTokens.primary : DesignTokens.border,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: value
                ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: const Text.rich(
              TextSpan(
                text: 'I agree to the ',
                style: TextStyle(
                  fontSize: 13,
                  color: DesignTokens.textMuted,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: DesignTokens.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: DesignTokens.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
