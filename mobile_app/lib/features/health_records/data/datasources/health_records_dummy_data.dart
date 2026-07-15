import '../models/doctor_model.dart';
import '../models/health_summary_model.dart';
import '../models/lab_report_model.dart';
import '../models/medical_history_model.dart';
import '../models/medical_image_model.dart';
import '../models/medical_profile_model.dart';
import '../models/medical_record_model.dart';
import '../models/medical_timeline_model.dart';
import '../models/prescription_model.dart';
import '../models/report_category_model.dart';
import '../models/timeline_event_model.dart';

class HealthRecordsDummyData {
  // ── Doctors ───────────────────────────────────────────────────────────────

  static const doctors = [
    DoctorModel(
      id: 'd1',
      name: 'Dr. Asha Karki',
      specialty: 'Internal Medicine',
      hospital: 'City General Hospital',
      contactNumber: '+977-01-5550101',
    ),
    DoctorModel(
      id: 'd2',
      name: 'Dr. Ramesh Shrestha',
      specialty: 'Cardiology',
      hospital: 'Kathmandu Heart Center',
      contactNumber: '+977-01-5550202',
    ),
    DoctorModel(
      id: 'd3',
      name: 'Dr. Mira Lama',
      specialty: 'Pathology',
      hospital: 'Community Diagnostic Lab',
      contactNumber: '+977-01-5550303',
    ),
  ];

  // ── Medical Profile ───────────────────────────────────────────────────────

  static final MedicalProfileModel medicalProfile = MedicalProfileModel(
    id: 'mp1',
    userId: 'local',
    bloodGroup: 'B+',
    heightCm: 168.0,
    weightKg: 65.0,
    bmi: 23.0,
    smokingStatus: 'never',
    alcoholStatus: 'occasional',
    activityLevel: 'moderate',
    allergies: const ['Penicillin', 'Dust'],
    chronicDiseases: const ['Hypertension'],
    currentMedications: const ['Amlodipine 5mg'],
    familyHistory: const ['Diabetes (mother)', 'Heart disease (father)'],
    vaccinationHistory: const [
      VaccinationRecordModel(
        name: 'COVID-19',
        dateGiven: '2022-09-10',
        dose: '2nd Dose',
      ),
      VaccinationRecordModel(
        name: 'Hepatitis B',
        dateGiven: '2020-04-15',
        dose: 'Booster',
      ),
    ],
    createdAt: _d(2024, 1, 1),
    updatedAt: _d(2026, 5, 12),
  );

  // ── Medical History ───────────────────────────────────────────────────────

  static final List<MedicalHistoryModel> medicalHistory = [
    MedicalHistoryModel(
      id: 'mh1',
      userId: 'local',
      diseaseName: 'Hypertension',
      category: 'chronic',
      diagnosisDate: _d(2022, 3, 10),
      status: 'managed',
      doctorName: 'Dr. Ramesh Shrestha',
      hospitalName: 'Kathmandu Heart Center',
      notes: 'Blood pressure well controlled with medication.',
      createdAt: _d(2022, 3, 10),
      updatedAt: _d(2026, 4, 5),
    ),
    MedicalHistoryModel(
      id: 'mh2',
      userId: 'local',
      diseaseName: 'Typhoid Fever',
      category: 'past',
      diagnosisDate: _d(2021, 8, 5),
      status: 'resolved',
      doctorName: 'Dr. Asha Karki',
      hospitalName: 'City General Hospital',
      notes: 'Fully recovered after antibiotic course.',
      createdAt: _d(2021, 8, 5),
      updatedAt: _d(2021, 9, 1),
    ),
    MedicalHistoryModel(
      id: 'mh3',
      userId: 'local',
      diseaseName: 'Appendectomy',
      category: 'surgery',
      diagnosisDate: _d(2019, 11, 20),
      status: 'resolved',
      doctorName: 'Dr. Suresh Bajracharya',
      hospitalName: 'National Hospital',
      notes: 'Laparoscopic surgery, no complications.',
      createdAt: _d(2019, 11, 20),
      updatedAt: _d(2020, 1, 15),
    ),
    MedicalHistoryModel(
      id: 'mh4',
      userId: 'local',
      diseaseName: 'Penicillin Allergy',
      category: 'allergy',
      status: 'active',
      doctorName: 'Dr. Asha Karki',
      notes: 'Causes rash and swelling. Avoid all penicillin-based antibiotics.',
      createdAt: _d(2018, 6, 1),
      updatedAt: _d(2018, 6, 1),
    ),
    MedicalHistoryModel(
      id: 'mh5',
      userId: 'local',
      diseaseName: 'Type 2 Diabetes',
      category: 'family',
      status: 'active',
      notes: 'Mother diagnosed at age 55. Annual glucose monitoring advised.',
      createdAt: _d(2023, 1, 10),
      updatedAt: _d(2023, 1, 10),
    ),
  ];

  // ── Legacy Records ────────────────────────────────────────────────────────

