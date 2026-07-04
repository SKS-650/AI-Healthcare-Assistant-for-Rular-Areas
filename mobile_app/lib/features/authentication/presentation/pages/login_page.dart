import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../routing/route_names.dart';
import '../../../../shared/design_system/design_tokens.dart';
import '../controllers/authentication_state.dart';
import '../providers/authentication_provider.dart';
import '../widgets/common/auth_background.dart';
import '../widgets/common/auth_text_field.dart';
import '../widgets/common/divider_with_text.dart';
import '../widgets/common/loading_overlay.dart';
import '../widgets/common/primary_auth_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _rememberMe = false;

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
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authControllerProvider.notifier).login(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    // React to success → navigate to home
    ref.listen<AuthenticationState>(authControllerProvider, (prev, next) {
      if (next.isSuccess && next.user != null) {
        if (next.user!.isProfileComplete) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            RouteNames.home,
            (r) => false,
          );
        } else {
          Navigator.of(context).pushReplacementNamed(
            RouteNames.profileCompletion,
            arguments: next.user,
          );
        }
      }
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Login failed'),
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

                        // ── Back button ──────────────────────────────────
                        _BackButton(),

                        const SizedBox(height: 32),

                        // ── Header ───────────────────────────────────────
                        _buildHeader(),

                        const SizedBox(height: 36),

                        // ── Email ────────────────────────────────────────
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
                          onChanged: (_) =>
                              ref.read(authControllerProvider.notifier).clearError(),
                        ),

                        const SizedBox(height: 16),

                        // ── Password ─────────────────────────────────────
                        AuthTextField(
                          controller: _passwordCtrl,
                          focusNode: _passwordFocus,
                          label: 'Password',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: _submit,
                          suffix: IconButton(
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                              color: DesignTokens.textMuted,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Remember me + Forgot ──────────────────────────
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _rememberMe = !_rememberMe),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: _rememberMe
                                          ? DesignTokens.primary
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: _rememberMe
                                            ? DesignTokens.primary
                                            : DesignTokens.border,
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: _rememberMe
                                        ? const Icon(Icons.check_rounded,
                                            size: 13, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Remember me',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: DesignTokens.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(RouteNames.forgotPassword),
                              style: TextButton.styleFrom(
                                foregroundColor: DesignTokens.primary,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // ── Sign in button ────────────────────────────────
                        PrimaryAuthButton(
                          label: 'Sign In',
                          onPressed: state.isLoading ? null : _submit,
                          isLoading: state.isLoading,
                          icon: Icons.login_rounded,
                        ),

                        const SizedBox(height: 24),

                        // ── Divider ───────────────────────────────────────
                        const DividerWithText(text: 'or continue with'),

                        const SizedBox(height: 20),

                        // ── Social login row ──────────────────────────────
                        _SocialLoginRow(),

                        const SizedBox(height: 32),

                        // ── Register link ─────────────────────────────────
                        Center(
                          child: Text.rich(
                            TextSpan(
                              text: "Don't have an account? ",
                              style: const TextStyle(
                                color: DesignTokens.textMuted,
                                fontSize: 14,
                              ),
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () => Navigator.of(context)
                                        .pushReplacementNamed(RouteNames.register),
                                    child: const Text(
                                      'Sign Up',
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

                        const SizedBox(height: 24),

                        // ── Demo hint ─────────────────────────────────────
                        _DemoHint(),

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
            child: Text('👋', style: TextStyle(fontSize: 26)),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Welcome back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: DesignTokens.textStrong,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sign in to continue your health journey',
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

// ── Back button ──────────────────────────────────────────────────────────────

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

// ── Social login row ──────────────────────────────────────────────────────────

class _SocialLoginRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SocialButton(label: 'Google', emoji: '🇬')),
        const SizedBox(width: 12),
        Expanded(child: _SocialButton(label: 'Apple', emoji: '')),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final String emoji;
  const _SocialButton({required this.label, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: () {}, // Hook social auth here
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignTokens.textStrong,
          side: const BorderSide(color: DesignTokens.border, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: DesignTokens.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: DesignTokens.textStrong,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Demo hint card ────────────────────────────────────────────────────────────

class _DemoHint extends StatefulWidget {
  @override
  State<_DemoHint> createState() => _DemoHintState();
}

class _DemoHintState extends State<_DemoHint> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DesignTokens.primaryContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DesignTokens.primaryMuted),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Demo credentials',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: DesignTokens.primaryDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Email: demo@health.ai\nPassword: Password@1',
                  style: TextStyle(
                    fontSize: 11,
                    color: DesignTokens.textMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _visible = false),
            child: const Icon(
              Icons.close_rounded,
              size: 16,
              color: DesignTokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
