# Bugfix Requirements Document

## Introduction

The AI Healthcare Assistant app (Flutter mobile + FastAPI backend) has multiple bugs across four modules — Authentication, User Management, Symptom Checker, and Medical Chatbot — that collectively prevent the app from working on a physical device after installation and cause runtime crashes or silent failures during normal use. This document captures the defective behaviors, the required correct behaviors, and the existing behaviors that must not regress.

The fix scope covers:
- Backend Python (FastAPI, SQLAlchemy, startup, dependencies)
- Flutter Dart (pubspec.yaml, api_config.dart, authentication_repository_impl.dart)
- App-wide UI package availability and network configuration

---

## Bug Analysis

### Current Behavior (Defect)

**Module 1 — Authentication**

1.1 WHEN a user sends any chatbot request and `UserModel.id` is a UUID string (e.g. `"a1b2c3d4-..."`) THEN the system crashes with `ValueError: invalid literal for int() with base 10` because `get_current_user` in `backend/app/medical_chatbot/api/dependencies.py` casts `user.id` to `int` and `get_user_id` returns type `int`

1.2 WHEN the backend starts for the first time in a development environment THEN the system fails to create the `conversations`, `messages`, `chatbot_feedback`, and `chatbot_sessions` tables because `backend/app/core/startup.py` does not import `app.medical_chatbot.database.models` in the auto-create block

1.3 WHEN a user installs the app on a physical device and opens it on any network other than the developer's original LAN THEN the system cannot connect to the backend because `mobile_app/lib/config/api_config.dart` hardcodes the IP `192.168.18.26` with no mechanism to change it after installation without recompiling

1.4 WHEN a user closes and reopens the Flutter app after a successful login THEN the system logs the user out because `AuthenticationRepositoryImpl` stores `_accessToken` and `_refreshToken` only in memory and `shared_preferences`/`flutter_secure_storage` are not listed in `mobile_app/pubspec.yaml`

**Module 2 — User Management**

1.5 WHEN the Flutter app calls `/api/v1/users/me` after login and reads `data['user_id']` from the response THEN the system maps correctly because `UserSummary` does export `user_id`; however the `_mapUserFromSummary` in `authentication_repository_impl.dart` also reads `data['user_id']` which does match — this means the field name alignment is correct but must not be changed

1.6 WHEN the Flutter `completeProfile` method sends a POST to `/api/v1/users/profile` and the endpoint returns a 422 validation error THEN the system silently retries with PUT, discards the original 422 error, and throws only the PUT response error, making the root cause undiagnosable to the user or developer

**Module 3 — Symptom Checker**

1.7 WHEN the backend server is started from the `backend/` working directory THEN the system may fail to locate the `ai_models` package because `backend/app/symptom_checker/service.py` computes the path as `Path(__file__).parent.parent.parent.parent / "ai_models"` which traverses four parent levels — if the file is at `backend/app/symptom_checker/service.py`, four parents gives the project root, which is correct; however the path is computed at module-import time via `sys.path.insert`, meaning any import ordering issue can cause `ImportError` at server start before the path is resolved

1.8 WHEN the Flutter symptom checker page calls `/api/v1/symptom-checker/predict` without a valid JWT token (unauthenticated user or expired token) THEN the system returns HTTP 401 but the Flutter symptom checker page crashes or shows an unhandled error instead of prompting the user to log in

**Module 4 — Medical Chatbot**

1.9 WHEN a user sends any chatbot message and the Gemini API is called with the configured key  (which is not a valid Google AI Studio key — valid keys start with `AIza`) THEN the system returns a 500 error to the user with no human-readable explanation, instead of gracefully degrading to a rule-based fallback response

1.10 WHEN the chatbot router is registered in `backend/app/main.py` via `app.include_router(chatbot_router)` without a prefix, while `backend/app/medical_chatbot/api/routes.py` already sets `prefix="/api/v1/chatbot"` THEN the system exposes the chatbot at `/api/v1/chatbot/*` — the Flutter app's calls succeed accidentally, but this is architecturally inconsistent with all other routers that receive their prefix from `settings.api_prefix`, creating a maintenance risk where changing `API_PREFIX` in `.env` breaks all other routers but not the chatbot

