import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class DiseaseImage extends StatelessWidget {
  final String imageUrl;
  final double height;

  const DiseaseImage({super.key, required this.imageUrl, this.height = 180});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _Placeholder(height: height);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            height: height,
            decoration: BoxDecoration(
              color: DesignTokens.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: DesignTokens.primary, strokeWidth: 2.5),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _Placeholder(height: height),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final double height;
  const _Placeholder({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DesignTokens.primary, DesignTokens.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text('🦠', style: TextStyle(fontSize: 54)),
      ),
    );
  }
}
