# Implementation Plan

- [ ] 1. Write bug condition exploration test
  - **Property 1: Bug Condition** - UUID-to-int Cast (C1) and LLM Fallback (C8)
  - **CRITICAL**: This test MUST FAIL on unfixed code — failure confirms the bugs exist
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: These tests encode the expected behavior — they will validate the fix when passing after implementation
  - **GOAL**: Surface counterexamples demonstrating the bugs exist

  **C1 — UUID cast counterexample (Python / pytest):**
  - Create `backend/tests/test_chatbot_dependencies_bug.py`
  - Import `get_current_user` from `app.medical_chatbot.api.dependencies`
  - Mock `UserModel` with `id = "a1b2c3d4-1234-5678-abcd-ef0123456789"` and `is_active = True`
  - Call `get_current_user` with that mock user via a patched DB session
  - **EXPECTED OUTCOME on UNFIXED code**: `ValueError: invalid literal for int() with base 10` is raised → HTTP 500
  - Document counterexample: `get_user_id(user_with_uuid_id)` raises `ValueError`
  - The fixed behavior asserts: return value has `id` of type `str`, no `ValueError`, response status in {200, 400, 401, 429}

  **C8 — LLM fallback counterexample (Python / pytest):**
  - In the same test file, import `ChatbotService` and `get_llm_service`
  - Patch `LLM_API_KEY` env var to `"AQ.invalid_key"` (the currently configured invalid key)
  - Instantiate `ChatbotService` with mocked repos
  - Call `process_chat` with any valid `ChatRequest`
  - **EXPECTED OUTCOME on UNFIXED code**: `LLMServiceException` propagates, HTTP 500 returned
  - Document counterexample: `ChatbotService.__init__` with invalid key crashes `get_llm_service()` before fallback can run

  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Both tests FAIL (this is correct — it proves the bugs exist)
  - Document counterexamples found to understand root cause
  - Mark task complete when tests are written, run, and failures are documented
  - _Requirements: 1.1, 1.9_


- [ ] 2. Write preservation property tests (BEFORE implementing fix)
  - **Property 2: Preservation** - Non-Chatbot Auth and Successful LLM Paths
  - **IMPORTANT**: Follow observation-first methodology
  - **Observe on UNFIXED code** (cases where isBugCondition_C1 and isBugCondition_C8 are FALSE):

  **C1 preservation — non-chatbot endpoints:**
  - Create `backend/tests/test_auth_preservation.py`
  - Observe: `POST /api/v1/auth/login` with valid credentials returns 200 with `tokens.access_token` (non-chatbot path, no UUID cast involved)
  - Observe: `GET /api/v1/users/me` with valid JWT returns 200 with `user_id` field present
  - Observe: `GET /api/v1/symptom-checker/symptoms` without auth returns 200 list (no auth dependency)
  - Write property-based test using `hypothesis`: `@given(st.just("valid_user"))` — assert login, /me, and symptom endpoint all return expected shapes unmodified by C1 fix
  - Verify tests PASS on UNFIXED code

  **C8 preservation — valid LLM key path:**
  - Create `backend/tests/test_chatbot_llm_preservation.py`
  - Observe: with a mocked LLM service that returns a real response, `process_chat` returns `ChatResponse` with HTTP 200
  - Write property-based test using `hypothesis`: `@given(chat_request_strategy())` with mocked valid LLM — assert `ChatResponse.status_code == 200` and `response.message` is non-empty
  - Verify tests PASS on UNFIXED code (mocked LLM is valid so C8 bug condition is false)

  - Run all preservation tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (this confirms baseline behavior to preserve)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.2, 3.4, 3.5, 3.8_


