// Authentication feature barrel export.
//
// Import this single file to access all public auth symbols:
//   import 'package:mobile_apps/features/authentication/authentication.dart';
library authentication;

// ── Domain ────────────────────────────────────────────────────────────────────
export 'domain/entities/user.dart';
export 'domain/entities/auth_state.dart';
export 'domain/entities/onboarding.dart';
export 'domain/repositories/authentication_repository.dart';
export 'domain/usecases/login.dart';
export 'domain/usecases/register.dart';
export 'domain/usecases/logout.dart';
export 'domain/usecases/guest_login.dart';
export 'domain/usecases/forgot_password.dart';
export 'domain/usecases/verify_otp.dart';
export 'domain/usecases/reset_password.dart';
export 'domain/usecases/complete_profile.dart';
export 'domain/usecases/load_onboarding.dart';

// ── Data ──────────────────────────────────────────────────────────────────────
export 'data/datasources/auth_dummy_data.dart';
export 'data/models/user_model.dart';
export 'data/repositories/authentication_repository_impl.dart';

// ── Presentation ──────────────────────────────────────────────────────────────
export 'presentation/controllers/authentication_state.dart';
export 'presentation/controllers/authentication_controller.dart';
export 'presentation/providers/authentication_provider.dart';

// Pages
export 'presentation/pages/splash_page.dart';
export 'presentation/pages/onboarding_page.dart';
export 'presentation/pages/welcome_page.dart';
export 'presentation/pages/login_page.dart';
export 'presentation/pages/register_page.dart';
export 'presentation/pages/forgot_password_page.dart';
export 'presentation/pages/otp_verification_page.dart';
export 'presentation/pages/reset_password_page.dart';
export 'presentation/pages/profile_completion_page.dart';
export 'presentation/pages/guest_mode_page.dart';

// Common widgets
export 'presentation/widgets/common/auth_background.dart';
export 'presentation/widgets/common/auth_header.dart';
export 'presentation/widgets/common/auth_text_field.dart';
export 'presentation/widgets/common/primary_auth_button.dart';
export 'presentation/widgets/common/loading_overlay.dart';
export 'presentation/widgets/common/divider_with_text.dart';

// OTP widgets
export 'presentation/widgets/otp/otp_input.dart';
export 'presentation/widgets/otp/resend_timer.dart';

// Onboarding widgets
export 'presentation/widgets/onboarding/onboarding_indicator.dart';

// Dialogs
export 'presentation/widgets/dialogs/success_dialog.dart';
export 'presentation/widgets/dialogs/error_dialog.dart';
export 'presentation/widgets/dialogs/logout_dialog.dart';