**UI & Packages**

1.11 WHEN `flutter pub get` is run on `mobile_app/pubspec.yaml` THEN the system only resolves `equatable`, `http`, and `flutter_riverpod` — packages required by existing feature code (`google_fonts`, `cached_network_image`, `shimmer`, `lottie`, `shared_preferences`, `flutter_secure_storage`) are absent, causing compile-time import errors in files that reference them

---

### Expected Behavior (Correct)

**Module 1 — Authentication**

2.1 WHEN a user sends any chatbot request and `UserModel.id` is a UUID string THEN the system SHALL pass the UUID string as-is through `get_current_user` and `get_user_id` (return type `str`), and `ChatbotService.process_chat` SHALL accept `user_id: str`, eliminating the `ValueError` crash

2.2 WHEN the backend starts for the first time in a development environment THEN the system SHALL import `app.medical_chatbot.database.models` in `on_startup` before calling `Base.metadata.create_all`, so that `conversations`, `messages`, `chatbot_feedback`, and `chatbot_sessions` tables are created automatically

2.3 WHEN a user installs the app on a physical device and opens it for the first time on any network THEN the system SHALL display a backend setup screen that allows the user to enter or confirm the backend URL, tests connectivity, and persists the URL with `shared_preferences` so subsequent launches use the saved URL without requiring USB or recompilation

2.4 WHEN a user closes and reopens the Flutter app after a successful login THEN the system SHALL restore the access token and refresh token from `flutter_secure_storage` so the user remains authenticated across app restarts

**Module 2 — User Management**

2.5 WHEN the Flutter `completeProfile` method sends a POST to `/api/v1/users/profile` and receives a 422 validation error THEN the system SHALL immediately surface the original 422 error message to the user without silently retrying with a PUT, so the developer and user see the actual cause of the failure

**Module 3 — Symptom Checker**

2.6 WHEN the backend server starts THEN the system SHALL resolve the `ai_models` path safely regardless of the working directory, using an absolute path anchored to the source file's location, and SHALL only insert the path after confirming the directory exists

2.7 WHEN the Flutter symptom checker page calls `/predict` and receives HTTP 401 THEN the system SHALL navigate the user to the login page with a clear message ("Please log in to use the Symptom Checker") instead of crashing or showing an unhandled error

**Module 4 — Medical Chatbot**

2.8 WHEN a user sends a chatbot message and the LLM API call fails for any reason (invalid key, network error, quota exceeded) THEN the system SHALL return a graceful rule-based fallback response with HTTP 200, and SHALL log the LLM error server-side, so the user sees a helpful message rather than a 500 error

2.9 WHEN the chatbot router is registered in `main.py` THEN the system SHALL use the same prefix pattern as all other routers (`prefix=settings.api_prefix`) and the chatbot router in `routes.py` SHALL use only the sub-path `/chatbot`, so that changing `API_PREFIX` in `.env` consistently affects all routers including the chatbot

**UI & Packages**

2.10 WHEN `flutter pub get` is run on `mobile_app/pubspec.yaml` THEN the system SHALL resolve all packages required by existing feature code, including `google_fonts: ^6.2.1`, `cached_network_image: ^3.4.1`, `shimmer: ^3.0.0`, `lottie: ^3.1.2`, `shared_preferences: ^2.3.2`, and `flutter_secure_storage: ^9.2.2`

---

### Unchanged Behavior (Regression Prevention)

3.1 WHEN a user authenticates with a valid email and password THEN the system SHALL CONTINUE TO issue a JWT access token and refresh token and return them in the login response

3.2 WHEN a user registers a new account THEN the system SHALL CONTINUE TO create the account, auto-login, and return a `UserEntity` to the Flutter app

3.3 WHEN the backend starts and the symptom checker model is present with the correct 230 features THEN the system SHALL CONTINUE TO load the model successfully and log a confirmation message