- [ ] 3. Fix Group 1: Critical Backend Fixes

  - [ ] 3.1 Fix UUID-to-int cast in chatbot dependencies (C1)

    **File: `backend/app/medical_chatbot/api/dependencies.py`**
    - In `get_current_user`, change the return dict from:
      `"id": int(user.id) if isinstance(user.id, str) else user.id`
      to: `"id": user.id`  (never cast to int — keep as UUID str)
    - Change `def get_user_id(...) -> int:` return type annotation to `-> str:`

    **File: `backend/app/medical_chatbot/services/chatbot_service.py`**
    - Change `async def process_chat(self, user_id: int, ...)` → `user_id: str`
    - Propagate `user_id: str` to all internal helpers: `_check_rate_limits`, `_get_or_create_conversation`, `get_user_conversations`, `delete_conversation`, `submit_feedback`

    **File: `backend/app/medical_chatbot/api/routes.py`**
    - Change `user_id: int = Depends(get_user_id)` → `user_id: str = Depends(get_user_id)` on all five route handlers: `chat`, `get_conversations`, `get_conversation`, `delete_conversation`, `submit_feedback`

    **File: `backend/app/medical_chatbot/repositories/conversation_repository.py`**
    - Update any `user_id: int` parameter type hints to `user_id: str` in all repository methods

    - Acceptance criteria: `get_user_id` returns the UUID string as-is; no `ValueError` raised for any UUID user ID
    - _Bug_Condition: isBugCondition_C1(X) where typeof(X.user.id) == STRING AND NOT isInteger(X.user.id)_
    - _Expected_Behavior: get_user_id returns str, process_chat accepts str, no ValueError, HTTP response in {200, 400, 401, 429}_
    - _Preservation: Auth/users/symptom-checker endpoints continue to work unchanged; token issuance unchanged_
    - _Requirements: 2.1, 3.1, 3.2, 3.8_

  - [ ] 3.2 Add chatbot model import to startup (C2)

    **File: `backend/app/core/startup.py`**
    - Inside the `if os.getenv("ENVIRONMENT"...) in {"development", "test"}:` block in `on_startup`, add before the `Base.metadata.create_all` call:
      ```python
      import app.medical_chatbot.database.models  # noqa: F401
      ```
    - This registers `Conversation`, `Message`, `ChatbotFeedback`, and `ChatbotSession` with `Base.metadata`

    - Acceptance criteria: after fix, fresh dev startup creates `conversations`, `messages`, `chatbot_feedback`, `chatbot_sessions` tables; production startup still skips auto-create
    - _Bug_Condition: isBugCondition_C2(X) where X.environment IN {"development","test"} AND chatbot models not imported_
    - _Expected_Behavior: tablesExist(["conversations","messages","chatbot_feedback","chatbot_sessions"]) == true_
    - _Preservation: production/staging startup skips the block unchanged; auth/users/symptom_checker tables still created_
    - _Requirements: 2.2, 3.9_

  - [ ] 3.3 Fix chatbot router prefix inconsistency (C9)

    **File: `backend/app/medical_chatbot/api/routes.py`**
    - Change `router = APIRouter(prefix="/api/v1/chatbot", ...)` → `router = APIRouter(prefix="/chatbot", ...)`

    **File: `backend/app/main.py`**
    - Change `app.include_router(chatbot_router)` → `app.include_router(chatbot_router, prefix=settings.api_prefix)`

    - Acceptance criteria: chatbot accessible at `{settings.api_prefix}/chatbot/*`; changing `API_PREFIX` in `.env` moves chatbot route along with all other routers
    - _Bug_Condition: isBugCondition_C9(X) where chatbot registered without prefix AND settings.api_prefix != "/api/v1"_
    - _Expected_Behavior: GET {api_prefix}/chatbot/health returns 200 for any api_prefix value_
    - _Preservation: when API_PREFIX="/api/v1" (default), chatbot still accessible at /api/v1/chatbot/* unchanged_
    - _Requirements: 2.9_

  - [ ] 3.4 Add LLM fallback for invalid/unavailable API key (C8)

    **File: `backend/app/medical_chatbot/services/chatbot_service.py`**
    - In `ChatbotService.__init__`, wrap the `get_llm_service()` call:
      ```python
      try:
          self.llm_service = llm_service or get_llm_service()
      except Exception as e:
          logger.error(f"LLM service unavailable at startup: {e}")
          self.llm_service = None
      ```
    - In `process_chat`, before calling `self.llm_service.generate_response(...)`, add:
      ```python
      if self.llm_service is None:
          # jump to fallback block
      ```
    - Replace fallback response text with:
      ```
      "I'm having trouble connecting to the AI service right now. Here are some general tips:
       For medical emergencies, please call 108 (India) or your local emergency number immediately.
       For non-emergency questions, please consult with a qualified healthcare professional."
      ```

    - Acceptance criteria: with invalid/missing LLM key, `ChatbotService` initialises with `llm_service = None`; `process_chat` returns HTTP 200 with fallback message; LLM error logged server-side
    - _Bug_Condition: isBugCondition_C8(X) where X.llmApiKeyValid == FALSE OR X.llmServiceReachable == FALSE_
    - _Expected_Behavior: HTTP 200, response.message contains fallback text, LLM error logged_
    - _Preservation: when valid LLM key and reachable service, AI-generated response still returned unchanged_
    - _Requirements: 2.8, 3.5_

  - [ ] 3.5 Fix symptom checker sys.path at module level (C6)

    **File: `backend/app/symptom_checker/service.py`**
    - Remove the module-level block (currently lines 7–9):
      ```python
      ai_models_path = Path(__file__).parent.parent.parent.parent / "ai_models"
      sys.path.insert(0, str(ai_models_path))
      ```
    - Inside `_load_model()`, add at the very top of the method body:
      ```python
      ai_models_path = Path(__file__).parent.parent.parent.parent / "ai_models"
      if ai_models_path.exists():
          sys.path.insert(0, str(ai_models_path))
      ```
    - Keep `from pathlib import Path` and `import sys` at the top of the file (they are still needed inside the method)

    - Acceptance criteria: when `ai_models_path` does not exist, `sys.path` is not mutated and no exception propagates; when it does exist, path is inserted and model loads as before
    - _Bug_Condition: isBugCondition_C6(X) where ai_models_path.exists()==FALSE OR moduleImportedBeforePathResolved(X)_
    - _Expected_Behavior: sys.path unchanged when directory missing; model loads and logs OK when directory present_
    - _Preservation: when ai_models_path exists and model file present, model loads with 230 features and logs confirmation unchanged_
    - _Requirements: 2.6, 3.3_

  - [ ] 3.6 Verify bug condition exploration test now passes (C1 and C8)
    - **Property 1: Expected Behavior** - UUID Type Safety and LLM Fallback
    - **IMPORTANT**: Re-run the SAME tests from task 1 — do NOT write new tests
    - Re-run `backend/tests/test_chatbot_dependencies_bug.py` (both C1 and C8 test cases)
    - **EXPECTED OUTCOME**: Both tests PASS (confirms C1 and C8 bugs are fixed)
    - Confirm: `get_user_id` returns str for UUID user, no ValueError
    - Confirm: `process_chat` with invalid LLM key returns HTTP 200 with fallback message
    - _Requirements: 2.1, 2.8_

  - [ ] 3.7 Verify preservation tests still pass after backend fixes
    - **Property 2: Preservation** - Non-Chatbot Auth and Valid LLM Paths
    - **IMPORTANT**: Re-run the SAME tests from task 2 — do NOT write new tests
    - Re-run `backend/tests/test_auth_preservation.py` and `backend/tests/test_chatbot_llm_preservation.py`
    - **EXPECTED OUTCOME**: All preservation tests PASS (confirms no regressions)
    - Confirm: login, /me, symptom-checker endpoints unchanged; valid LLM still returns AI response
    - _Requirements: 3.1, 3.2, 3.4, 3.5, 3.8_


- [ ] 4. Fix Group 2: Flutter Critical Fixes

  - [ ] 4.1 Add missing packages to pubspec.yaml (C10)

    **File: `mobile_app/pubspec.yaml`**
    - Add to the `dependencies:` section (exact pinned versions):
      ```yaml
      shared_preferences: ^2.3.2
      flutter_secure_storage: ^9.2.2
      google_fonts: ^6.2.1
      cached_network_image: ^3.4.1
      shimmer: ^3.0.0
      lottie: ^3.1.2
      ```
    - Run `flutter pub get` and confirm exit code 0 with all packages resolved

    - Acceptance criteria: `flutter pub get` exits 0; all six packages appear in `.dart_tool/package_config.json`; no compile-time "Target of URI doesn't exist" errors
    - _Bug_Condition: isBugCondition_C10(X) where any required package NOT IN X.dependencies_
    - _Expected_Behavior: flutter pub get resolves shared_preferences, flutter_secure_storage, google_fonts, cached_network_image, shimmer, lottie_
    - _Preservation: existing packages (equatable, http, flutter_riverpod) still resolve unchanged_
    - _Requirements: 2.10_

  - [ ] 4.2 Implement token persistence with FlutterSecureStorage (C4)

    **File: `mobile_app/lib/features/authentication/data/repositories/authentication_repository_impl.dart`**
    - Add import: `import 'package:flutter_secure_storage/flutter_secure_storage.dart';`
    - Add field: `final FlutterSecureStorage _storage = const FlutterSecureStorage();`
    - In `login()`: after setting `_accessToken` and `_refreshToken`, add:
      ```dart
      await _storage.write(key: 'access_token', value: _accessToken);
      await _storage.write(key: 'refresh_token', value: _refreshToken);
      ```
    - Add private method `_restoreSession()`:
      ```dart
      Future<void> _restoreSession() async {
        _accessToken = await _storage.read(key: 'access_token');
        _refreshToken = await _storage.read(key: 'refresh_token');
      }
      ```
    - Add public `Future<void> init()` that calls `await _restoreSession()`; call this from the Riverpod provider setup or app initialization
    - Add `Future<bool> isLoggedIn()` returning `_accessToken != null && _accessToken!.isNotEmpty`
    - In `logout()`: add `await _storage.deleteAll();` before nulling the in-memory fields

    - Acceptance criteria: after login + app restart, `isLoggedIn()` returns true; access token readable without re-login; logout clears storage
    - _Bug_Condition: isBugCondition_C4(X) where X.previousSessionTokenSavedToStorage==FALSE AND X.userWasLoggedIn==TRUE_
    - _Expected_Behavior: access_token and refresh_token readable from FlutterSecureStorage after restart_
    - _Preservation: users who were never logged in still get isLoggedIn()==false after restart_
    - _Requirements: 2.4_

  - [ ] 4.3 Fix profile completion error propagation (C5)

    **File: `mobile_app/lib/features/authentication/data/repositories/authentication_repository_impl.dart`**
    - In `completeProfile()`, replace the `if (profilePayload.isNotEmpty)` block's retry logic.
    - Current (buggy) logic:
      ```dart
      if (profileResponse.statusCode != 201 && profileResponse.statusCode != 200) {
        final updateResponse = await http.put(...);  // silently retries even on 422
        if (updateResponse.statusCode != 200) {
          throw _mapError(updateResponse);  // throws PUT error, not original 422
        }
      }
      ```
    - Replace with:
      ```dart
      if (profileResponse.statusCode == 201 || profileResponse.statusCode == 200) {
        // success — continue
      } else if (profileResponse.statusCode == 404) {
        // Profile record not found edge case — retry once with PUT
        final updateResponse = await http.put(
          Uri.parse('${ApiConfig.baseUrl}/api/v1/users/profile'),
          headers: _authHeaders(),
          body: jsonEncode(profilePayload),
        );
        if (updateResponse.statusCode != 200) {
          throw _mapError(updateResponse);
        }
      } else {
        // All other errors (422, 400, 500, etc.) surface immediately
        throw _mapError(profileResponse);
      }
      ```

    - Acceptance criteria: POST 422 throws `AuthException` with the 422 detail immediately; PUT is never called on 422; POST 201 still succeeds without PUT; POST 404 still retries with PUT
    - _Bug_Condition: isBugCondition_C5(X) where POST("/api/v1/users/profile",X).statusCode NOT IN {200,201}_
    - _Expected_Behavior: 422 error surfaces immediately with original detail; no PUT issued_
    - _Preservation: POST 201 path continues to succeed without PUT; successful profile completion unchanged_
    - _Requirements: 2.5, 3.7_

  - [ ] 4.4 Add 401 handler to symptom checker (C7)

    - Find the symptom checker repository or service file that makes the `predict` HTTP call:
      likely `mobile_app/lib/features/symptom_checker/data/repositories/symptom_checker_repository_impl.dart`
      or `mobile_app/lib/features/symptom_checker/data/datasources/symptom_checker_remote_datasource.dart`
    - Wrap the predict HTTP call so that when `response.statusCode == 401`:
      ```dart
      throw AuthException('Please log in to use the Symptom Checker');
      ```
    - In the calling widget/controller (`SymptomCheckerController` or equivalent), add catch for `AuthException`:
      ```dart
      on AuthException catch (e) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.login,
          (_) => false,
          arguments: e.message,
        );
      }
      ```

    - Acceptance criteria: 401 from predict navigates to `/login` with message; no unhandled exception or red-screen; 200 response still displays results normally
    - _Bug_Condition: isBugCondition_C7(X) where X.responseStatusCode==401 AND X.callerHasAuthExceptionHandler==FALSE_
    - _Expected_Behavior: Navigator.pushNamedAndRemoveUntil to /login called with user-readable message_
    - _Preservation: 200 response from predict continues to display results unchanged; no navigation occurs_
    - _Requirements: 2.7_


- [ ] 5. Fix Group 3: Network Configuration (Physical Device Support) (C3)

  - [ ] 5.1 Create NetworkConfig service

    **New file: `mobile_app/lib/config/network_config.dart`**
    ```dart
    import 'package:shared_preferences/shared_preferences.dart';
    import 'package:http/http.dart' as http;

    class NetworkConfig {
      static const _prefKey = 'backend_url';

      /// Read the persisted backend URL. Returns null if not saved.
      static Future<String?> getSavedBackendUrl() async {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(_prefKey);
      }

      /// Persist the backend URL for future launches.
      static Future<void> setBackendUrl(String url) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefKey, url);
      }

      /// Test if the given URL hosts a reachable backend (GET /health within 5s).
      static Future<bool> testConnection(String url) async {
        try {
          final uri = Uri.parse('$url/health');
          final response = await http
              .get(uri)
              .timeout(const Duration(seconds: 5));
          return response.statusCode == 200;
        } catch (_) {
          return false;
        }
      }

      /// Clear the saved backend URL (e.g. when user wants to reconfigure).
      static Future<void> clearSavedUrl() async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_prefKey);
      }
    }
    ```

    - Acceptance criteria: `setBackendUrl` persists across hot-restart; `testConnection` returns true for live backend, false for unreachable URL; `clearSavedUrl` removes the entry
    - _Bug_Condition: isBugCondition_C3(X) where X.platform==PHYSICAL_DEVICE AND X.backendUrlFromPrefs==NULL_
    - _Expected_Behavior: getBackendUrl returns persisted URL; testConnection validates live backend_
    - _Requirements: 2.3_

  - [ ] 5.2 Create BackendSetupPage

    **New file: `mobile_app/lib/features/settings/presentation/pages/backend_setup_page.dart`**
    - Import `NetworkConfig` and `ApiConfig`
    - Stateful widget with:
      - `TextEditingController _urlController` pre-filled with `await NetworkConfig.getSavedBackendUrl() ?? ApiConfig.baseUrl`
      - `bool _testing = false` and `bool? _testPassed` state fields
      - "Test Connection" button: sets `_testing = true`, calls `NetworkConfig.testConnection(_urlController.text)`, sets `_testPassed`, shows green checkmark or red error
      - "Save & Continue" button (enabled only when `_testPassed == true`): calls `NetworkConfig.setBackendUrl(url)` then `Navigator.pushReplacementNamed(context, RouteNames.splash)`
      - Card with shadow using `BoxDecoration(blurRadius: 12, color: Colors.black.withOpacity(0.06), offset: Offset(0, 4))`
      - Instruction text: "Enter the IP address and port of the backend server (e.g. http://192.168.1.100:8000)"

    - Acceptance criteria: page shown on first physical-device launch; test passes with valid URL; URL saved and app proceeds; subsequent launches skip this page
    - _Requirements: 2.3, 3.10_

  - [ ] 5.3 Update ApiConfig to support dynamic URL

    **File: `mobile_app/lib/config/api_config.dart`**
    - Add mutable static field: `static String? _cachedUrl;`
    - Add `static Future<void> init() async` method that reads from `NetworkConfig.getSavedBackendUrl()` and if non-null, sets `_cachedUrl`
    - Change `baseUrl` getter to check `_cachedUrl` first:
      ```dart
      static String get baseUrl {
        if (_cachedUrl != null) return _cachedUrl!;
        // existing platform logic below (unchanged)
        const override = String.fromEnvironment('BACKEND_URL');
        if (override.isNotEmpty) return override;
        if (kIsWeb) return 'http://localhost:$_backendPort';
        if (Platform.isAndroid) {
          return _useEmulator
              ? 'http://10.0.2.2:$_backendPort'
              : 'http://$_devLanIp:$_backendPort';
        }
        // ... rest unchanged
      }
      ```

    - Acceptance criteria: after `ApiConfig.init()`, `baseUrl` returns saved URL when present; emulator still returns `10.0.2.2:8000` when no saved URL; web still returns `localhost:8000`
    - _Preservation: emulator path (isBugCondition_C3 false) returns 10.0.2.2:8000 unchanged; saved-URL path skips setup screen_
    - _Requirements: 2.3, 3.6, 3.10_

  - [ ] 5.4 Update splash page to check connectivity and show setup page if needed

    **File: `mobile_app/lib/features/authentication/presentation/pages/splash_page.dart`**
    - Add `import 'package:shared_preferences/shared_preferences.dart';` and import `NetworkConfig`, `ApiConfig`
    - At the start of the splash initialization logic (before any auth check):
      1. Call `await ApiConfig.init()` to load any saved URL
      2. Attempt `GET {ApiConfig.baseUrl}/health` with 3-second timeout
      3. If connectivity check fails AND `NetworkConfig.getSavedBackendUrl()` returns null → `Navigator.pushReplacementNamed(context, RouteNames.backendSetup)`
      4. If connectivity check passes OR saved URL already present → continue normal auth flow unchanged
    - Also call `await authRepo.init()` (from task 4.2) to restore tokens from secure storage

    - Acceptance criteria: first launch on new network shows BackendSetupPage; after URL saved, subsequent launches skip to auth flow; emulator launches proceed normally without showing setup page
    - _Requirements: 2.3, 3.6, 3.10_

  - [ ] 5.5 Add BackendSetupPage to router

    **File: `mobile_app/lib/routing/route_names.dart`**
    - Add: `static const String backendSetup = '/backend-setup';`

    **File: `mobile_app/lib/routing/app_router.dart`**
    - Add import for `BackendSetupPage`
    - Add route case: `RouteNames.backendSetup: (context, settings) => const BackendSetupPage()`

    - Acceptance criteria: `Navigator.pushNamed(context, RouteNames.backendSetup)` renders `BackendSetupPage`; no unknown route errors
    - _Requirements: 2.3_


- [ ] 6. Fix Group 4: UI Enhancements

  - [ ] 6.1 Update design tokens to blue/teal medical palette

    **File: `mobile_app/lib/shared/design_system/design_tokens.dart`**
    - Update the following color constants (old → new):
      - `primary`: `#926EFF` → `#1565C0`  (primary deep blue)
      - `primaryLight`: `#B89EFF` → `#5E92F3`  (hover / lighter blue)
      - `primaryDark`: `#6B47E8` → `#003C8F`  (pressed / dark blue)
      - `primaryContainer`: `#F0EBFF` → `#E3F2FD`  (light blue background)
      - `teal` (tertiary): `#1BB8A3` → `#00ACC1`  (accent teal)
      - `tealContainer`: `#E3F8F5` → `#E0F7FA`  (light teal background)
      - `danger`: `#FF4757` → `#D32F2F`  (error red)
      - `dangerContainer`: `#FFECEF` → `#FFEBEE`  (error container)
      - `background`: `#F8F6FF` → `#F8FBFF`  (app background)
      - `textStrong`: `#1A1035` → `#0D1B2A`  (near-black text)
      - `textMuted`: `#6B6289` → `#455A64`  (muted body text)
    - Add new constant for gradient: `static const List<Color> blueGradient2 = [Color(0xFF1565C0), Color(0xFF003C8F)];`
    - All other tokens (green, yellow, orange, pink, dark-mode colours, surface) remain unchanged

    - Acceptance criteria: all updated tokens compile; existing usages of unchanged tokens (green, yellow, etc.) are unaffected; `blueGradient2` available for button gradient usage
    - _Requirements: UI design spec_

  - [ ] 6.2 Update light theme with Google Fonts and pill buttons

    **File: `mobile_app/lib/themes/light_theme.dart`**
    - Add import: `import 'package:google_fonts/google_fonts.dart';`
    - Update `AppBarTheme.titleTextStyle`:
      ```dart
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      ```
    - Update `FilledButton` style:
      ```dart
      FilledButton.styleFrom(
        backgroundColor: DesignTokens.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: const StadiumBorder(),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
      )
      ```

    - Acceptance criteria: app bar titles render in Poppins Bold; filled buttons are full-width pill-shaped (52dp height); no compile errors
    - _Requirements: UI design spec_

  - [ ] 6.3 Update dark theme with Google Fonts and blue palette

    **File: `mobile_app/lib/themes/dark_theme.dart`**
    - Add import: `import 'package:google_fonts/google_fonts.dart';`
    - Update `AppBarTheme.titleTextStyle` with `GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)`
    - Update dark-mode primary color constants:
      - `primary` (dark mode) → `Color(0xFF82B1FF)`  (light blue suitable for dark backgrounds)
      - `primaryDeep` (dark mode) → `Color(0xFF1565C0)`

    - Acceptance criteria: dark-mode app bar titles render in Poppins; dark-mode primary color is readable light blue; no regression on other dark-mode colors
    - _Requirements: UI design spec_


- [ ] 7. Checkpoint — Ensure all tests pass
  - Run all backend tests: `pytest backend/tests/ -v`
  - Confirm `test_chatbot_dependencies_bug.py` (C1 exploration) passes — UUID user ID flows through without ValueError
  - Confirm `test_chatbot_dependencies_bug.py` (C8 exploration) passes — invalid LLM key returns HTTP 200 with fallback
  - Confirm `test_auth_preservation.py` passes — login, /me, symptom-checker endpoints unchanged
  - Confirm `test_chatbot_llm_preservation.py` passes — valid mocked LLM still returns AI response
  - Run `flutter pub get` in `mobile_app/` — confirm exit code 0 and all 6 new packages resolved
  - Run Flutter analyzer: `flutter analyze` — confirm no new errors introduced
  - Run Flutter tests: `flutter test` in `mobile_app/` — confirm all widget/unit tests pass
  - Verify end-to-end: backend starts without error; chatbot tables exist in dev DB; chatbot health endpoint accessible at `{api_prefix}/chatbot/health`
  - Ensure all tests pass; ask the user if questions arise.
