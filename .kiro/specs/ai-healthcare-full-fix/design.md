# AI Healthcare Full Fix — Bugfix Design

## Overview

The AI Healthcare Assistant has ten distinct bugs spanning the FastAPI backend and Flutter mobile app.
The fixes fall into four concern areas:

1. **Backend type safety** — UUID user IDs are force-cast to `int`, crashing every chatbot request (C1). The chatbot DB models are never imported at startup, so their tables are never created (C2). The chatbot router bypasses the shared API-prefix mechanism (C9).
2. **Backend robustness** — The LLM service has no fallback when the API key is invalid or the service is unreachable (C8). The symptom-checker inserts its `sys.path` entry at module-import time, which can fail before the path is validated (C6).
3. **Mobile connectivity** — The backend IP is hardcoded (`192.168.18.26`), making the app unusable on any other network without recompiling (C3). Tokens are kept only in memory, logging users out every app restart (C4). Six packages required by existing code are missing from `pubspec.yaml` (C10).
4. **Mobile error handling** — `completeProfile` silently swallows 422 errors and retries with PUT (C5). The symptom-checker page has no 401 handler (C7).

Each fix is minimal and targeted. No existing passing behavior is removed.


## Glossary

- **Bug_Condition (C)**: A predicate C(X) that is `true` for inputs that trigger a specific bug.
- **Property (P)**: The desired correct behavior when C(X) is true — what the fixed code must produce.
- **Preservation**: All behavior for inputs where C(X) is false must remain byte-for-byte identical.
- **F / F'**: The original (unfixed) function and the fixed function respectively.
- **UUID user ID**: `UserModel.id` is `String(36)` in the SQLAlchemy model, holding a UUID like `"a1b2c3d4-1234-..."`. It is never an integer.
- **`get_user_id`**: Dependency in `backend/app/medical_chatbot/api/dependencies.py` that extracts the user ID from the JWT and passes it to route handlers.
- **`process_chat`**: The primary method in `ChatbotService` that handles each message turn.
- **`on_startup`**: Async lifecycle hook in `backend/app/core/startup.py` that initialises the DB tables.
- **`_load_model`**: Method in `SymptomCheckerService` that resolves the `ai_models` path and loads the ML model.
- **`completeProfile`**: Method in `AuthenticationRepositoryImpl` that updates user name, phone, gender, age, and language.
- **`NetworkConfig`**: New Flutter service that persists and retrieves the runtime backend URL.
- **`BackendSetupPage`**: New Flutter page shown on first launch (or failed connection) allowing the user to enter the backend URL.
- **`FlutterSecureStorage`**: Package storing tokens encrypted on the device keychain/keystore.
- **`shared_preferences`**: Package storing non-sensitive preferences (e.g. persisted backend URL).
- **`FallbackResponse`**: The plain-text message returned by the chatbot when the LLM call fails for any reason.
- **`api_prefix`**: The `settings.API_PREFIX` value (default `/api/v1`) shared by all routers except the chatbot in the current buggy code.


## Bug Details

### C1 — UUID-to-int Cast in Chatbot Dependencies

The bug manifests on every authenticated chatbot request. `get_current_user` in
`backend/app/medical_chatbot/api/dependencies.py` returns a dict where `"id"` is coerced
with `int(user.id) if isinstance(user.id, str) else user.id`. Because `UserModel.id` is
always a UUID string like `"a1b2c3d4-..."`, this always hits the `int()` branch and always
raises `ValueError: invalid literal for int() with base 10`.

**Formal Specification:**
```
FUNCTION isBugCondition_C1(X)
  INPUT: X of type AuthenticatedChatRequest
  OUTPUT: boolean

  RETURN typeof(X.user.id) == STRING
         AND NOT isInteger(X.user.id)
END FUNCTION
```

**Examples:**
- User ID `"a1b2c3d4-1234-5678-abcd-ef0123456789"` → `int(...)` raises `ValueError` → HTTP 500
- User ID `"00000000-0000-0000-0000-000000000001"` → same crash
- Expected: user ID passed as-is (`str`) through `get_user_id` → `process_chat` receives `str`

---

### C2 — Chatbot DB Models Not Imported at Startup

The bug manifests the first time the backend runs in development (or after a DB wipe).
`on_startup` imports `app.auth.models`, `app.users.models`, and `app.symptom_checker.models`
before calling `Base.metadata.create_all`, but never imports `app.medical_chatbot.database.models`.
SQLAlchemy only creates tables whose model classes have been imported into the same Python process.
Result: `conversations`, `messages`, `chatbot_feedback`, and `chatbot_sessions` tables are never created.

**Formal Specification:**
```
FUNCTION isBugCondition_C2(X)
  INPUT: X of type ServerStartupContext
  OUTPUT: boolean

  RETURN X.environment IN {"development", "test"}
         AND "app.medical_chatbot.database.models" NOT IN X.importedModules
END FUNCTION
```

**Examples:**
- Fresh dev environment → chatbot tables missing → every `/api/v1/chatbot/*` call returns 500
- After `Base.metadata.drop_all` in tests → tables stay missing until fix applied

---

### C3 — Hardcoded Backend IP

The bug manifests when a physical Android/iOS device is on any network other than the developer's
home WiFi (`192.168.18.26`). `api_config.dart` returns this hardcoded string with no runtime
override path.

