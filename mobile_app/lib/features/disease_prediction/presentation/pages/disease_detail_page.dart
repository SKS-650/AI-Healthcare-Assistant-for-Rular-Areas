import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/disease.dart';
import '../widgets/disease/disease_causes.dart';
import '../widgets/disease/disease_header.dart';
import '../widgets/disease/disease_image.dart';
import '../widgets/disease/disease_information.dart';
import '../widgets/disease/disease_symptoms.dart';

class DiseaseDetailPage extends StatelessWidget {
  final Disease disease;

  const DiseaseDetailPage({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: DesignTokens.primary,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                disease.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [DesignTokens.primaryDark, DesignTokens.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: disease.imageUrl.isNotEmpty
                    ? DiseaseImage(imageUrl: disease.imageUrl)
                    : const Center(
                        child: Text('🦠', style: TextStyle(fontSize: 64)),
                      ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DesignTokens.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: DesignTokens.border),
                  ),
                  child: DiseaseHeader(disease: disease),
                ),

                const SizedBox(height: 16),

                _Section(
                  emoji: 'ℹ️',
                  title: 'Overview',
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DiseaseInformation(disease: disease),
                  ),
                ),

                const SizedBox(height: 12),

                _Section(
                  emoji: '🌡️',
                  title: 'Common Symptoms',
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DiseaseSymptoms(disease: disease),
                  ),
                ),

                const SizedBox(height: 12),

                _Section(
                  emoji: '🔬',
                  title: 'Possible Causes',
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DiseaseCauses(disease: disease),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String emoji, title;
  final Widget child;
  const _Section(
      {required this.emoji, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DesignTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: DesignTokens.textStrong,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}