3.4 WHEN a user calls `/api/v1/symptom-checker/symptoms` or `/api/v1/symptom-checker/diseases` without authentication THEN the system SHALL CONTINUE TO return the symptom and disease lists without requiring a JWT token (these endpoints have no auth dependency)

3.5 WHEN a user sends a chatbot message with a valid JWT and a working LLM API key THEN the system SHALL CONTINUE TO return an AI-generated response through the existing `ChatbotService` pipeline

3.6 WHEN the Flutter app is run on an Android emulator THEN the system SHALL CONTINUE TO use `10.0.2.2` as the backend host

3.7 WHEN the Flutter `completeProfile` method sends a valid POST to `/api/v1/users/profile` and receives HTTP 201 THEN the system SHALL CONTINUE TO succeed without attempting the PUT fallback

3.8 WHEN any authenticated user calls `/api/v1/users/me` THEN the system SHALL CONTINUE TO return a `UserSummary` object with `user_id` as the identifier field

3.9 WHEN the backend is started in a `production` or `staging` environment THEN the system SHALL CONTINUE TO skip the dev auto-create block and not run `Base.metadata.create_all`

3.10 WHEN the Flutter app is launched and the backend URL has already been saved in `shared_preferences` THEN the system SHALL CONTINUE TO skip the backend setup screen and go directly to the normal splash/auth flow

---

## Bug Condition Derivations

### Bug Condition C1 — UUID-to-int cast (Bug 1.1 / Fix 2.1)

```pascal
FUNCTION isBugCondition_C1(X)
  INPUT: X of type AuthenticatedChatRequest
  OUTPUT: boolean
  // Bug fires whenever UserModel.id is a UUID string (always true in this schema)
  RETURN typeof(X.user.id) = STRING AND NOT isInteger(X.user.id)
END FUNCTION

// Fix Checking
FOR ALL X WHERE isBugCondition_C1(X) DO
  result ← processChatRequest'(X)
  ASSERT no_ValueError(result) AND result.status IN {200, 400, 429}
END FOR

// Preservation Checking
FOR ALL X WHERE NOT isBugCondition_C1(X) DO
  ASSERT processChatRequest(X) = processChatRequest'(X)
END FOR
```

### Bug Condition C2 — Missing model import at startup (Bug 1.2 / Fix 2.2)

```pascal
FUNCTION isBugCondition_C2(X)
  INPUT: X of type ServerStartupContext
  OUTPUT: boolean
  RETURN X.environment IN {"development", "test"} AND
         "app.medical_chatbot.database.models" NOT IN X.importedModules
END FUNCTION

FOR ALL X WHERE isBugCondition_C2(X) DO
  result ← on_startup'(X)
  ASSERT tablesExist(result, ["conversations", "messages", "chatbot_feedback", "chatbot_sessions"])
END FOR
```

### Bug Condition C3 — Hardcoded IP (Bug 1.3 / Fix 2.3)

```pascal
FUNCTION isBugCondition_C3(X)
  INPUT: X of type AppLaunchContext
  OUTPUT: boolean
  RETURN X.isPhysicalDevice AND X.networkSSID != "developer_home_network"
END FUNCTION

FOR ALL X WHERE isBugCondition_C3(X) DO
  result ← getBackendUrl'(X)
  ASSERT result != "http://192.168.18.26:8000" AND isReachable(result)
END FOR
```

### Bug Condition C4 — LLM auth failure with no fallback (Bug 1.9 / Fix 2.8)

```pascal
FUNCTION isBugCondition_C4(X)
  INPUT: X of type ChatRequest
  OUTPUT: boolean
  RETURN X.llmApiKeyValid = FALSE OR X.llmServiceReachable = FALSE
END FUNCTION

FOR ALL X WHERE isBugCondition_C4(X) DO
  result ← chat'(X)
  ASSERT result.statusCode = 200 AND result.body.message != NULL AND
         result.body.message CONTAINS "fallback"
END FOR
```