**Formal Specification:**
```
FUNCTION isBugCondition_C3(X)
  INPUT: X of type AppLaunchContext
  OUTPUT: boolean

  RETURN X.platform == PHYSICAL_DEVICE
         AND X.backendUrlFromPrefs == NULL
         AND X.currentNetwork != "developer_home_wifi"
END FUNCTION
```

**Examples:**
- Student uses own WiFi (192.168.1.x subnet) → all API calls fail with `SocketException`
- Demo on mobile data → same failure
- After fix: first launch shows `BackendSetupPage`; subsequent launches use saved URL


---

### C4 — Token Not Persisted Across App Restarts

`AuthenticationRepositoryImpl` stores `_accessToken` and `_refreshToken` as in-memory fields only.
On app restart, Dart's object heap is cleared and both tokens become `null`. The app re-runs the
splash page, finds no token, and redirects to login — forcing the user to re-authenticate every
time. `flutter_secure_storage` and `shared_preferences` are absent from `pubspec.yaml`.

**Formal Specification:**
```
FUNCTION isBugCondition_C4(X)
  INPUT: X of type AppLaunchContext
  OUTPUT: boolean

  RETURN X.previousSessionTokenSavedToStorage == FALSE
         AND X.userWasLoggedIn == TRUE
END FUNCTION
```

---

### C5 — Profile Completion Swallows 422 Errors

`completeProfile` in `authentication_repository_impl.dart` POST to `/api/v1/users/profile`.
If the response is not 201 or 200 it silently issues a PUT to the same endpoint. If the PUT
also fails, _that_ error is thrown — not the original 422. Developers cannot diagnose the
actual validation failure because it is discarded.

**Formal Specification:**
```
FUNCTION isBugCondition_C5(X)
  INPUT: X of type ProfileCompletionRequest
  OUTPUT: boolean

  RETURN POST("/api/v1/users/profile", X).statusCode NOT IN {200, 201}
END FUNCTION
```

---

### C6 — Symptom Checker `sys.path` Insert at Module Level

`backend/app/symptom_checker/service.py` calls `sys.path.insert(0, str(ai_models_path))` at the
module's top level, before the `SymptomCheckerService` class. If Python imports this file before
the project root is on `sys.path`, or if the `ai_models` directory does not exist, the next
`from symptom_checker...` import may fail with `ModuleNotFoundError`. Additionally, there is no
existence check on `ai_models_path`.

**Formal Specification:**
```
FUNCTION isBugCondition_C6(X)
  INPUT: X of type ServerStartupContext
  OUTPUT: boolean

  RETURN ai_models_path.exists() == FALSE
         OR moduleImportedBeforePathResolved(X)
END FUNCTION
```

---

### C7 — Symptom Checker 401 Not Handled in Flutter

When a user with an expired or missing JWT calls the symptom checker predict endpoint, the backend
returns HTTP 401. The Flutter symptom-checker feature has no `catch` block for `AuthException`
around its API calls, so the exception propagates unhandled, resulting in a red-screen error in
debug mode or a silent crash in release.

**Formal Specification:**
```
FUNCTION isBugCondition_C7(X)
  INPUT: X of type SymptomCheckerApiCall
  OUTPUT: boolean

  RETURN X.responseStatusCode == 401
         AND X.callerHasAuthExceptionHandler == FALSE
END FUNCTION
```

---

### C8 — Chatbot LLM Has No Fallback on API Failure

`LLMService.__init__` raises `LLMServiceException("LLM API key not configured")` if the key
is empty, and `GeminiProvider._initialize_client` raises when the key format is invalid (the
configured key `AQ.Ab8RN6J9...` is not a valid Google AI Studio key; valid keys start with
`AIza`). Even when the exception is caught in `process_chat`, `ResponseValidator.get_fallback_response`
returns a generic technical string, not a human-friendly message. The user receives HTTP 500.

**Formal Specification:**
```
FUNCTION isBugCondition_C8(X)
  INPUT: X of type ChatRequest
  OUTPUT: boolean

  RETURN X.llmApiKeyValid == FALSE
         OR X.llmServiceReachable == FALSE
         OR X.llmQuotaExceeded == TRUE
END FUNCTION
```

---

### C9 — Chatbot Router Prefix Inconsistency

`routes.py` sets `prefix="/api/v1/chatbot"` on the `APIRouter`. `main.py` calls
`app.include_router(chatbot_router)` without a prefix. All other routers receive their prefix
from `app.include_router(router, prefix=settings.api_prefix)`. If `API_PREFIX` in `.env` is
changed (e.g. to `/api/v2`), every other router moves, but the chatbot stays at `/api/v1/chatbot`.

**Formal Specification:**
```
FUNCTION isBugCondition_C9(X)
  INPUT: X of type RouterRegistration
  OUTPUT: boolean

  RETURN X.router == chatbot_router
         AND X.registeredWithPrefix == FALSE
         AND settings.api_prefix != "/api/v1"
END FUNCTION
```

---

### C10 — Missing pubspec.yaml Packages

`mobile_app/pubspec.yaml` only declares `equatable`, `http`, and `flutter_riverpod`. Existing
feature files import `google_fonts`, `cached_network_image`, `shimmer`, `lottie`,
`shared_preferences`, and `flutter_secure_storage`. Running `flutter pub get` resolves none of
these, causing compile-time `Target of URI doesn't exist` errors.

