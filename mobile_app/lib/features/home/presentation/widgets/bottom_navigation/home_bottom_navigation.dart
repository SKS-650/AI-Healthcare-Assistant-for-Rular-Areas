import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../routing/route_names.dart';
import '../../../../../shared/design_system/design_tokens.dart';
import '../../providers/dashboard_provider.dart';

class HomeBottomNavigation extends ConsumerWidget {
  const HomeBottomNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIdx = ref.watch(dashboardTabProvider);

    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        boxShadow: [
          BoxShadow(
            color: DesignTokens.primary.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
        border: const Border(
            top: BorderSide(color: DesignTokens.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              _NavItem(
                index: 0,
                selectedIndex: currentIdx,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: 'Home',
                emoji: '🏠',
                gradient: const LinearGradient(
                  colors: [Color(0xFF926EFF), Color(0xFF6B47E8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () =>
                    ref.read(dashboardTabProvider.notifier).state = 0,
              ),
              _NavItem(
                index: 1,
                selectedIndex: currentIdx,
                icon: Icons.monitor_heart_outlined,
                selectedIcon: Icons.monitor_heart_rounded,
                label: 'Symptoms',
                emoji: '🩺',
                gradient: const LinearGradient(
                  colors: [Color(0xFF926EFF), Color(0xFF6B47E8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  ref.read(dashboardTabProvider.notifier).state = 1;
                  Navigator.of(context).pushNamed(RouteNames.symptomChecker);
                },
              ),
              _NavItem(
                index: 2,
                selectedIndex: currentIdx,
                icon: Icons.smart_toy_outlined,
                selectedIcon: Icons.smart_toy_rounded,
                label: 'AI Chat',
                emoji: '🤖',
                gradient: const LinearGradient(
                  colors: [Color(0xFF18C8C8), Color(0xFF0B9B9B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  ref.read(dashboardTabProvider.notifier).state = 2;
                  Navigator.of(context).pushNamed(RouteNames.chatbot);
                },
              ),
              _NavItem(
                index: 3,
                selectedIndex: currentIdx,
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
                label: 'Profile',
                emoji: '👤',
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF5E9E), Color(0xFFE11D68)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  ref.read(dashboardTabProvider.notifier).state = 3;
                  Navigator.of(context).pushNamed(RouteNames.profile);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String emoji;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.emoji,
    required this.gradient,
    required this.onTap,
  });

  bool get _selected => index == selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: _selected ? gradient : null,
            color: _selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _selected
                    ? Text(emoji,
                        key: const ValueKey('e'),
                        style: const TextStyle(fontSize: 20))
                    : Icon(icon,
                        key: const ValueKey('i'),
                        size: 22,
                        color: DesignTokens.textMuted),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: _selected
                      ? FontWeight.w800
                      : FontWeight.w500,
                  color:
                      _selected ? Colors.white : DesignTokens.textMuted,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
