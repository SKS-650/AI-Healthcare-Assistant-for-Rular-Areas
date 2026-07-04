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

class GuestModePage extends ConsumerStatefulWidget {
  const GuestModePage({super.key});

  @override
  ConsumerState<GuestModePage> createState() => _GuestModePageState();
}

class _GuestModePageState extends ConsumerState<GuestModePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  static const _features = [
    _GuestFeature(
      icon: Icons.check_circle_rounded,
      color: DesignTokens.success,
      text: 'Symptom checker',
    ),
    _GuestFeature(
      icon: Icons.check_circle_rounded,
      color: DesignTokens.success,
      text: 'AI health chatbot',
    ),
    _GuestFeature(
      icon: Icons.check_circle_rounded,
      color: DesignTokens.success,
      text: 'Emergency services',
    ),
    _GuestFeature(
      icon: Icons.check_circle_rounded,
      color: DesignTokens.success,
      text: 'Find nearby hospitals',
    ),
    _GuestFeature(
      icon: Icons.cancel_rounded,
      color: DesignTokens.border,
      text: 'Save health records',
      disabled: true,
    ),
    _GuestFeature(
      icon: Icons.cancel_rounded,
      color: DesignTokens.border,
      text: 'Personalised insights',
      disabled: true,
    ),
    _GuestFeature(
      icon: Icons.cancel_rounded,
      color: DesignTokens.border,
      text: 'Medical history',
      disabled: true,
    ),
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
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _continueAsGuest() async {
    await ref.read(authControllerProvider.notifier).continueAsGuest();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    ref.listen<AuthenticationState>(authControllerProvider, (prev, next) {
      if (next.isSuccess && next.user != null && next.user!.isGuest) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteNames.home,
          (r) => false,
        );
      }
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Failed to continue as guest'),
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
                      const SizedBox(height: 32),

                      // ── Illustration ──────────────────────────────────
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                color: DesignTokens.surfaceMuted,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
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
                                    color: DesignTokens.primary
                                        .withValues(alpha: 0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text('👤',
                                    style: TextStyle(fontSize: 46)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Header ─────────────────────────────────────────
                      const Text(
                        'Continue as Guest',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: DesignTokens.textStrong,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Explore the app without creating an account. Some features require sign-in.',
                        style: TextStyle(
                          fontSize: 15,
                          color: DesignTokens.textMuted,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Feature list ──────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: DesignTokens.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: DesignTokens.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'What you can access',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: DesignTokens.textStrong,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._features.map((f) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Icon(f.icon,
                                          color: f.color, size: 18),
                                      const SizedBox(width: 10),
                                      Text(
                                        f.text,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: f.disabled
                                              ? DesignTokens.textSubtle
                                              : DesignTokens.textStrong,
                                          fontWeight: f.disabled
                                              ? FontWeight.w400
                                              : FontWeight.w500,
                                          decoration: f.disabled
                                              ? TextDecoration.lineThrough
                                              : null,
                                          decorationColor:
                                              DesignTokens.textSubtle,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // ── CTA ───────────────────────────────────────────
                      PrimaryAuthButton(
                        label: 'Continue as Guest',
                        onPressed:
                            state.isLoading ? null : _continueAsGuest,
                        isLoading: state.isLoading,
                        icon: Icons.arrow_forward_rounded,
                      ),

                      const SizedBox(height: 12),

                      // ── Sign up prompt ────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context)
                              .pushReplacementNamed(RouteNames.register),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: DesignTokens.primary,
                            side: const BorderSide(
                                color: DesignTokens.primary, width: 1.5),
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.person_add_rounded, size: 18),
                          label: const Text(
                            'Create Free Account',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

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

class _GuestFeature {
  final IconData icon;
  final Color color;
  final String text;
  final bool disabled;

  const _GuestFeature({
    required this.icon,
    required this.color,
    required this.text,
    this.disabled = false,
  });
}
