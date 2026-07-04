import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../routing/route_names.dart';
import '../../../../shared/design_system/design_tokens.dart';
import '../controllers/authentication_state.dart';
import '../providers/authentication_provider.dart';
import '../widgets/common/auth_background.dart';
import '../widgets/common/loading_overlay.dart';
import '../widgets/common/primary_auth_button.dart';
import '../widgets/otp/otp_input.dart';
import '../widgets/otp/resend_timer.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  ConsumerState<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage>
    with SingleTickerProviderStateMixin {
  String _otp = '';
  String? _email;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) _email = args;
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter the complete 6-digit OTP'),
          backgroundColor: DesignTokens.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    await ref.read(authControllerProvider.notifier).verifyOtp(_otp);
  }

  Future<void> _resend() async {
    if (_email == null) return;
    await ref
        .read(authControllerProvider.notifier)
        .sendForgotPasswordOtp(_email!);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final email = _email ?? state.pendingEmail ?? 'your email';

    ref.listen<AuthenticationState>(authControllerProvider, (prev, next) {
      if (next.isSuccess && next.resetToken != null) {
        Navigator.of(context).pushReplacementNamed(RouteNames.resetPassword);
      }
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Verification failed'),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
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
                                DesignTokens.primaryContainer,
                                DesignTokens.primaryMuted,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: DesignTokens.primary.withValues(alpha: 0.15),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('📱', style: TextStyle(fontSize: 46)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Header ──────────────────────────────────────────
                      const Text(
                        'Check your email',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: DesignTokens.textStrong,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          text: "We've sent a 6-digit code to ",
                          style: const TextStyle(
                            fontSize: 15,
                            color: DesignTokens.textMuted,
                            height: 1.55,
                          ),
                          children: [
                            TextSpan(
                              text: email,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: DesignTokens.textStrong,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Dev hint
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: DesignTokens.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '💡 Dev mode: OTP is 123456',
                          style: TextStyle(
                            fontSize: 12,
                            color: DesignTokens.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ── OTP input ────────────────────────────────────────
                      OtpInput(
                        length: 6,
                        onChanged: (v) => setState(() => _otp = v),
                        onCompleted: (v) {
                          setState(() => _otp = v);
                        },
                      ),

                      const SizedBox(height: 36),

                      // ── Verify button ────────────────────────────────────
                      PrimaryAuthButton(
                        label: 'Verify OTP',
                        onPressed: state.isLoading ? null : _verify,
                        isLoading: state.isLoading,
                        icon: Icons.verified_rounded,
                      ),

                      const SizedBox(height: 28),

                      // ── Resend timer ─────────────────────────────────────
                      Center(
                        child: ResendTimer(
                          seconds: 60,
                          onResend: _resend,
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(height: 24),
                    ],
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
