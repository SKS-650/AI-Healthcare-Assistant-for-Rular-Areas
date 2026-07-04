"""
Integration tests for Module 1: Authentication

Tests cover the complete flows:
  Registration → Email Verify → Login → Refresh → Logout → Password Reset
"""

from __future__ import annotations

import pytest
from httpx import AsyncClient

pytestmark = pytest.mark.asyncio

BASE = "/api/v1/auth"

# ─── Payloads ─────────────────────────────────────────────────────────────────

GOOD_USER = {
    "full_name": "Ramesh Sharma",
    "email": "ramesh@example.com",
    "phone": "+919876543210",
    "password": "SecurePass@123",
    "confirm_password": "SecurePass@123",
    "role": "patient",
    "language": "en",
}


# ─── Registration ─────────────────────────────────────────────────────────────


async def test_register_success(client: AsyncClient):
    r = await client.post(f"{BASE}/register", json=GOOD_USER)
    assert r.status_code == 201
    body = r.json()
    assert body["email"] == GOOD_USER["email"]
    assert "user_id" in body


async def test_register_duplicate_email(client: AsyncClient):
    await client.post(f"{BASE}/register", json=GOOD_USER)
    r = await client.post(f"{BASE}/register", json=GOOD_USER)
    assert r.status_code == 409


async def test_register_password_mismatch(client: AsyncClient):
    payload = {**GOOD_USER, "email": "other@example.com", "confirm_password": "Wrong@123"}
    r = await client.post(f"{BASE}/register", json=payload)
    assert r.status_code == 422


async def test_register_weak_password(client: AsyncClient):
    payload = {
        **GOOD_USER,
        "email": "weak@example.com",
        "password": "short",
        "confirm_password": "short",
    }
    r = await client.post(f"{BASE}/register", json=payload)
    assert r.status_code == 422


async def test_register_invalid_phone(client: AsyncClient):
    payload = {**GOOD_USER, "email": "phone@example.com", "phone": "123"}
    r = await client.post(f"{BASE}/register", json=payload)
    assert r.status_code == 422


# ─── Login (before verification) ─────────────────────────────────────────────


async def test_login_before_email_verify(client: AsyncClient, db_session):
    await client.post(f"{BASE}/register", json=GOOD_USER)
    r = await client.post(
        f"{BASE}/login",
        json={"email": GOOD_USER["email"], "password": GOOD_USER["password"]},
    )
    # Email not verified → 403
    assert r.status_code == 403


# ─── Email Verification & Login ───────────────────────────────────────────────


async def _register_and_verify(client: AsyncClient, db_session, email: str = GOOD_USER["email"]):
    """Helper: register + manually set email_verified."""
    payload = {**GOOD_USER, "email": email}
    r = await client.post(f"{BASE}/register", json=payload)
    assert r.status_code == 201
    user_id = r.json()["user_id"]

    from backend.app.auth import repository as auth_repo
    await auth_repo.set_email_verified(db_session, user_id)
    await db_session.commit()
    return user_id


async def test_login_success(client: AsyncClient, db_session):
    await _register_and_verify(client, db_session, "login@example.com")
    r = await client.post(
        f"{BASE}/login",
        json={"email": "login@example.com", "password": GOOD_USER["password"]},
    )
    assert r.status_code == 200
    body = r.json()
    assert "tokens" in body
    assert body["tokens"]["access_token"]
    assert body["tokens"]["refresh_token"]
    assert body["role"] == "patient"


async def test_login_wrong_password(client: AsyncClient, db_session):
    await _register_and_verify(client, db_session, "wrongpw@example.com")
    r = await client.post(
        f"{BASE}/login",
        json={"email": "wrongpw@example.com", "password": "BadPass@999"},
    )
    assert r.status_code == 401


async def test_login_unknown_email(client: AsyncClient):
    r = await client.post(
        f"{BASE}/login",
        json={"email": "nobody@example.com", "password": "SecurePass@123"},
    )
    assert r.status_code == 401


# ─── Token Refresh ────────────────────────────────────────────────────────────


async def test_refresh_token(client: AsyncClient, db_session):
    await _register_and_verify(client, db_session, "refresh@example.com")
    login = await client.post(
        f"{BASE}/login",
        json={"email": "refresh@example.com", "password": GOOD_USER["password"]},
    )
    refresh_token = login.json()["tokens"]["refresh_token"]

    r = await client.post(f"{BASE}/refresh", json={"refresh_token": refresh_token})
    assert r.status_code == 200
    assert r.json()["access_token"]


async def test_refresh_invalid_token(client: AsyncClient):
    r = await client.post(f"{BASE}/refresh", json={"refresh_token": "bad.token.here"})
    assert r.status_code == 401


# ─── /me endpoint ────────────────────────────────────────────────────────────


async def test_get_me(client: AsyncClient, db_session):
    await _register_and_verify(client, db_session, "me@example.com")
    login = await client.post(
        f"{BASE}/login",
        json={"email": "me@example.com", "password": GOOD_USER["password"]},
    )
    access = login.json()["tokens"]["access_token"]

    r = await client.get(f"{BASE}/me", headers={"Authorization": f"Bearer {access}"})
    assert r.status_code == 200
    assert r.json()["email"] == "me@example.com"


async def test_get_me_no_token(client: AsyncClient):
    r = await client.get(f"{BASE}/me")
    assert r.status_code == 401


# ─── Logout ───────────────────────────────────────────────────────────────────


async def test_logout(client: AsyncClient, db_session):
    await _register_and_verify(client, db_session, "logout@example.com")
    login = await client.post(
        f"{BASE}/login",
        json={"email": "logout@example.com", "password": GOOD_USER["password"]},
    )
    tokens = login.json()["tokens"]

    r = await client.post(
        f"{BASE}/logout", json={"refresh_token": tokens["refresh_token"]}
    )
    assert r.status_code == 200

    # Refresh should now fail
    r2 = await client.post(
        f"{BASE}/refresh", json={"refresh_token": tokens["refresh_token"]}
    )
    assert r2.status_code == 401


# ─── Password Reset ───────────────────────────────────────────────────────────


async def test_forgot_password_always_200(client: AsyncClient):
    """Should return 200 even for unknown emails (anti-enumeration)."""
    r = await client.post(
        f"{BASE}/forgot-password", json={"email": "nobody@example.com"}
    )
    assert r.status_code == 200


async def test_reset_password_invalid_token(client: AsyncClient):
    r = await client.post(
        f"{BASE}/reset-password",
        json={
            "token": "invalidtoken",
            "new_password": "NewPass@456",
            "confirm_password": "NewPass@456",
        },
    )
    assert r.status_code == 400


# ─── Session management ───────────────────────────────────────────────────────


async def test_list_sessions(client: AsyncClient, db_session):
    await _register_and_verify(client, db_session, "sessions@example.com")
    login = await client.post(
        f"{BASE}/login",
        json={"email": "sessions@example.com", "password": GOOD_USER["password"]},
    )
    access = login.json()["tokens"]["access_token"]

    r = await client.get(
        f"{BASE}/sessions", headers={"Authorization": f"Bearer {access}"}
    )
    assert r.status_code == 200
    assert isinstance(r.json()["sessions"], list)
    assert len(r.json()["sessions"]) >= 1
