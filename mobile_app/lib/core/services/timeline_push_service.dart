/// Lightweight service for pushing events onto the health records timeline
/// from any feature module (symptom checker, emergency, chatbot).
///
/// Uses [HealthRecordsRemoteDataSource] under the hood — fire-and-forget,
/// never throws to callers.
library;

import '../../features/health_records/data/datasources/health_records_remote_datasource.dart';

class TimelinePushService {
  TimelinePushService._();
  static final TimelinePushService instance = TimelinePushService._();

  final _ds = HealthRecordsRemoteDataSource.instance;

  // ── Symptom checker ───────────────────────────────────────────────────────

  Future<void> pushSymptomAssessment({
    required String diseaseName,
    required double confidence,
    required String riskLevel,
    String? referenceId,
  }) async {
    final pct = (confidence * 100).toStringAsFixed(1);
    await _ds.pushTimelineEvent(
      eventType: 'symptom_assessment',
      title: 'Symptom Check: $diseaseName',
      description: '$riskLevel risk · $pct% confidence',
      referenceId: referenceId,
    );
  }

  // ── Emergency assessment ──────────────────────────────────────────────────

  Future<void> pushEmergencyAssessment({
    required String possibleEmergency,
    required String riskLevel,
    required int riskScore,
    String? assessmentId,
  }) async {
    await _ds.pushTimelineEvent(
      eventType: 'emergency_assessment',
      title: 'Emergency: $possibleEmergency',
      description: '$riskLevel risk · Score $riskScore/100',
      referenceId: assessmentId,
    );
  }

  // ── AI chatbot conversation ───────────────────────────────────────────────

  Future<void> pushChatConversation({
    required String summary,
    String? conversationId,
  }) async {
    await _ds.pushTimelineEvent(
      eventType: 'chat_conversation',
      title: 'AI Medical Consultation',
      description: summary,
      referenceId: conversationId,
    );
  }
}