**Formal Specification:**
```
FUNCTION isBugCondition_C10(X)
  INPUT: X of type PubspecYaml
  OUTPUT: boolean

  RETURN ANY package IN REQUIRED_PACKAGES
         WHERE package NOT IN X.dependencies
END FUNCTION

REQUIRED_PACKAGES = {
  "shared_preferences", "flutter_secure_storage",
  "google_fonts", "cached_network_image",
  "shimmer", "lottie"
}
```


## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- WHEN a user logs in with valid credentials, the backend SHALL continue to return JWT access and refresh tokens in the login response.
- WHEN a user registers, the system SHALL continue to auto-login and return a `UserEntity` to Flutter.
- WHEN the symptom checker model loads with 230 features, the startup log SHALL continue to show the OK confirmation.
- WHEN unauthenticated calls reach `/api/v1/symptom-checker/symptoms` or `/api/v1/symptom-checker/diseases`, those endpoints SHALL continue to respond without requiring a token.
- WHEN a valid LLM API key is configured and the LLM service is reachable, the chatbot SHALL continue to return AI-generated responses.
- WHEN the Flutter app runs on an Android emulator, `ApiConfig.baseUrl` SHALL continue to return `http://10.0.2.2:8000`.
- WHEN `completeProfile` POST returns HTTP 201 (new profile created), the method SHALL continue to succeed without attempting the PUT.
- WHEN any authenticated user calls `/api/v1/users/me`, the response SHALL continue to include the `user_id` field.
- WHEN the backend starts in `production` or `staging`, the dev auto-create block SHALL continue to be skipped.
- WHEN the Flutter app launches and a saved backend URL already exists in `shared_preferences`, the app SHALL continue directly to the normal splash/auth flow without showing `BackendSetupPage`.

**Scope:**
All inputs that do NOT match any of C1–C10's bug conditions should produce exactly the same behavior as before. This includes:
- Authenticated requests to non-chatbot endpoints
- Emulator-based development workflows
- Successful profile completions (201 from POST)
- Symptom checker calls with valid tokens


## Hypothesized Root Cause

### C1 — UUID-to-int Cast
The developer originally designed `UserModel.id` as an integer primary key, then migrated to a UUID string primary key (`String(36)` with `default=_uuid4`). The chatbot dependency module was written when the original integer design was still in place. The cast was never updated to track the schema change. The `Conversation.user_id` FK column also uses `String(36)`, confirming that UUID is the correct type throughout the chatbot schema.

### C2 — Missing Model Import
SQLAlchemy's `Base.metadata.create_all` only creates tables registered in the `Base.metadata` registry. A model class is registered only when its module is imported. The chatbot models were added after the startup file was written, and no one added the corresponding import to the auto-create block. The chatbot models import `Base` from `app.auth.models`, so they share the same registry — they just need to be imported.

### C3 — Hardcoded IP
The file was written for the developer's own LAN. There is no `shared_preferences` dependency in `pubspec.yaml`, so a proper runtime-persistence approach was never implemented.

### C4 — No Token Persistence
`flutter_secure_storage` is not listed in `pubspec.yaml` and was never called in the repository. The developer likely intended to add it later but the feature was never completed.

### C5 — Silent POST→PUT Retry
The retry was intended as a convenience for the "profile already exists, just update it" case (HTTP 200 from the POST endpoint, not 404). However the condition `!= 201 && != 200` also catches 422 validation errors, hiding them from the developer.

### C6 — Module-Level `sys.path` Insert
Path manipulation was added at module level for convenience. The issue is that Python module initialisation order is not guaranteed when multiple modules are imported in parallel during startup. Moving the insert inside `_load_model()` makes it lazy and ensures it runs after the file system is accessible.

### C7 — No 401 Handler in Flutter Symptom Checker
The symptom-checker feature was developed independently and does not share the same error-handling layer as the auth feature. A 401 is treated as an unexpected exception with no specific catch branch.

### C8 — No LLM Fallback
`LLMService.__init__` raises immediately on an invalid key, which means `get_llm_service()` crashes before returning an instance. `ChatbotService.__init__` calls `get_llm_service()` directly, so the service itself cannot be instantiated. The existing `except LLMServiceException` in `process_chat` never runs because the crash happens at construction time, not call time. The fix must wrap the `get_llm_service()` call at construction time.

### C9 — Prefix Inconsistency
Copy-paste from an older version of the router that predated the centralised `settings.api_prefix` pattern. The hardcoded `/api/v1/chatbot` was never updated when the other routers were normalised.

### C10 — Missing pubspec Packages
Packages were referenced in feature Dart files as they were written, but the corresponding `pubspec.yaml` entries were never added, possibly because the files were scaffolded without running `flutter pub add`.


## Correctness Properties

Property 1: Bug Condition — UUID Type Safety (C1)

_For any_ authenticated chatbot request where `UserModel.id` is a UUID string
(isBugCondition_C1 returns true), the fixed `get_current_user` SHALL return `{"id": user.id}`
without any `int()` cast, `get_user_id` SHALL have return type `str`, and `process_chat` SHALL
accept `user_id: str`, so that no `ValueError` is raised and the response status is one of
{200, 400, 401, 429}.

**Validates: Requirements 2.1**

---

Property 2: Preservation — Non-Chatbot Auth Paths (C1)

