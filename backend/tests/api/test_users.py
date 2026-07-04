"""
Integration tests for Module 2: User Management

Covers: profile, addresses, emergency contacts, medical info,
account status, and permission boundaries.
"""

from __future__ import annotations

import pytest
from httpx import AsyncClient

pytestmark = pytest.mark.asyncio

AUTH_BASE = "/api/v1/auth"
USER_BASE = "/api/v1/users"

GOOD_USER = {
    "full_name": "Sunita Thapa",
    "email": "sunita@example.com",
    "phone": "+977980000001",
    "password": "SecurePass@123",
    "confirm_password": "SecurePass@123",
    "role": "patient",
    "language": "en",
}

ADMIN_USER = {
    "full_name": "Admin User",
    "email": "admin@example.com",
    "phone": "+977980000002",
    "password": "AdminPass@123",
    "confirm_password": "AdminPass@123",
    "role": "admin",
    "language": "en",
}


# ─── Fixtures ─────────────────────────────────────────────────────────────────


async def _create_and_login(
    client: AsyncClient, db_session, payload: dict
) -> tuple[str, str, str]:
    """Register + verify + login. Returns (access_token, refresh_token, user_id)."""
    r = await client.post(f"{AUTH_BASE}/register", json=payload)
    assert r.status_code == 201, r.text
    user_id = r.json()["user_id"]

    from backend.app.auth import repository as auth_repo
    await auth_repo.set_email_verified(db_session, user_id)
    await db_session.commit()

    login = await client.post(
        f"{AUTH_BASE}/login",
        json={"email": payload["email"], "password": payload["password"]},
    )
    assert login.status_code == 200, login.text
    tokens = login.json()["tokens"]
    return tokens["access_token"], tokens["refresh_token"], user_id


# ─── Account ──────────────────────────────────────────────────────────────────


async def test_get_me(client: AsyncClient, db_session):
    access, _, _ = await _create_and_login(client, db_session, GOOD_USER)
    r = await client.get(f"{USER_BASE}/me", headers={"Authorization": f"Bearer {access}"})
    assert r.status_code == 200
    assert r.json()["email"] == GOOD_USER["email"]
    assert r.json()["role"] == "patient"


async def test_update_me(client: AsyncClient, db_session):
    access, _, _ = await _create_and_login(
        client, db_session, {**GOOD_USER, "email": "update@example.com", "phone": "+977980000010"}
    )
    r = await client.put(
        f"{USER_BASE}/me",
        json={"full_name": "Sunita Thapa Updated"},
        headers={"Authorization": f"Bearer {access}"},
    )
    assert r.status_code == 200
    assert r.json()["full_name"] == "Sunita Thapa Updated"


async def test_update_me_invalid_language(client: AsyncClient, db_session):
    access, _, _ = await _create_and_login(
        client, db_session, {**GOOD_USER, "email": "lang@example.com", "phone": "+977980000011"}
    )
    r = await client.put(
        f"{USER_BASE}/me",
        json={"preferred_language": "klingon"},
        headers={"Authorization": f"Bearer {access}"},
    )
    assert r.status_code in (400, 422)


# ─── Profile ──────────────────────────────────────────────────────────────────


async def test_create_profile(client: AsyncClient, db_session):
    access, _, _ = await _create_and_login(
        client, db_session, {**GOOD_USER, "email": "prof@example.com", "phone": "+977980000020"}
    )
    r = await client.post(
        f"{USER_BASE}/profile",
        json={
            "date_of_birth": "1995-06-15",
            "gender": "female",
            "blood_group": "B+",
            "height_cm": 160,
            "weight_kg": 55,
            "occupation": "Nurse",
            "marital_status": "single",
        },
        headers={"Authorization": f"Bearer {access}"},
    )
    assert r.status_code == 201
    body = r.json()
    assert body["gender"] == "female"
    assert body["blood_group"] == "B+"


async def test_create_profile_duplicate(client: AsyncClient, db_session):
    access, _, _ = await _create_and_login(
        client, db_session, {**GOOD_USER, "email": "dupprof@example.com", "phone": "+977980000021"}
    )
    payload = {"date_of_birth": "1990-01-01", "gender": "female"}
    await client.post(
        f"{USER_BASE}/profile", json=payload, headers={"Authorization": f"Bearer {access}"}
    )
    r = await client.post(
        f"{USER_BASE}/profile", json=payload, headers={"Authorization": f"Bearer {access}"}
    )
    assert r.status_code == 409


async def test_create_profile_future_dob(client: AsyncClient, db_session):
    access, _, _ = await _create_and_login(
        client, db_session, {**GOOD_USER, "email": "futuredob@example.com", "phone": "+977980000022"}
    )
    r = await client.post(
        f"{USER_BASE}/profile",
        json={"date_of_birth": "2099-01-01"},
        headers={"Authorization": f"Bearer {access}"},
    )
    assert r.status_code == 422