  static final records = [
    MedicalRecordModel(
      id: 'r1',
      title: 'Annual Physical Checkup',
      category: 'Consultation',
      summary: 'Routine checkup with normal vitals and advice for balanced diet.',
      date: _d(2026, 6, 20),
      doctor: doctors[0],
      status: 'Reviewed',
      attachments: const ['checkup-summary.pdf'],
      tags: const ['checkup', 'vitals', 'general'],
    ),
    MedicalRecordModel(
      id: 'r2',
      title: 'Blood Pressure Follow-up',
      category: 'Cardiology',
      summary: 'Blood pressure readings improved. Continue lifestyle monitoring.',
      date: _d(2026, 5, 16),
      doctor: doctors[1],
      status: 'Follow-up',
      attachments: const ['bp-chart.jpg'],
      tags: const ['blood pressure', 'heart', 'follow-up'],
    ),
    MedicalRecordModel(
      id: 'r3',
      title: 'Allergy Consultation',
      category: 'Consultation',
      summary: 'Seasonal allergy symptoms. Avoid triggers, continue antihistamine.',
      date: _d(2026, 4, 12),
      doctor: doctors[0],
      status: 'Reviewed',
      attachments: const ['allergy-note.pdf'],
      tags: const ['allergy', 'seasonal', 'medicine'],
    ),
  ];

  // ── Prescriptions ─────────────────────────────────────────────────────────

  static final prescriptions = [
    PrescriptionModel(
      id: 'p1',
      diagnosis: 'Seasonal allergic rhinitis',
      doctor: doctors[0],
      prescribedAt: _d(2026, 4, 12),
      validUntil: _d(2026, 7, 12),
      medicines: const [
        MedicineDosageModel(
          name: 'Cetirizine',
          dose: '10 mg',
          frequency: 'Once at night',
          duration: '7 days as needed',
        ),
        MedicineDosageModel(
          name: 'Saline nasal spray',
          dose: '2 sprays',
          frequency: 'Twice daily',
          duration: '10 days',
        ),
      ],
      instructions: 'Avoid dust exposure and drink warm fluids.',
    ),
    PrescriptionModel(
      id: 'p2',
      diagnosis: 'Elevated blood pressure',
      doctor: doctors[1],
      prescribedAt: _d(2026, 5, 16),
      validUntil: _d(2026, 8, 16),
      medicines: const [
        MedicineDosageModel(
          name: 'Amlodipine',
          dose: '5 mg',
          frequency: 'Once daily',
          duration: '30 days',
        ),
      ],
      instructions: 'Record BP twice a week and reduce excess salt.',
    ),
  ];

  // ── Lab Reports ───────────────────────────────────────────────────────────

  static final labReports = [
    LabReportModel(
      id: 'l1',
      testName: 'Complete Blood Count',
      category: 'Blood Test',
      testedAt: _d(2026, 6, 18),
      doctor: doctors[2],
      labName: 'Community Diagnostic Lab',
      resultSummary: 'Most values are within reference range.',
      status: 'Normal',
      values: const {
        'Hemoglobin': '13.8 g/dL',
        'WBC': '7,200 /uL',
        'Platelets': '245,000 /uL',
      },
      attachments: const ['cbc-report.pdf'],
    ),
    LabReportModel(
      id: 'l2',
      testName: 'Lipid Profile',
      category: 'Cardiology',
      testedAt: _d(2026, 5, 14),
      doctor: doctors[1],
      labName: 'Kathmandu Heart Center',
      resultSummary: 'LDL is mildly elevated. Lifestyle review advised.',
      status: 'Attention',
      values: const {
        'Total Cholesterol': '205 mg/dL',
        'LDL': '132 mg/dL',
        'HDL': '48 mg/dL',
      },
      attachments: const ['lipid-profile.pdf'],
    ),
  ];

  // ── Medical Images ────────────────────────────────────────────────────────

  static final List<MedicalImageModel> medicalImages = [
    MedicalImageModel(
      id: 'img1',
      userId: 'local',
      title: 'Chest X-Ray PA View',
      imageType: 'xray',
      description: 'No acute cardiopulmonary disease. Lung fields clear.',
      bodyPart: 'Chest',
      doctorName: 'Dr. Asha Karki',
      hospitalName: 'City General Hospital',
      scanDate: _d(2026, 3, 15),
      tags: const ['chest', 'routine'],
      createdAt: _d(2026, 3, 15),
    ),
    MedicalImageModel(
      id: 'img2',
      userId: 'local',
      title: 'Complete Blood Count Report',
      imageType: 'blood_report',
      description: 'Hemoglobin slightly low. Follow-up in 3 months.',
      doctorName: 'Dr. Mira Lama',
      hospitalName: 'Community Diagnostic Lab',
      scanDate: _d(2026, 6, 18),
      tags: const ['blood', 'cbc'],
      createdAt: _d(2026, 6, 18),
    ),
    MedicalImageModel(
      id: 'img3',
      userId: 'local',
      title: 'Right Knee MRI',
      imageType: 'mri',
      description: 'Mild medial meniscus degeneration. Physiotherapy recommended.',
      bodyPart: 'Right Knee',
      doctorName: 'Dr. Priya Acharya',
      hospitalName: 'Ortho Specialist Center',
      scanDate: _d(2025, 11, 5),
      tags: const ['knee', 'orthopedics'],
      createdAt: _d(2025, 11, 5),
    ),
  ];

