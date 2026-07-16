import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import 'auth_provider.dart';
import '../../core/router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'admin@healthcare.ai');
  final _passCtrl = TextEditingController(text: 'Admin@123456');
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final error = await ref
        .read(authStateProvider.notifier)
        .login(_emailCtrl.text.trim(), _passCtrl.text.trim());
    if (mounted) {
      setState(() => _loading = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        context.go(AppRoutes.dashboard);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBg : const Color(0xFF0EA5A0).withOpacity(0.04),
      body: Row(
        children: [
          // ── Left panel (hero) ─────────────────────────────────────────────
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0EA5A0),
                    const Color(0xFF0A7B77),
                    const Color(0xFF065F5C),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Background circles
                  Positioned(
                    top: -80,
                    right: -80,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -60,
                    left: -60,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(56),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.local_hospital_rounded,
                              color: Colors.white, size: 32),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: -0.2),
                        const SizedBox(height: 32),
                        Text(
                          'AI Healthcare\nAssistant',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2),
                        )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 600.ms)
                            .slideX(begin: -0.1),
                        const SizedBox(height: 16),
                        Text(
                          'Admin Dashboard — Complete control\nover your healthcare platform.',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withOpacity(0.85),
                                    height: 1.6,
                                  ),
                        )
                            .animate()
                            .fadeIn(delay: 350.ms, duration: 600.ms),
                        const SizedBox(height: 48),
                        // Feature bullets
                        ...[
                          ('👥', 'User Management'),
                          ('🚨', 'Emergency Monitoring'),
                          ('🤖', 'Chatbot Analytics'),
                          ('📊', 'Reports & Insights'),
                        ]
                            .asMap()
                            .entries
                            .map((e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    children: [
                                      Text(e.value.$1,
                                          style:
                                              const TextStyle(fontSize: 22)),
                                      const SizedBox(width: 12),
                                      Text(
                                        e.value.$2,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                                color: Colors.white
                                                    .withOpacity(0.9),
                                                fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                )
                                    .animate()
                                    .fadeIn(
                                        delay:
                                            Duration(milliseconds: 400 + e.key * 100),
                                        duration: 500.ms)
                                    .slideX(begin: -0.05)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Right panel (form) ────────────────────────────────────────────
          Expanded(
            flex: 4,
            child: Container(
              color: isDark ? AppColors.darkSurface : Colors.white,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 48, vertical: 40),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Welcome back 👋',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.1),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to your admin account',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.lightTextMuted,
                                  ),
                        ).animate().fadeIn(delay: 100.ms),
                        const SizedBox(height: 40),

                        // ── Form ─────────────────────────────────────────
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email address',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                validator: (v) =>
                                    (v == null || !v.contains('@'))
                                        ? 'Enter valid email'
                                        : null,
                              )
                                  .animate()
                                  .fadeIn(delay: 200.ms, duration: 400.ms),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passCtrl,
                                obscureText: _obscure,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon:
                                      const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                validator: (v) => (v == null || v.length < 6)
                                    ? 'Password too short'
                                    : null,
                                onFieldSubmitted: (_) => _submit(),
                              )
                                  .animate()
                                  .fadeIn(delay: 300.ms, duration: 400.ms),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _submit,
                                  child: _loading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Sign In',
                                          style: TextStyle(fontSize: 16)),
                                ),
                              ).animate().fadeIn(delay: 400.ms),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                        // Demo hint
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Demo credentials',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                          color: AppColors.primaryDark)),
                              const SizedBox(height: 4),
                              Text('admin@healthcare.ai',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: AppColors.primaryDark)),
                              Text('Admin@123456',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: AppColors.primaryDark)),
                            ],
                          ),
                        ).animate().fadeIn(delay: 500.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