async def test_update_profile(client: AsyncClient, db_session):
    access, _, _ = await _create_and_login(
        client, db_session, {**GOOD_USER, "email": "updprof@example.com", "phone": "+977980000023"}
    )
    await client.post(
        f"{USER_BASE}/profile",
        json={"gender": "female", "height_cm": 160},
        headers={"Authorization": f"Bearer {access}"},
    )
    r = await client.put(
        f"{USER_BASE}/profile",
        json={"weight_kg": 58, "occupation": "Doctor"},
        headers={"Authorization": f"Bearer {access}"},
    )
    assert r.status_code == 200
    assert r.json()["occupation"] == "Doctor"


async def test_invalid_blood_group(client: AsyncClient, db_session):
    access, _, _ = await _create_and_login(
        client, db_session, {**GOOD_USER, "email": "bg@example.com", "phone": "+977980000024"}
    )
    r = await client.post(
        f"{USER_BASE}/profile",
        json={"blood_group": "X+"},
        headers={"Authorization": f"Bearer {access}"},
    )
    assert r.status_code == 422


# ─── Addresses ────────────────────────────────────────────────────────────────


async def test_add_address(client: AsyncClient, db_session):
    access, _, _ = await _create_and_login(
        client, db_session, {**GOOD_USER, "email": "addr@example.com", "phone": "+977980000030"}
    )
    r = await client.post(
        f"{USER_BASE}/address",
        json={
            "address_type": "home",
            "country": "Nepal",
            "district": "Kathmandu",
            "municipality": "KMC",
            "ward_number": "10",
            "is_primary": True,
        },
        headers={"Authorization": f"Bearer {access}"},
    )
    assert r.status_code == 201
    assert r.json()["is_primary"] is True


async def test_get_addresses(client: AsyncClient, db_session):
    access, _, _ = await _create_and_login(
        client, db_session, {**GOOD_USER, "email": "getaddr@example.com", "phone": "+977980000031"}
    )
    await client.post(
        f"{USER_BASE}/address",
        json={"address_type": "home", "country": "Nepal"},
        headers={"Authorization": f"Bearer {access}"},
    )
    r = await client.get(
        f"{USER_BASE}/address", headers={"Authorization": f"Bearer {access}"}
    )
    assert r.status_code == 200
    assert r.json()["total"] == 1


async def test_update_address(client: AsyncClient, db_session):
    access, _, _ = await _create_and_login(
        client, db_session, {**GOOD_USER, "email": "updaddr@example.com", "phone": "+977980000032"}
    )
    create = await client.post(
        f"{USER_BASE}/address",
        json={"address_type": "home", "country": "Nepal"},
        headers={"Authorization": f"Bearer {access}"},
    )
    addr_id = create.json()["address_id"]

    r = await client.put(
        f"{USER_BASE}/address/{addr_id}",
        json={"address_type": "work", "country": "Nepal", "district": "Lalitpur"},
        headers={"Authorization": f"Bearer {access}"},
    )
    assert r.status_code == 200
    assert r.json()["district"] == "Lalitpur"


async def test_delete_address(client: AsyncClient, db_session):
    access, _, _ = await _create_and_login(
        client, db_session, {**GOOD_USER, "email": "deladdr@example.com", "phone": "+977980000033"}
    )
    create = await client.post(
        f"{USER_BASE}/address",
        json={"address_type": "home"},
        headers={"Authorization": f"Bearer {access}"},
    )
    addr_id = create.json()["address_id"]

    r = await client.delete(
        f"{USER_BASE}/address/{addr_id}",
        headers={"Authorization": f"Bearer {access}"},
    )
    assert r.status_code == 200


async def test_address_invalid_coordinates(client: AsyncClient, db_session):
    access, _, _ = await _create_and_login(
        client, db_session, {**GOOD_USER, "email": "coords@example.com", "phone": "+977980000034"}
    )
    r = await client.post(
        f"{USER_BASE}/address",
        json={"address_type": "home", "latitude": 200},  # out of range, no longitude
        headers={"Authorization": f"Bearer {access}"},
    )
    assert r.status_code == 422


# ─── Emergency Contacts ───────────────────────────────────────────────────────


async def test_add_emergency_contact(client: AsyncClient, db_session):
    access, _, _ = await _create_and_login(
        client, db_session, {**GOOD_USER, "email": "ec@example.com", "phone": "+977980000040"}
    )
    r = await client.post(
        f"{USER_BASE}/emergency-contact",
        json={
            "contact_name": "Ram Sharma",
            "relationship": "father",
            "phone": "+919876543000",
            "priority": 1,
        },
        headers={"Authorization": f"Bearer {access}"},
    )
    assert r.status_code == 201
    assert r.json()["relationship"] == "father"