  // ── Categories ────────────────────────────────────────────────────────────

  static final categories = [
    const ReportCategoryModel(
      id: 'consultation',
      name: 'Consultation',
      count: 2,
      description: 'Doctor visits, clinical notes, and follow-ups.',
    ),
    const ReportCategoryModel(
      id: 'lab',
      name: 'Lab Reports',
      count: 2,
      description: 'Blood tests, pathology, imaging, and diagnostics.',
    ),
    const ReportCategoryModel(
      id: 'prescription',
      name: 'Prescriptions',
      count: 2,
      description: 'Current and previous medicine plans.',
    ),
    const ReportCategoryModel(
      id: 'images',
      name: 'Medical Images',
      count: 3,
      description: 'X-Rays, MRI, CT scans, and other imaging.',
    ),
  ];

  // ── Unified Timeline Events ───────────────────────────────────────────────

  static List<TimelineEventModel> timelineEvents() {
    final List<TimelineEventModel> events = [
      TimelineEventModel(
        id: 'te1',
        eventType: 'medical_history',
        title: 'Hypertension diagnosis',
        description: 'Chronic condition — managed with Amlodipine 5mg.',
        referenceId: 'mh1',
        iconEmoji: '🩺',
        eventDate: _d(2022, 3, 10),
        createdAt: _d(2022, 3, 10),
      ),
      TimelineEventModel(
        id: 'te2',
        eventType: 'prescription',
        title: 'Prescription: Elevated blood pressure',
        description: 'Dr. Ramesh Shrestha — Amlodipine 5mg once daily.',
        referenceId: 'p2',
        iconEmoji: '💊',
        eventDate: _d(2026, 5, 16),
        createdAt: _d(2026, 5, 16),
      ),
      TimelineEventModel(
        id: 'te3',
        eventType: 'medical_image',
        title: 'Chest X-Ray uploaded',
        description: 'No acute findings. Lung fields clear.',
        referenceId: 'img1',
        iconEmoji: '🩻',
        eventDate: _d(2026, 3, 15),
        createdAt: _d(2026, 3, 15),
      ),
      TimelineEventModel(
        id: 'te4',
        eventType: 'symptom_assessment',
        title: 'Symptom Assessment: Fever & Headache',
        description: 'Risk level: Moderate. Top condition: Viral Fever (84%).',
        iconEmoji: '🤒',
        eventDate: _d(2026, 6, 14),
        createdAt: _d(2026, 6, 14),
      ),
      TimelineEventModel(
        id: 'te5',
        eventType: 'chat_conversation',
        title: 'AI Medical Consultation',
        description: 'Discussed blood pressure management strategies.',
        iconEmoji: '💬',
        eventDate: _d(2026, 7, 1),
        createdAt: _d(2026, 7, 1),
      ),
      TimelineEventModel(
        id: 'te6',
        eventType: 'prescription',
        title: 'Prescription: Allergic rhinitis',
        description: 'Dr. Asha Karki — Cetirizine 10mg at night.',
        referenceId: 'p1',
        iconEmoji: '💊',
        eventDate: _d(2026, 4, 12),
        createdAt: _d(2026, 4, 12),
      ),
      TimelineEventModel(
        id: 'te7',
        eventType: 'medical_image',
        title: 'Right Knee MRI scan',
        description: 'Mild medial meniscus degeneration.',
        referenceId: 'img3',
        iconEmoji: '🧠',
        eventDate: _d(2025, 11, 5),
        createdAt: _d(2025, 11, 5),
      ),
    ]..sort((a, b) => b.eventDate.compareTo(a.eventDate));
    return events;
  }

  // ── Legacy timeline (for backwards compat) ────────────────────────────────

  static List<MedicalTimelineModel> timeline() {
    return [
      ...records.map(
        (r) => MedicalTimelineModel(
          id: 't-${r.id}',
          title: r.title,
          description: r.summary,
          type: r.category,
          occurredAt: r.date,
          doctorName: r.doctor.name,
        ),
      ),
      ...labReports.map(
        (r) => MedicalTimelineModel(
          id: 't-${r.id}',
          title: r.testName,
          description: r.resultSummary,
          type: r.category,
          occurredAt: r.testedAt,
          doctorName: r.doctor.name,
        ),
      ),
      ...prescriptions.map(
        (p) => MedicalTimelineModel(
          id: 't-${p.id}',
          title: p.diagnosis,
          description: p.instructions,
          type: 'Prescription',
          occurredAt: p.prescribedAt,
          doctorName: p.doctor.name,
        ),
      ),
    ]..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }

  // ── Dashboard Summary ─────────────────────────────────────────────────────

  static HealthSummaryModel summary() => HealthSummaryModel(
        hasProfile: true,
        medicalHistoryCount: medicalHistory.length,
        prescriptionCount: prescriptions.length,
        medicalImageCount: medicalImages.length,
        recentTimeline: timelineEvents().take(5).toList(),
      );

  static DateTime _d(int y, int m, int d) => DateTime(y, m, d);
}
