// ── Data layer ────────────────────────────────────────────────────────────────
export 'data/datasources/health_records_dummy_data.dart';
export 'data/datasources/health_records_remote_datasource.dart';
export 'data/models/doctor_model.dart';
export 'data/models/health_summary_model.dart';
export 'data/models/lab_report_model.dart';
export 'data/models/medical_history_model.dart';
export 'data/models/medical_image_model.dart';
export 'data/models/medical_profile_model.dart';
export 'data/models/medical_record_model.dart';
export 'data/models/medical_timeline_model.dart';
export 'data/models/prescription_model.dart';
export 'data/models/report_category_model.dart';
export 'data/models/timeline_event_model.dart';
export 'data/models/upload_record_model.dart';
export 'data/repositories/health_records_repository_impl.dart';

// ── Domain — entities ─────────────────────────────────────────────────────────
export 'domain/entities/doctor.dart';
export 'domain/entities/health_records_summary.dart';
export 'domain/entities/lab_report.dart';
export 'domain/entities/medical_history_entry.dart';
export 'domain/entities/medical_image_record.dart';
export 'domain/entities/medical_profile.dart';
export 'domain/entities/medical_record.dart';
export 'domain/entities/medical_timeline.dart';
export 'domain/entities/prescription.dart';
export 'domain/entities/report_category.dart';
export 'domain/entities/timeline_event.dart';
export 'domain/entities/upload_record.dart';

// ── Domain — repository interface ─────────────────────────────────────────────
export 'domain/repositories/health_records_repository.dart';

// ── Domain — use cases ────────────────────────────────────────────────────────
export 'domain/usecases/create_medical_history.dart';
export 'domain/usecases/delete_medical_history.dart';
export 'domain/usecases/get_health_summary.dart';
export 'domain/usecases/get_lab_reports.dart';
export 'domain/usecases/get_medical_history.dart';
export 'domain/usecases/get_medical_images.dart';
export 'domain/usecases/get_medical_profile.dart';
export 'domain/usecases/get_medical_records.dart';
export 'domain/usecases/get_medical_timeline.dart';
export 'domain/usecases/get_prescriptions.dart';
export 'domain/usecases/get_timeline_events.dart';
export 'domain/usecases/search_records.dart';
export 'domain/usecases/update_medical_history.dart';
export 'domain/usecases/upload_dummy_record.dart';
export 'domain/usecases/upload_medical_image.dart';
export 'domain/usecases/upsert_medical_profile.dart';

// ── Presentation ──────────────────────────────────────────────────────────────
export 'presentation/controllers/health_records_controller.dart';
export 'presentation/controllers/health_records_state.dart';
export 'presentation/pages/health_records_home_page.dart';
export 'presentation/pages/lab_reports_page.dart';
export 'presentation/pages/medical_history_page.dart';
export 'presentation/pages/medical_images_page.dart';
export 'presentation/pages/medical_profile_page.dart';
export 'presentation/pages/medical_records_page.dart';
export 'presentation/pages/medical_timeline_page.dart';
export 'presentation/pages/prescriptions_page.dart';
export 'presentation/pages/report_detail_page.dart';
export 'presentation/pages/search_records_page.dart';
export 'presentation/pages/upload_report_page.dart';
export 'presentation/providers/health_records_provider.dart';
