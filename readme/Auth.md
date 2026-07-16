## Authentication (Auth) — Detailed Implementation

**Purpose & scope**

The authentication module implements secure user authentication and authorization for the backend and mobile clients. It provides credential-based login, JWT access token issuance, refresh token rotation, role-based access control, and helper dependencies used throughout the app (e.g., `get_current_user`). The implementation is intentionally minimal and pragmatic for a student project but follows common production patterns.

Files of interest

- `backend/app/auth/` — models, schemas, utilities for auth entities
- `backend/app/authentication/` — login, token creation, dependencies
- `backend/app/api/` — routes that include auth endpoints and use auth dependencies

---

1) Background & theory

Token-based authentication (JWT) is used because it is stateless at the API layer and straightforward to integrate with mobile clients. A JSON Web Token (JWT) is a compact, URL-safe string composed of three base64url-encoded parts: header, payload (claims), and signature:

$$
JWT = \mathrm{base64url}(header) . \mathrm{base64url}(payload) . \mathrm{base64url}(signature)
$$

Typical claims used in this project

- `sub` (subject): user id (UUID)
- `exp`: expiration timestamp
- `iat`: issued-at timestamp
- `roles`: list of user roles (e.g., `admin`, `user`)

Signature is computed with an HMAC or RSA/EC key; in this project the signing algorithm is configured via environment variables (see `backend/.env` or project env configuration). On each request the backend validates the signature and checks the `exp` claim.

Refresh tokens

- Access tokens are short-lived (e.g., 15 minutes). Refresh tokens are long-lived (e.g., 7-30 days) and allow the client to obtain a new access token without re-entering credentials.
- Refresh token rotation: on token refresh, the old refresh token is invalidated and a new refresh token is issued to reduce replay risk.

---

2) How authentication works in this project (concrete flow)

- Login flow (credential-based):

	1. Client sends `POST /api/v1/auth/login` with username/password.
	2. Backend authenticates against `users` table (passwords hashed with a secure algorithm like bcrypt).
	3. On success, backend issues an access token (JWT) and a refresh token (opaque token stored hashed in DB or issued as JWT with longer expiry).
	4. Client stores tokens: access in memory (or short-lived storage), refresh in secure storage (mobile: `flutter_secure_storage`).

- Token refresh flow:

	1. Client calls `POST /api/v1/auth/refresh` with refresh token.
	2. Backend verifies the refresh token, invalidates it (rotation), and issues a new access token + refresh token pair.

- Logout flow:

	1. Client calls `POST /api/v1/auth/logout` (if implemented) with refresh token.
	2. Backend removes the refresh token and revokes session.

Concrete files and functions

- `backend/app/authentication/token.py` (or similarly named) contains token creation and verification helpers.
- `backend/app/auth/models.py` defines the `User` model, password hashing utilities, and role fields.
- `backend/app/authentication/dependencies.py` defines `get_current_user` and `get_user_id` used as FastAPI dependencies.

Known project bug to be aware of

- The repo contains a documented issue (C1) where `get_current_user` cast user IDs to `int`, causing crashes if `User.id` is a UUID string. See `.kiro/specs/ai-healthcare-full-fix/bugfix.md` for details. Ensure `get_current_user` returns the same type used across models (prefer UUID strings).

---

3) API contracts & examples

- `POST /api/v1/auth/login`

Request

```json
{
	"username": "alice",
	"password": "secret"
}
```

Response

```json
{
	"access_token": "eyJhbGci...",
	"refresh_token": "rft_<opaque_token>",
	"token_type": "bearer",
	"expires_in": 900
}
```

- `POST /api/v1/auth/refresh` — exchange refresh token for new pair.
- Protected endpoint example: `GET /api/v1/users/me` requires `Authorization: Bearer <access_token>`; uses dependency `get_current_user` which extracts the user claims and fetches the user record.

---

4) Role-based access control (RBAC)

- The `roles` claim in JWT indicates privileges. Admin routes (admin dashboard APIs) check for `admin` role and optionally a separate permission set.
- Role checks are implemented as small dependency functions that raise `HTTPException(status_code=403)` on missing permissions.

---

5) Security considerations & hardening (project-specific recommendations)

- Password hashing: use `bcrypt` or `argon2` with appropriate cost factor; never store plaintext.
- Transport: always serve API over TLS in production.
- Store secrets out of repo: signing keys, database passwords, and LLM API keys should be pulled from environment variables or secret manager.
- Refresh token storage: on mobile, store in `flutter_secure_storage` (not shared_preferences). On the server, store hashed refresh tokens to allow revocation.
- Rate limiting: protect login endpoints with rate limiting and lockout policies to mitigate brute-force attempts.

Example of access token validation pseudo-code

```python
from jose import jwt

def verify_token(token):
		payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGO])
		if payload['exp'] < now_timestamp():
				raise Unauthorized
		return payload
```

---

6) How other modules use auth

- Symptom Checker, Chatbot, Backend services: all depend on the `get_current_user` dependency to obtain `user_id` and roles.
- Mobile app: must manage token lifecycle (store refresh token securely, refresh access tokens before expiry, and clear tokens on logout). See `mobile_app/lib/authentication_repository_impl.dart` for mobile-side logic (noting the repo's earlier bug where tokens were only stored in memory).
- Admin Dashboard: requires admin JWT claims; UI should request elevated permissions and show admin-only controls when role present.

---

7) Testing & validation

- Unit tests: token creation and verification functions, password hashing, and RBAC decorators.
- Integration tests: login + refresh workflows; protected endpoint access with and without valid tokens.

---

8) Troubleshooting common issues in this repo

- Mismatched ID types: ensure that `User.id` type (UUID vs int) is consistent across models and token claims — a recent bug caused runtime cast errors when UUIDs were cast to `int`.
- Missing tokens on mobile: ensure the mobile app stores refresh tokens in secure storage and reads them on startup.

---

9) Glossary (auth-specific terms)

- JWT (JSON Web Token): compact token with header.payload.signature
- Access token: short-lived token used for API calls
- Refresh token: long-lived token used to obtain new access tokens
- RBAC: Role-Based Access Control

---

10) References & file links

- Authentication implementation: [backend/app/auth](backend/app/auth#L1)
- Token helpers & dependencies: [backend/app/authentication](backend/app/authentication#L1)

**Glossary:**

- JWT: JSON Web Token. Signed token with claims.
- Access token: short-lived token for API access.
- Refresh token: longer-lived token to obtain new access tokens.
