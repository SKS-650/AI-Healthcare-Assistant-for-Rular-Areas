library symptom_checker;

// =========================================================================
// DATA LAYER EXPORTS
// =========================================================================

// Data Sources
export 'data/datasources/symptom_dummy_data.dart';

// Models
export 'data/models/symptom_model.dart';
export 'data/models/selected_symptom_model.dart';
export 'data/models/medical_history_model.dart';
export 'data/models/lifestyle_model.dart';
export 'data/models/symptom_form_model.dart';
export 'data/models/dummy_result_model.dart';

// Repositories Implementation
export 'data/repositories/symptom_repository_impl.dart';

// =========================================================================
// DOMAIN LAYER EXPORTS
// =========================================================================

// Entities
export 'domain/entities/symptom.dart';
export 'domain/entities/selected_symptom.dart';
export 'domain/entities/medical_history.dart';
export 'domain/entities/lifestyle.dart';
export 'domain/entities/symptom_form.dart';
export 'domain/entities/prediction_result.dart';

// Repositories Contract
export 'domain/repositories/symptom_repository.dart';

// Use Cases
export 'domain/usecases/get_symptoms.dart';
export 'domain/usecases/save_symptom_form.dart';
export 'domain/usecases/load_symptom_form.dart';
export 'domain/usecases/generate_dummy_result.dart';

// =========================================================================
// PRESENTATION LAYER EXPORTS
// =========================================================================

// State Management / Controllers
export 'presentation/controllers/symptom_controller.dart';
export 'presentation/controllers/symptom_state.dart';

// Providers
export 'presentation/providers/symptom_provider.dart';

// Pages / Screen Navigations
export 'presentation/pages/symptom_checker_page.dart';
export 'presentation/pages/symptom_selection_page.dart';
export 'presentation/pages/severity_page.dart';
export 'presentation/pages/duration_page.dart';
export 'presentation/pages/personal_info_page.dart';
export 'presentation/pages/medical_history_page.dart';
export 'presentation/pages/lifestyle_page.dart';
export 'presentation/pages/review_page.dart';
export 'presentation/pages/analyzing_page.dart';
export 'presentation/pages/result_page.dart';

// Common Custom UI Elements
export 'presentation/widgets/common/next_button.dart';
export 'presentation/widgets/common/previous_button.dart';
export 'presentation/widgets/common/progress_header.dart';
export 'presentation/widgets/common/section_title.dart';
export 'presentation/widgets/common/step_indicator.dart';

// Symptom Interactive Selection Subwidgets
export 'presentation/widgets/symptom/symptom_card.dart';
export 'presentation/widgets/symptom/symptom_chip.dart';
export 'presentation/widgets/symptom/selected_symptom_list.dart';
export 'presentation/widgets/symptom/symptom_search_bar.dart';
export 'presentation/widgets/symptom/voice_input_button.dart';

// Intensity Trackers / Severity Adjusters
export 'presentation/widgets/severity/severity_slider.dart';
export 'presentation/widgets/severity/severity_meter.dart';
export 'presentation/widgets/severity/pain_scale.dart';

// Onset / Duration Parameters
export 'presentation/widgets/duration/duration_selector.dart';
export 'presentation/widgets/duration/calendar_selector.dart';

// Comorbidities / Medical Logs
export 'presentation/widgets/medical_history/disease_checkbox.dart';
export 'presentation/widgets/medical_history/allergy_selector.dart';
export 'presentation/widgets/medical_history/medication_input.dart';

// Behavioral / Lifestyle Habits
export 'presentation/widgets/lifestyle/smoking_selector.dart';
export 'presentation/widgets/lifestyle/alcohol_selector.dart';
export 'presentation/widgets/lifestyle/exercise_selector.dart';
export 'presentation/widgets/lifestyle/sleep_selector.dart';

// Form Final Review Summary
export 'presentation/widgets/review/review_card.dart';

// Diagnostics Pipeline / Processing Engines
export 'presentation/widgets/loading/analyzing_animation.dart';
export 'presentation/widgets/loading/loading_status.dart';

// Analytics Evaluation Reports
export 'presentation/widgets/result/risk_meter.dart';
export 'presentation/widgets/result/disease_card.dart';
export 'presentation/widgets/result/recommendation_card.dart';
export 'presentation/widgets/result/disclaimer_card.dart';