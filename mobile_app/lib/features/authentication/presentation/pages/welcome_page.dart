import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../routing/route_names.dart';
import '../../../../shared/design_system/design_tokens.dart';
import '../widgets/common/auth_background.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeTop;
  late Animation<Offset> _slideTop;
  late Animation<double> _fadeButtons;
  late Animation<Offset> _slideButtons;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeTop = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideTop = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _fadeButtons = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );

    _slideButtons = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Top section ────────────────────────────────────────────
                FadeTransition(
                  opacity: _fadeTop,
                  child: SlideTransition(
                    position: _slideTop,
                    child: Column(
                      children: [
                        // App icon
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                DesignTokens.primaryDark,
                                DesignTokens.primary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    DesignTokens.primary.withValues(alpha: 0.4),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '🏥',
                              style: TextStyle(fontSize: 48),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        const Text(
                          'AI Healthcare',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: DesignTokens.textStrong,
                            letterSpacing: -0.8,
                            height: 1.1,
                          ),
                        ),
                        const Text(
                          'Assistant',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w300,
                            color: DesignTokens.primary,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'Smart, accessible healthcare\nguidance for everyone',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: DesignTokens.textMuted,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Feature pills row
                        const Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            _FeaturePill('🩺', 'Symptom Check'),
                            _FeaturePill('🤖', 'AI Chat'),
                            _FeaturePill('🚨', 'Emergency SOS'),
                            _FeaturePill('🏥', 'Find Hospitals'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // ── Buttons ────────────────────────────────────────────────
                FadeTransition(
                  opacity: _fadeButtons,
                  child: SlideTransition(
                    position: _slideButtons,
                    child: Column(
                      children: [
                        // Sign In
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  DesignTokens.primaryDark,
                                  DesignTokens.primary,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: DesignTokens.primary
                                      .withValues(alpha: 0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: FilledButton.icon(
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(RouteNames.login),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(Icons.login_rounded, size: 20),
                              label: const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Create Account
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context)
                                .pushNamed(RouteNames.register),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: DesignTokens.primary,
                              side: const BorderSide(
                                  color: DesignTokens.primary, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.person_add_rounded, size: 20),
                            label: const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Guest
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: TextButton.icon(
                            onPressed: () => Navigator.of(context)
                                .pushNamed(RouteNames.guestMode),
                            style: TextButton.styleFrom(
                              foregroundColor: DesignTokens.textMuted,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.visibility_rounded, size: 18),
                            label: const Text(
                              'Continue as Guest',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Terms
                FadeTransition(
                  opacity: _fadeButtons,
                  child: const Text(
                    'By continuing you agree to our Terms & Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: DesignTokens.textSubtle,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final String emoji;
  final String label;
  const _FeaturePill(this.emoji, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: DesignTokens.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DesignTokens.primaryMuted),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DesignTokens.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