_For any_ request that does NOT involve the chatbot dependency chain (all auth, users, and
symptom-checker endpoints), the fixed code SHALL produce the same response as the original code,
preserving token issuance, registration, and user profile retrieval.

**Validates: Requirements 3.1, 3.2, 3.8**

---

Property 3: Bug Condition — Chatbot DB Tables Created at Startup (C2)

_For any_ server startup context where the environment is `"development"` or `"test"`
(isBugCondition_C2 returns true), the fixed `on_startup` SHALL ensure that `conversations`,
`messages`, `chatbot_feedback`, and `chatbot_sessions` tables exist in the database after startup
completes.

**Validates: Requirements 2.2**

---

Property 4: Preservation — Production Startup Unchanged (C2)

_For any_ server startup context where the environment is `"production"` or `"staging"`,
the fixed `on_startup` SHALL continue to skip the auto-create block, preserving the existing
production-safe behaviour.

**Validates: Requirements 3.9**

---

Property 5: Bug Condition — Runtime Backend URL Resolution (C3)

_For any_ physical-device launch context where no URL is saved in `shared_preferences`
(isBugCondition_C3 returns true), the fixed Flutter app SHALL display `BackendSetupPage`,
accept a URL from the user, test connectivity via `GET /health`, and persist the URL in
`shared_preferences` so the next launch skips the setup screen.

**Validates: Requirements 2.3**

---

Property 6: Preservation — Emulator and Saved-URL Paths Unchanged (C3)

_For any_ launch context where the device is an emulator OR a saved URL already exists in
`shared_preferences`, `ApiConfig.baseUrl` SHALL continue to return the emulator host
(`10.0.2.2:8000`) or the saved URL respectively, without showing `BackendSetupPage`.

**Validates: Requirements 3.6, 3.10**

---

Property 7: Bug Condition — Token Persisted Across App Restarts (C4)

_For any_ app restart that follows a successful login (isBugCondition_C4 returns true), the fixed
`AuthenticationRepositoryImpl` SHALL read `access_token` and `refresh_token` from
`FlutterSecureStorage` so the user is still authenticated and does not see the login page.

**Validates: Requirements 2.4**

---

Property 8: Bug Condition — 422 Errors Surface Immediately (C5)

_For any_ `completeProfile` call where the POST to `/api/v1/users/profile` returns a status code
that is not 200 or 201 (isBugCondition_C5 returns true), the fixed method SHALL throw immediately
with the original error detail and SHALL NOT issue a follow-up PUT request.

**Validates: Requirements 2.5**

---

Property 9: Preservation — Successful POST 201 Path Unchanged (C5)

_For any_ `completeProfile` call where the POST returns HTTP 201, the fixed method SHALL continue
to succeed without attempting PUT, preserving the happy-path behaviour.

**Validates: Requirements 3.7**

---

Property 10: Bug Condition — Safe `sys.path` Insertion (C6)

_For any_ server startup where `_load_model()` is called, the fixed service SHALL only insert
`ai_models_path` into `sys.path` if the directory exists, and SHALL perform the insertion inside
`_load_model()` rather than at module-import time, so that import-order issues cannot cause
`ModuleNotFoundError`.

**Validates: Requirements 2.6**

---

Property 11: Preservation — Symptom Checker Model Load Unchanged (C6)

_For any_ startup where `ai_models_path` exists and the model file is present, the fixed service
SHALL load the model and log the confirmation message identically to the original behaviour.

**Validates: Requirements 3.3**

---

Property 12: Bug Condition — 401 Redirects to Login in Flutter (C7)

_For any_ symptom-checker API call that receives HTTP 401
(isBugCondition_C7 returns true), the fixed Flutter code SHALL navigate to `/login` via
`Navigator.pushNamedAndRemoveUntil` with a user-readable message instead of crashing.

**Validates: Requirements 2.7**

---

Property 13: Bug Condition — LLM Failure Returns Fallback Response (C8)

_For any_ chatbot request where the LLM API call fails for any reason — invalid key, network
error, quota exceeded (isBugCondition_C8 returns true) — the fixed `process_chat` SHALL return
HTTP 200 with a `FallbackResponse` message that guides the user toward emergency services and
professional care, and SHALL log the LLM error server-side.

**Validates: Requirements 2.8**

---

Property 14: Preservation — Working LLM Still Returns AI Response (C8)

_For any_ chatbot request where the LLM API key is valid and the service is reachable, the fixed
code SHALL continue to return an AI-generated response with no change to the existing pipeline.

**Validates: Requirements 3.5**

---

Property 15: Bug Condition — Chatbot Router Uses Shared Prefix (C9)

_For any_ router registration where `settings.api_prefix` is changed from its default `/api/v1`,
the fixed chatbot router SHALL be accessible at `{settings.api_prefix}/chatbot/*` — the same
pattern as all other routers — rather than the hardcoded `/api/v1/chatbot/*`.

**Validates: Requirements 2.9**

---

Property 16: Bug Condition — All Required Packages Resolve (C10)

_For any_ run of `flutter pub get` on the fixed `pubspec.yaml`, the dependency resolver SHALL
successfully resolve `shared_preferences`, `flutter_secure_storage`, `google_fonts`,
`cached_network_image`, `shimmer`, and `lottie`, eliminating all compile-time import errors.

**Validates: Requirements 2.10**


## Fix Implementation

### FIX C1 — UUID Type Safety

**File:** `backend/app/medical_chatbot/api/dependencies.py`