async def test_get_emergency_contacts(client: AsyncClient, db_session):
    access, _, _ = await _create_and_login(
        client, db_session, {**GOOD_USER, "email": "getec@example.com", "phone": "+977980000041"}
    )
    await client.post(
        f"{USER_BASE}/emergency-contact",
        json={"contact_name": "Ram", "relationship": "father", "phone": "+919876543001"},
        headers={"Authorization": f"Bearer {access}"},
    )
    r = await client.get(
        f"{USER_BASE}/emergency-contact", headers={"Authorization": f"Bearer {access}"}
    )
    assert r.status_code == 200
    assert r.json()["total"] == 1


async def test_update_emergency_contact(client: AsyncClient, db_session):
    access, _, _ = await _create_and_login(
        client, db_session, {**GOOD_USER, "email": "updec@example.com", "phone": "+977980000042"}
    )
    create = await client.post(
        f"{USER_BASE}/emergency-contact",
        json={"contact_name": "Sita", "relationship": "mother", "phone": "+919876543002"},
        headers={"Authorization": f"Bearer {access}"},
    )
    cid = create.json()["contact_id"]

    r = await client.put(
        f"{USER_BASE}/emergency-contact/{cid}",
        json={"contact_name": "Sita Devi"},
        headers={"Authorization": f"Bearer {access}"},
    )
    assert r.status_code == 200
    assert r.json()["contact_name"] == "Sita Devi"


# ─── Medical Information ──────────────────────────────────────────────────────


async def test_create_medical_info(client: AsyncClient, db_session):
    access, _, _ = await _create_and_login(
        client, db_session, {**GOOD_USER, "email": "med@example.com", "phone": "+977980000050"}
    )
    r = await client.post(
        f"{USER_BASE}/medical-info",
        json={
            "blood_group": "O+",
            "allergies": ["Penicillin", "Dust"],
            "chronic_diseases": ["Diabetes"],
            "current_medications": ["Metformin 500mg"],
            "smoking_status": False,
            "alcohol_consumption": False,
        },
        headers={"Authorization": f"Bearer {access}"},
    )
    assert r.status_code == 201
    body = r.json()
    assert body["blood_group"] == "O+"
    assert "Penicillin" in body["allergies"]


async def test_create_medical_info_duplicate(client: AsyncClient, db_session):
    access, _, _ = await _create_and_login(
        client, db_session, {**GOOD_USER, "email": "dupmed@example.com", "phone": "+977980000051"}
    )
    payload = {"blood_group": "A+"}
    await client.post(
        f"{USER_BASE}/medical-info", json=payload, headers={"Authorization": f"Bearer {access}"}
    )
    r = await client.post(
        f"{USER_BASE}/medical-info", json=payload, headers={"Authorization": f"Bearer {access}"}
    )
    assert r.status_code == 409


async def test_update_medical_info(client: AsyncClient, db_session):
    access, _, _ = await _create_and_login(
        client, db_session, {**GOOD_USER, "email": "updmed@example.com", "phone": "+977980000052"}
    )
    await client.post(
        f"{USER_BASE}/medical-info",
        json={"blood_group": "A+"},
        headers={"Authorization": f"Bearer {access}"},
    )
    r = await client.put(
        f"{USER_BASE}/medical-info",
        json={"blood_group": "AB+", "smoking_status": True},
        headers={"Authorization": f"Bearer {access}"},
    )
    assert r.status_code == 200
    assert r.json()["blood_group"] == "AB+"
    assert r.json()["smoking_status"] is True


# ─── Full user detail ─────────────────────────────────────────────────────────


async def test_full_user_detail(client: AsyncClient, db_session):
    access, _, user_id = await _create_and_login(
        client, db_session, {**GOOD_USER, "email": "full@example.com", "phone": "+977980000060"}
    )
    r = await client.get(
        f"{USER_BASE}/{user_id}", headers={"Authorization": f"Bearer {access}"}
    )
    assert r.status_code == 200
    body = r.json()
    assert "account" in body
    assert body["account"]["email"] == "full@example.com"


# ─── Permission boundary ──────────────────────────────────────────────────────


async def test_cannot_view_other_users_detail(client: AsyncClient, db_session):
    """A patient cannot view another user's full detail."""
    access1, _, _ = await _create_and_login(
        client, db_session, {**GOOD_USER, "email": "user1@example.com", "phone": "+977980000070"}
    )
    _, _, user2_id = await _create_and_login(
        client, db_session,
        {**GOOD_USER, "email": "user2@example.com", "phone": "+977980000071"},
    )
    r = await client.get(
        f"{USER_BASE}/{user2_id}", headers={"Authorization": f"Bearer {access1}"}
    )
    assert r.status_code == 403
