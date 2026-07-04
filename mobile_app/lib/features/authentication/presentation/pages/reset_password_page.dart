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
import '../widgets/dialogs/success_dialog.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(authControllerProvider.notifier)
        .resetPassword(_passwordCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    ref.listen<AuthenticationState>(authControllerProvider, (prev, next) {
      // Reset succeeded: flow is success and resetToken is now null
      // (it was non-null before the call, set during OTP verification)
      if (next.isSuccess && next.resetToken == null) {
        SuccessDialog.show(
          context,
          title: 'Password Reset!',
          message:
              'Your password has been reset successfully. Sign in with your new password.',
          buttonLabel: 'Sign In',
          onConfirm: () {
            ref.read(authControllerProvider.notifier).reset();
            Navigator.of(context).pushNamedAndRemoveUntil(
              RouteNames.login,
              (r) => false,
            );
          },
        );
      }
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Reset failed'),
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
                        const SizedBox(height: 16),
                        _BackButton(),
                        const SizedBox(height: 40),

                        // ── Illustration ────────────────────────────────────
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  DesignTokens.successContainer,
                                  DesignTokens.greenContainer,
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: DesignTokens.success
                                      .withValues(alpha: 0.2),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Center(
                              child:
                                  Text('🔒', style: TextStyle(fontSize: 46)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── Header ────────────────────────────────────────
                        const Text(
                          'Create New Password',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: DesignTokens.textStrong,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Your new password must be at least 8 characters, with one uppercase letter and one number.',
                          style: TextStyle(
                            fontSize: 15,
                            color: DesignTokens.textMuted,
                            height: 1.55,
                          ),
                        ),

                        const SizedBox(height: 36),

                        // ── New password ──────────────────────────────────
                        AuthTextField(
                          controller: _passwordCtrl,
                          focusNode: _passwordFocus,
                          label: 'New Password',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () =>
                              FocusScope.of(context).requestFocus(_confirmFocus),
                          onChanged: (_) => setState(() {}),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password is required';
                            if (v.length < 8) return 'At least 8 characters';
                            if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Add an uppercase letter';
                            if (!RegExp(r'[a-z]').hasMatch(v)) return 'Add a lowercase letter';
                            if (!RegExp(r'[0-9]').hasMatch(v)) return 'Add a digit';
                            if (!RegExp(r'[!@#\$%^&*()\-_,.?":{}|<>]').hasMatch(v)) {
                              return 'Add a special character';
                            }
                            return null;
                          },
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

                        const SizedBox(height: 16),

                        // ── Confirm password ──────────────────────────────
                        AuthTextField(
                          controller: _confirmCtrl,
                          focusNode: _confirmFocus,
                          label: 'Confirm Password',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: _submit,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please confirm your password';
                            if (v != _passwordCtrl.text) return 'Passwords do not match';
                            return null;
                          },
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

                        const SizedBox(height: 32),

                        // ── Password requirements ─────────────────────────
                        _PasswordRequirements(password: _passwordCtrl.text),

                        const SizedBox(height: 32),

                        PrimaryAuthButton(
                          label: 'Reset Password',
                          onPressed: state.isLoading ? null : _submit,
                          isLoading: state.isLoading,
                          icon: Icons.lock_reset_rounded,
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
}

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

class _PasswordRequirements extends StatelessWidget {
  final String password;
  const _PasswordRequirements({required this.password});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DesignTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Password Requirements',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: DesignTokens.textStrong,
            ),
          ),
          const SizedBox(height: 10),
          _Requirement(
            label: 'At least 8 characters',
            met: password.length >= 8,
          ),
          _Requirement(
            label: 'One uppercase letter',
            met: RegExp(r'[A-Z]').hasMatch(password),
          ),
          _Requirement(
            label: 'One number',
            met: RegExp(r'[0-9]').hasMatch(password),
          ),
        ],
      ),
    );
  }
}

class _Requirement extends StatelessWidget {
  final String label;
  final bool met;
  const _Requirement({required this.label, required this.met});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: met ? DesignTokens.success : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: met ? DesignTokens.success : DesignTokens.border,
                width: 1.5,
              ),
            ),
            child: met
                ? const Icon(Icons.check_rounded,
                    size: 11, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: met ? DesignTokens.success : DesignTokens.textMuted,
              fontWeight: met ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
