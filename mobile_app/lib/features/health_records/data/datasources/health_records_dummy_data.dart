import '../models/doctor_model.dart';
import '../models/lab_report_model.dart';
import '../models/medical_record_model.dart';
import '../models/medical_timeline_model.dart';
import '../models/prescription_model.dart';
import '../models/report_category_model.dart';

class HealthRecordsDummyData {
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

  static final records = [
    MedicalRecordModel(
      id: 'r1',
      title: 'Annual Physical Checkup',
      category: 'Consultation',
      summary:
          'Routine checkup with normal vitals and advice for balanced diet, hydration, and regular exercise.',
      date: DateTime(2026, 6, 20),
      doctor: doctors[0],
      status: 'Reviewed',
      attachments: const ['checkup-summary.pdf'],
      tags: const ['checkup', 'vitals', 'general'],
    ),
    MedicalRecordModel(
      id: 'r2',
      title: 'Blood Pressure Follow-up',
      category: 'Cardiology',
      summary:
          'Blood pressure readings improved. Continue lifestyle monitoring and prescribed medicine schedule.',
      date: DateTime(2026, 5, 16),
      doctor: doctors[1],
      status: 'Follow-up',
      attachments: const ['bp-chart.jpg'],
      tags: const ['blood pressure', 'heart', 'follow-up'],
    ),
    MedicalRecordModel(
      id: 'r3',
      title: 'Allergy Consultation',
      category: 'Consultation',
      summary:
          'Seasonal allergy symptoms documented. Avoid known triggers and continue antihistamine when needed.',
      date: DateTime(2026, 4, 12),
      doctor: doctors[0],
      status: 'Reviewed',
      attachments: const ['allergy-note.pdf'],
      tags: const ['allergy', 'seasonal', 'medicine'],
    ),
  ];

  static final prescriptions = [
    PrescriptionModel(
      id: 'p1',
      diagnosis: 'Seasonal allergic rhinitis',
      doctor: doctors[0],
      prescribedAt: DateTime(2026, 4, 12),
      validUntil: DateTime(2026, 7, 12),
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
      prescribedAt: DateTime(2026, 5, 16),
      validUntil: DateTime(2026, 8, 16),
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

  static final labReports = [
    LabReportModel(
      id: 'l1',
      testName: 'Complete Blood Count',
      category: 'Blood Test',
      testedAt: DateTime(2026, 6, 18),
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
      testedAt: DateTime(2026, 5, 14),
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
  ];

  static List<MedicalTimelineModel> timeline() {
    return [
      ...records.map(
        (record) => MedicalTimelineModel(
          id: 't-${record.id}',
          title: record.title,
          description: record.summary,
          type: record.category,
          occurredAt: record.date,
          doctorName: record.doctor.name,
        ),
      ),
      ...labReports.map(
        (report) => MedicalTimelineModel(
          id: 't-${report.id}',
          title: report.testName,
          description: report.resultSummary,
          type: report.category,
          occurredAt: report.testedAt,
          doctorName: report.doctor.name,
        ),
      ),
      ...prescriptions.map(
        (prescription) => MedicalTimelineModel(
          id: 't-${prescription.id}',
          title: prescription.diagnosis,
          description: prescription.instructions,
          type: 'Prescription',
          occurredAt: prescription.prescribedAt,
          doctorName: prescription.doctor.name,
        ),
      ),
    ]..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }
}