**Specific Changes:**
1. In `get_current_user`: change `"id": int(user.id) if isinstance(user.id, str) else user.id` → `"id": user.id` (keep as `str` — never cast to `int`).
2. Change `def get_user_id(...) -> int:` return type annotation to `-> str:`.

**File:** `backend/app/medical_chatbot/services/chatbot_service.py`

**Specific Changes:**
3. Change `async def process_chat(self, user_id: int, ...)` → `user_id: str`.
4. Propagate `str` type hint to all internal helpers that receive `user_id` (e.g. `_check_rate_limits`, `_get_or_create_conversation`, `get_user_conversations`, `delete_conversation`, `submit_feedback`).

**File:** `backend/app/medical_chatbot/api/routes.py`

**Specific Changes:**
5. Change `user_id: int = Depends(get_user_id)` → `user_id: str = Depends(get_user_id)` on all six route functions (`chat`, `get_conversations`, `get_conversation`, `delete_conversation`, `submit_feedback`).

**File:** `backend/app/medical_chatbot/repositories/conversation_repository.py` (and any other repo that declares `user_id: int`)

**Specific Changes:**
6. Update any `user_id: int` type hints in repository methods to `str`.

---

### FIX C2 — Chatbot DB Models Import at Startup

**File:** `backend/app/core/startup.py`

**Specific Changes:**
1. Inside the `if os.getenv("ENVIRONMENT"...) in {"development", "test"}:` block in `on_startup`, add one import line before the `Base.metadata.create_all` call:
   ```python
   import app.medical_chatbot.database.models  # noqa: F401
   ```
   This registers `Conversation`, `Message`, `ChatbotFeedback`, and `ChatbotSession` with `Base.metadata`.

---

### FIX C3 — Dynamic Backend URL

**New File:** `mobile_app/lib/config/network_config.dart`

```dart
// Provides runtime-persisted backend URL with connectivity testing.
// Falls back to ApiConfig.baseUrl if nothing is saved.

class NetworkConfig {
  static const _prefKey = 'backend_url';

  static Future<String> getBackendUrl() async { ... }   // reads shared_preferences
  static Future<void> setBackendUrl(String url) async { ... }  // writes shared_preferences
  static Future<bool> testConnection(String url) async { ... } // GET /health, 5s timeout
  static Future<void> clearSavedUrl() async { ... }
}
```

**New File:** `mobile_app/lib/features/settings/presentation/pages/backend_setup_page.dart`

Fields:
- `TextEditingController` pre-filled with `await NetworkConfig.getBackendUrl()`
- "Test Connection" button — calls `NetworkConfig.testConnection(url)`, shows green tick or red error
- "Save & Continue" button — calls `NetworkConfig.setBackendUrl(url)` then pops or navigates to splash

**File:** `mobile_app/lib/config/api_config.dart`

Changes:
- Add a `static String? _cachedUrl` mutable field.
- Add `static Future<void> init()` that reads from `NetworkConfig` and caches into `_cachedUrl`.
- Change `baseUrl` getter to return `_cachedUrl` if non-null, otherwise fall back to existing platform logic.

**File:** `mobile_app/lib/features/authentication/presentation/pages/splash_page.dart`

Changes:
- Before navigating, call `ApiConfig.init()`.
- Attempt `GET /health`. If it fails and no URL is saved in prefs → push `BackendSetupPage`.

**File:** `mobile_app/lib/routing/route_names.dart`

Changes:
- Add `static const backendSetup = '/backend-setup';`

**File:** `mobile_app/lib/routing/app_router.dart`

Changes:
- Add `RouteNames.backendSetup => const BackendSetupPage()` to the switch.

---

### FIX C4 — Token Persistence

**File:** `mobile_app/pubspec.yaml`

Changes (also covers C10):
```yaml
shared_preferences: ^2.3.2
flutter_secure_storage: ^9.2.2
```

**File:** `mobile_app/lib/features/authentication/data/repositories/authentication_repository_impl.dart`

Specific Changes:
1. Add a `FlutterSecureStorage _storage` field, initialised at construction or lazily.
2. In `login`: after setting `_accessToken` and `_refreshToken`, call:
   ```dart
   await _storage.write(key: 'access_token', value: _accessToken);
   await _storage.write(key: 'refresh_token', value: _refreshToken);
   ```
3. Add `Future<void> _restoreSession()` that reads from `_storage` and populates `_accessToken` / `_refreshToken` if not null.
4. Call `_restoreSession()` from the constructor's `initializer` or via an `init()` method called from the Riverpod provider setup.
5. In `logout`: call `await _storage.deleteAll()` before nulling the in-memory fields.
6. Add `Future<bool> isLoggedIn()` that returns `true` if `_accessToken` is non-null and non-empty.

---

### FIX C5 — Profile Completion Error Propagation

**File:** `mobile_app/lib/features/authentication/data/repositories/authentication_repository_impl.dart`

Specific Changes — replace the `if (profilePayload.isNotEmpty)` block:
1. First: `POST /api/v1/users/profile`.
2. If response is `201` → success, continue.
3. If response is `200` → also success (server accepted an upsert), continue.
4. If response is `404` → the profile record does not exist yet in an edge case; retry once with `PUT`.
5. If response is any other status (including `422`) → call `throw _mapError(profileResponse)` immediately; **do not** issue a PUT.

