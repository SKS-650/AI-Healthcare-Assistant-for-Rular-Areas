import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/prediction_result.dart';
import '../widgets/hospital/hospital_card.dart';
import '../widgets/recommendations/doctor_visit_card.dart';
import '../widgets/recommendations/medicine_card.dart';
import '../widgets/recommendations/prevention_card.dart';
import '../widgets/recommendations/treatment_card.dart';

class RecommendationPage extends StatelessWidget {
  final PredictionResult result;

  const RecommendationPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final recommendation = result.recommendation;
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
            Text('💊', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              'Care Plan',
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          DoctorVisitCard(
            shouldVisitDoctor: recommendation.shouldVisitDoctor,
            reason: recommendation.doctorVisitReason,
          ),
          if (recommendation.treatments.isNotEmpty) ...[
            const _SectionHeader(emoji: '🩺', title: 'Treatments'),
            ...recommendation.treatments.map((item) =>
                TreatmentCard(treatment: item)),
          ],
          if (recommendation.medicines.isNotEmpty) ...[
            const _SectionHeader(emoji: '💊', title: 'Medicines'),
            ...recommendation.medicines.map((item) =>
                MedicineCard(medicine: item)),
          ],
          if (recommendation.preventions.isNotEmpty) ...[
            const _SectionHeader(emoji: '🛡️', title: 'Prevention'),
            ...recommendation.preventions.map((item) =>
                PreventionCard(prevention: item)),
          ],
          if (recommendation.nearbyHospitals.isNotEmpty) ...[
            const _SectionHeader(emoji: '🏥', title: 'Nearby Hospitals'),
            ...recommendation.nearbyHospitals.map((item) =>
                HospitalCard(hospital: item)),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String emoji, title;
  const _SectionHeader({required this.emoji, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: DesignTokens.textStrong,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
