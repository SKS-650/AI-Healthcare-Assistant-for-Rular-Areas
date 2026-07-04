import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/prediction_result.dart';
import '../widgets/charts/confidence_chart.dart';
import '../widgets/charts/disease_probability_chart.dart';
import '../widgets/charts/risk_gauge.dart';
import '../widgets/hospital/nearby_hospital_preview.dart';
import 'disease_detail_page.dart';
import 'recommendation_page.dart';

class PredictionResultPage extends StatelessWidget {
  final PredictionResult result;

  const PredictionResultPage({super.key, required this.result});

  Color _riskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'low': return DesignTokens.success;
      case 'medium': return DesignTokens.warning;
      case 'high': return DesignTokens.orange;
      case 'critical': return DesignTokens.danger;
      default: return DesignTokens.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rc = _riskColor(result.riskLevel);
    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          children: [
            Text('🧬', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              'Prediction Result',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textStrong,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // Hero result banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [rc, rc.withValues(alpha: 0.75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: rc.withValues(alpha: 0.35),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${result.riskLevel.toUpperCase()} RISK',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        result.disease.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        result.disease.shortDescription,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${(result.confidence * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const Text(
                      'confidence',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Charts row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DesignTokens.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: DesignTokens.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ConfidenceChart(confidence: result.confidence)),
                  Container(
                    width: 1,
                    height: 80,
                    color: DesignTokens.border,
                  ),
                  Expanded(
                    child: RiskGauge(riskLevel: result.riskLevel)),
                ],
              ),
            ),
          ),

          // Probability chart
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('📊', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 8),
                    Text(
                      'Disease Probabilities',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: DesignTokens.textStrong,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DesignTokens.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: DesignTokens.border),
                  ),
                  child: DiseaseProbabilityChart(
                      probabilities: result.probabilities),
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.info_outline_rounded, size: 18),
                    label: const Text('Disease Info',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            DiseaseDetailPage(disease: result.disease),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DesignTokens.primary,
                      side: const BorderSide(color: DesignTokens.primary),
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.healing_rounded, size: 18),
                    label: const Text('Care Plan',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            RecommendationPage(result: result),
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: DesignTokens.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Nearby hospitals
          if (result.recommendation.nearbyHospitals.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                children: [
                  Text('🏥', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Text(
                    'Nearby Care',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: DesignTokens.textStrong,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            NearbyHospitalPreview(
              hospitals: result.recommendation.nearbyHospitals,
            ),
          ],
        ],
      ),
    );
  }
}