---

### FIX C6 — Symptom Checker `sys.path`

**File:** `backend/app/symptom_checker/service.py`

Specific Changes:
1. Remove the module-level `sys.path.insert` block (lines 7–9 in the current file).
2. Inside `_load_model()`, add at the top:
   ```python
   ai_models_path = Path(__file__).parent.parent.parent.parent / "ai_models"
   if ai_models_path.exists():
       sys.path.insert(0, str(ai_models_path))
   ```
3. Keep the rest of `_load_model()` unchanged.

---

### FIX C7 — Symptom Checker 401 Handler in Flutter

**File:** `mobile_app/lib/features/symptom_checker/data/repositories/symptom_checker_repository_impl.dart` (or equivalent service file that makes the `predict` call)

Specific Changes:
1. Wrap the `predict` HTTP call in a try/catch for `AuthException` (or check the HTTP status explicitly).
2. On 401, throw `AuthException('Please log in to use the Symptom Checker')`.
3. In the calling widget/controller, catch `AuthException` and call:
   ```dart
   Navigator.pushNamedAndRemoveUntil(context, RouteNames.login, (_) => false);
   ```

---

### FIX C8 — Chatbot LLM Fallback

**File:** `backend/app/medical_chatbot/services/chatbot_service.py`

Specific Changes:
1. Wrap `self.llm_service = llm_service or get_llm_service()` in `ChatbotService.__init__` in a `try/except Exception`:
   ```python
   try:
       self.llm_service = llm_service or get_llm_service()
   except Exception as e:
       logger.error(f"LLM service unavailable at startup: {e}")
       self.llm_service = None
   ```
2. In `process_chat`, before calling `self.llm_service.generate_response(...)`, check `if self.llm_service is None:` and jump directly to the fallback block.
3. Replace the fallback response text with:
   ```
   "I'm having trouble connecting to the AI service right now. Here are some general tips:
   For medical emergencies, please call 108 (India) or your local emergency number immediately.
   For non-emergency questions, please consult with a qualified healthcare professional."
   ```

**File:** `backend/app/medical_chatbot/services/llm_service.py`

Changes:
4. In `LLMService.__init__`, change the `if not self.api_key: raise ...` guard to `if not self.api_key: raise LLMServiceException(...)` — no change needed here; the caller (`ChatbotService`) must catch it instead.

---

### FIX C9 — Chatbot Router Prefix Normalisation

**File:** `backend/app/medical_chatbot/api/routes.py`

Specific Changes:
1. Change `router = APIRouter(prefix="/api/v1/chatbot", ...)` → `router = APIRouter(prefix="/chatbot", ...)`.

**File:** `backend/app/main.py`

Specific Changes:
2. Change `app.include_router(chatbot_router)` → `app.include_router(chatbot_router, prefix=settings.api_prefix)`.

---

### FIX C10 — pubspec.yaml Missing Packages

**File:** `mobile_app/pubspec.yaml`

Add to the `dependencies:` section:
```yaml
shared_preferences: ^2.3.2
flutter_secure_storage: ^9.2.2
google_fonts: ^6.2.1
cached_network_image: ^3.4.1
shimmer: ^3.0.0
lottie: ^3.1.2
```


## UI Design

### Design Language

The app adopts a modern medical/healthcare design language built on top of the existing
Material3 + design-tokens architecture. The key change is that the current purple-tinted palette
is replaced with a clinical deep-blue and teal palette. Google Fonts `Poppins` is added for
headings. The existing `DesignTokens` and theme files are updated in-place — no new design system
files are created.

**Color Palette Changes:**

| Token | Old Value | New Value | Purpose |
|-------|-----------|-----------|---------|
| `primary` | `#926EFF` (purple) | `#1565C0` | Primary deep blue |
| `primaryLight` | `#B89EFF` | `#5E92F3` | Hover / lighter blue |
| `primaryDark` | `#6B47E8` | `#003C8F` | Pressed / dark blue |
| `primaryContainer` | `#F0EBFF` | `#E3F2FD` | Light blue background |
| `teal` (tertiary) | `#1BB8A3` | `#00ACC1` | Accent teal |
| `tealContainer` | `#E3F8F5` | `#E0F7FA` | Light teal background |
| `danger` | `#FF4757` | `#D32F2F` | Error red |
| `dangerContainer` | `#FFECEF` | `#FFEBEE` | Error container |
| `background` | `#F8F6FF` | `#F8FBFF` | App background |
| `surface` | `#FFFFFF` | `#FFFFFF` | Card surface (unchanged) |
| `textStrong` | `#1A1035` | `#0D1B2A` | Near-black text |
| `textMuted` | `#6B6289` | `#455A64` | Muted body text |

All other tokens (green, yellow, orange, pink, dark-mode colours) remain unchanged.

### Typography

**File:** `mobile_app/lib/themes/light_theme.dart` and `mobile_app/lib/themes/dark_theme.dart`

Add `google_fonts` import and apply `GoogleFonts.poppins()` for heading styles:
- `AppBarTheme.titleTextStyle` → `GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)`
- `CardTheme` headline text via `textTheme.titleMedium` → `GoogleFonts.poppins(...)`

Body text continues to use the system default (`TextTheme` is not overridden globally to avoid forcing Poppins on data-dense screens like chat and symptom lists).

### Card Style

