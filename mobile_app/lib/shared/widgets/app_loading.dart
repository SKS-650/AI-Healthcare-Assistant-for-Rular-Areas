import 'package:flutter/material.dart';

import '../design_system/app_animations.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';

class AppLoading extends StatelessWidget {
  final String message;
  final bool showSkeleton;

  const AppLoading({
    super.key,
    this.message = 'Loading',
    this.showSkeleton = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showSkeleton) return const _SkeletonList();

    return Center(
      child: Padding(
        padding: AppSpacing.screen,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _SkeletonList extends StatefulWidget {
  const _SkeletonList();

  @override
  State<_SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<_SkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppAnimations.slow)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.42 + (_controller.value * 0.28);
        return ListView.separated(
          padding: AppSpacing.screen,
          itemBuilder: (context, index) =>
              Opacity(opacity: opacity, child: const _SkeletonCard()),
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.md),
          itemCount: 5,
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Container(
      height: 104,
      decoration: BoxDecoration(color: color, borderRadius: AppRadius.medium),
      padding: AppSpacing.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 160, height: 16, color: Colors.white24),
          const SizedBox(height: AppSpacing.sm),
          Container(width: double.infinity, height: 12, color: Colors.white24),
          const SizedBox(height: AppSpacing.xs),
          Container(width: 220, height: 12, color: Colors.white24),
        ],
      ),
    );
  }
}
