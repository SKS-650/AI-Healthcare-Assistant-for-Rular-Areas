// lib/features/home/presentation/widgets/common/loading_widget.dart
import 'package:flutter/material.dart';

class DashboardSkeletonLoader extends StatelessWidget {
  const DashboardSkeletonLoader({super.key});

  Widget _buildSkeletonBox({required double height, double? width, double borderRadius = 12}) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildSkeletonBox(height: 110, borderRadius: 16), // Weather card bone
          _buildSkeletonBox(height: 95, borderRadius: 16),  // Health score bone
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Container(width: 120, height: 16, color: Colors.grey.withValues(alpha: 0.2)),
          ),
          
          // Quick actions grid bones
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: 4,
            itemBuilder: (_, __) => Column(
              children: [
                Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.15), shape: BoxShape.circle)),
                const SizedBox(height: 8),
                Container(width: 45, height: 10, color: Colors.grey.withValues(alpha: 0.15)),
              ],
            ),
          ),
          
          _buildSkeletonBox(height: 80, borderRadius: 16), // SOS block bone
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}