No change needed — existing `cardRadius: 20` and `elevation: 0` with `BorderSide` are already the target design. Only the border colour changes with the new `border` token above.

Cards needing the "subtle shadow" variant should use:
```dart
BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(20),
  boxShadow: [
    BoxShadow(
      blurRadius: 12,
      color: Colors.black.withOpacity(0.06),
      offset: Offset(0, 4),
    ),
  ],
)
```
This is documented here for use in `BackendSetupPage` and any future feature cards.

### Buttons

`FilledButton` style in `LightTheme` changes from a flat `backgroundColor` to a `LinearGradient`
via `ButtonStyle.backgroundBuilder` (Material3 pattern):

```dart
FilledButton.styleFrom(
  // Keep as fallback for non-gradient contexts
  backgroundColor: DesignTokens.primary,
  foregroundColor: Colors.white,
  minimumSize: const Size(double.infinity, 52),
  shape: StadiumBorder(),
  textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
)
```

Full-width pill buttons are achieved by setting `minimumSize: const Size(double.infinity, 52)` and `shape: StadiumBorder()`. Components that need a gradient fill should wrap the button in a `DecoratedBox` with a `LinearGradient` using `[DesignTokens.primary, DesignTokens.primaryDark]`.

### Risk Level Chips (Symptom Checker)

Status chips for risk levels use solid colour backgrounds:

| Risk Level | Background | Foreground |
|------------|-----------|------------|
| Low | `#E8F5E9` | `#2E7D32` |
| Medium | `#FFF8E1` | `#F57F17` |
| High | `#FFF3E0` | `#E65100` |
| Critical | `#FFEBEE` | `#C62828` |

These are applied as `Chip` `backgroundColor` and `labelStyle` colours in the symptom checker result widget. They do not change the existing `ChipTheme`; they are set inline.

### Theme File Changes Summary

**File:** `mobile_app/lib/shared/design_system/design_tokens.dart`
- Update the colour constants listed in the table above.
- Add `static const List<Color> blueGradient2 = [Color(0xFF1565C0), Color(0xFF003C8F)];` for button gradients.

**File:** `mobile_app/lib/themes/light_theme.dart`
- Import `google_fonts` and apply `GoogleFonts.poppins()` to `AppBarTheme.titleTextStyle`.
- Update `FilledButton` `minimumSize` to `Size(double.infinity, 52)` and `shape` to `StadiumBorder()`.

**File:** `mobile_app/lib/themes/dark_theme.dart`
- Import `google_fonts` and apply `GoogleFonts.poppins()` to `AppBarTheme.titleTextStyle`.
- Update dark-mode primary colours to match the blue palette:
  - `primary` → `Color(0xFF82B1FF)` (light blue for dark mode)
  - `primaryDeep` → `Color(0xFF1565C0)`

**File:** `mobile_app/lib/app/app_theme.dart`
- No changes needed; it simply delegates to `LightTheme` and `DarkTheme`.


## Testing Strategy

### Validation Approach

Testing follows a two-phase pattern across all ten fixes:
1. **Exploratory / Counterexample phase** — run tests against unfixed code to confirm the bug fires and to validate root-cause hypotheses.
2. **Fix + Preservation phase** — after applying each fix, run the same tests plus preservation tests to confirm (a) the bug is gone and (b) no existing behaviour regressed.

Property-based tests are used wherever the input space is large (user IDs, router registrations, startup contexts). Unit tests cover the narrower, deterministic fixes.

---

### Exploratory Bug Condition Checking

**C1 — UUID cast:**
- Unit test: call `get_current_user` with a mock `UserModel` whose `id = "a1b2c3d4-1234-5678-abcd-ef0123456789"`. Assert `ValueError` is raised on unfixed code.
- Property test: generate random UUID strings, assert `get_current_user` always raises on unfixed code.

**C2 — Missing tables:**
- Integration test: start FastAPI in-process with a fresh SQLite DB, do NOT apply the fix, call `GET /api/v1/chatbot/health`. Assert `OperationalError: no such table: conversations`.

**C3 — Hardcoded IP:**
- Unit test: call `ApiConfig.baseUrl` with `kIsWeb = false`, `Platform.isAndroid = true`, `_useEmulator = false`, `_devLanIp = "192.168.18.26"`. Assert returns the hardcoded IP on unfixed code.

**C4 — No token persistence:**
- Unit test: set `_accessToken = "tok"`, simulate app restart (recreate the `AuthenticationRepositoryImpl`), assert `accessToken == null` on unfixed code.

**C5 — Silent retry:**
- Unit test: mock the `POST /api/v1/users/profile` response as 422 with `{"detail": "phone is invalid"}`. Assert on unfixed code that the `PUT` is also called and the 422 detail is lost.

**C6 — Module-level path insert:**
- Unit test: import `symptom_checker.service` with a patched `Path.__truediv__` that makes `ai_models_path` return a non-existent directory. Assert that `sys.path` is mutated even when the directory does not exist on unfixed code.

**C7 — 401 unhandled:**
- Widget test: mount the symptom checker page, stub the repository to throw a 401-based exception. Assert the test fails with an unhandled exception on unfixed code.

**C8 — No fallback:**
- Unit test: configure `LLM_API_KEY = "AQ.invalid"`. Call `get_llm_service()`. Assert `LLMServiceException` propagates to caller on unfixed code, causing HTTP 500.

