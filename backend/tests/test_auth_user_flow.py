import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_register_login_and_get_me_flow(client: AsyncClient) -> None:
    payload = {
        "full_name": "Flutter Tester",
        "email": "flutter.tester@example.com",
        "phone": "+919876543210",
        "password": "SecurePass@123",
        "confirm_password": "SecurePass@123",
        "role": "patient",
        "language": "en",
    }

    register_response = await client.post("/api/v1/auth/register", json=payload)
    assert register_response.status_code == 201, register_response.text
    register_data = register_response.json()
    assert register_data["user_id"]

    login_response = await client.post(
        "/api/v1/auth/login",
        json={
            "email": payload["email"],
            "password": payload["password"],
            "device_info": "pytest",
        },
    )
    assert login_response.status_code == 200, login_response.text
    login_data = login_response.json()
    assert login_data["tokens"]["access_token"]

    me_response = await client.get(
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {login_data['tokens']['access_token']}"},
    )
    assert me_response.status_code == 200, me_response.text
    me_data = me_response.json()
    assert me_data["email"] == payload["email"]
