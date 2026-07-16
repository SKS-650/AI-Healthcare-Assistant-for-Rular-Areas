import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/authentication/presentation/providers/authentication_provider.dart';
import '../../../../../routing/route_names.dart';
import '../../../../../shared/design_system/design_tokens.dart';

class GreetingWidget extends ConsumerWidget {
  const GreetingWidget({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _emoji() {
    final h = DateTime.now().hour;
    if (h < 12) return '☀️';
    if (h < 17) return '🌤️';
    return '🌙';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final isGuest = user?.isGuest ?? false;

    // Derive initials from name or fall back to guest icon
    String initials = '?';
    String displayName = 'Guest';
    if (user != null && !isGuest) {
      displayName = user.name ?? user.email.split('@').first;
      final parts = displayName.trim().split(' ');
      initials = parts.length >= 2
          ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
          : displayName.substring(0, displayName.length >= 2 ? 2 : 1)
              .toUpperCase();
    }

    return Row(
      children: [
        // Avatar — tapping opens the profile page
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(RouteNames.profile),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isGuest
                    ? [DesignTokens.textSubtle, DesignTokens.textMuted]
                    : const [Color(0xFF926EFF), Color(0xFF6B47E8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (isGuest ? DesignTokens.textMuted : DesignTokens.primary)
                      .withValues(alpha: 0.28),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: isGuest
                  ? const Icon(Icons.person_rounded,
                      color: Colors.white, size: 22)
                  : Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    isGuest ? 'Browsing as' : _greeting(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: DesignTokens.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isGuest ? '👤' : _emoji(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              Text(
                isGuest ? 'Guest User' : displayName,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  letterSpacing: -0.3,
                  color: isGuest
                      ? DesignTokens.textMuted
                      : DesignTokens.textStrong,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