**C9 — Prefix inconsistency:**
- Integration test: create the FastAPI app with `API_PREFIX = "/api/v2"`. Assert `GET /api/v2/chatbot/health` returns 404 on unfixed code and `GET /api/v1/chatbot/health` returns 200.

**C10 — Missing packages:**
- Build check: run `flutter pub get` on unfixed `pubspec.yaml`. Assert exit code non-zero due to unresolved imports.

---

### Fix Checking

```
FOR ALL X WHERE isBugCondition_Cn(X) DO
  result := fixedFunction(X)
  ASSERT Property_n_holds(result)
END FOR
```

Concrete cases for each fix:

- **C1**: `get_user_id(user_with_uuid_id)` → returns UUID string, not raises. `process_chat(user_id="uuid-str", ...)` → returns `ChatResponse`.
- **C2**: Fresh dev DB after fix → `PRAGMA table_info(conversations)` returns columns.
- **C3**: Physical device, no saved URL → `BackendSetupPage` shown; after saving valid URL → subsequent `ApiConfig.baseUrl` returns saved URL.
- **C4**: After login, app restart → `accessToken != null`, user not redirected to login.
- **C5**: POST returns 422 → `AuthException("phone is invalid")` thrown immediately, no PUT issued.
- **C6**: `_load_model()` called with non-existent `ai_models_path` → `sys.path` unchanged, `_model_loaded = False`, no exception propagates.
- **C7**: 401 from predict → `Navigator.pushNamedAndRemoveUntil` to `/login` called.
- **C8**: `LLM_API_KEY = "AQ.invalid"` → `ChatbotService` initialises with `llm_service = None`, `process_chat` returns fallback response with HTTP 200.
- **C9**: `API_PREFIX = "/api/v2"` → `GET /api/v2/chatbot/health` returns 200.
- **C10**: `flutter pub get` on fixed yaml → exit 0, all packages resolved.

---

### Preservation Checking

```
FOR ALL X WHERE NOT isBugCondition_Cn(X) DO
  ASSERT originalFunction(X) = fixedFunction(X)
END FOR
```

Property-based tests using `hypothesis` (Python) and `flutter_test` (Dart):

- **C1 preservation**: Generate random non-UUID integer-like IDs (property: responses to auth/users/symptom-checker routes unchanged).
- **C2 preservation**: Generate `environment = "production"` startup contexts (property: `create_all` not called).
- **C3 preservation**: `kIsWeb = true` or saved URL present (property: `baseUrl` unchanged).
- **C4 preservation**: User was never logged in (property: `isLoggedIn() == false` after restart).
- **C5 preservation**: POST returns 201 (property: PUT never called, method succeeds).
- **C6 preservation**: `ai_models_path` exists (property: `sys.path` contains path, model loads).
- **C7 preservation**: Response is 200 (property: no navigation occurs, results displayed).
- **C8 preservation**: Valid LLM key, reachable service (property: AI-generated response returned).
- **C9 preservation**: `API_PREFIX = "/api/v1"` (property: chatbot accessible at `/api/v1/chatbot/*`).
- **C10 preservation**: Existing packages (`equatable`, `http`, `flutter_riverpod`) still resolve.

---

### Unit Tests

- C1: `test_get_user_id_returns_str_for_uuid_user` — mock `UserModel.id = "uuid-str"`, assert return type `str`.
- C2: `test_chatbot_tables_created_on_dev_startup` — async test with SQLite, assert table existence.
- C3: `test_network_config_saves_and_retrieves_url` — SharedPreferences mock, save URL, retrieve URL.
- C4: `test_token_persisted_to_secure_storage_on_login` — mock `FlutterSecureStorage`, assert write called.
- C5: `test_complete_profile_422_throws_immediately` — mock POST 422, assert `AuthException` thrown, PUT not called.
- C6: `test_sys_path_not_mutated_when_ai_models_missing` — patch `Path.exists()` to `False`, assert `sys.path` unchanged after `_load_model()`.
- C7: `test_symptom_checker_401_navigates_to_login` — widget test, stub 401, assert `Navigator` called.
- C8: `test_process_chat_returns_fallback_when_llm_none` — set `llm_service = None`, assert fallback text in response.
- C9: `test_chatbot_router_prefix_follows_api_prefix` — create app with custom prefix, assert chatbot endpoint accessible.
- C10: N/A (build-time check).

### Property-Based Tests

- `test_any_uuid_user_id_passes_through_get_user_id` — `@given(st.uuids())` — assert no `ValueError`.
- `test_process_chat_always_returns_200_when_llm_unavailable` — `@given(chat_request_strategy())` — assert HTTP 200 and non-empty message.
- `test_complete_profile_never_calls_put_on_201` — `@given(profile_payload_strategy())` — mock POST 201, assert PUT call count == 0.
- `test_chatbot_endpoint_accessible_for_any_api_prefix` — `@given(st.text(...))` for prefix strings — assert GET `{prefix}/chatbot/health` returns 200.

### Integration Tests

- Full chatbot request flow with valid UUID user → login → send message → verify `ChatResponse` received.
- First-launch physical device simulation → splash tries connection → fails → `BackendSetupPage` shown → URL saved → subsequent launch skips setup.
- `completeProfile` with valid payload end-to-end → user profile updated in DB, `UserEntity` returned with `isProfileComplete: true`.
- Symptom checker with expired token → 401 → login redirect in Flutter integration test.

