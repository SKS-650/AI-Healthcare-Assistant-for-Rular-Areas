"""backend/app/security/jwt.py

Minimal JWT (HS256) helpers implemented using the Python standard library.

Notes
-----
- This is intentionally dependency-free (no PyJWT).
- It is suitable for prototyping.
- For production-grade security, consider using a well-tested library.
"""

from __future__ import annotations

import base64
import hashlib
import hmac
import json
import time
from dataclasses import dataclass
from typing import Any, Dict, Optional


class JWTError(ValueError):
    """Base class for JWT-related errors."""


class JWTSecretError(JWTError):
    """Raised when a required JWT secret is missing."""


class JWTExpiredError(JWTError):
    """Raised when a token is expired."""


class JWTInvalidError(JWTError):
    """Raised when a token is malformed or signature is invalid.""" 


def _b64url_encode(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).decode("utf-8").rstrip("=")


def _b64url_decode(data: str) -> bytes:
    # Restore padding for urlsafe_b64decode
    padding = "=" * (-len(data) % 4)
    return base64.urlsafe_b64decode((data + padding).encode("utf-8"))


def _json_dumps(obj: Dict[str, Any]) -> bytes:
    return json.dumps(obj, separators=(",", ":"), sort_keys=True).encode("utf-8")


def _sign_hs256(secret: str, signing_input: str) -> str:
    mac = hmac.new(secret.encode("utf-8"), signing_input.encode("utf-8"), hashlib.sha256)
    return _b64url_encode(mac.digest())


@dataclass(frozen=True)
class JWTPayload:
    iss: Optional[str] = None
    sub: Optional[str] = None
    aud: Optional[str] = None
    jti: Optional[str] = None


def create_access_token(
    *,
    subject: str,
    secret: str,
    issuer: Optional[str] = None,
    audience: Optional[str] = None,
    expires_in_seconds: int = 15 * 60,
    additional_claims: Optional[Dict[str, Any]] = None,
) -> str:
    """Create a signed HS256 access token."""

    if not secret:
        raise JWTSecretError("JWT secret is required")

    now = int(time.time())
    exp = now + int(expires_in_seconds)

    header = {"alg": "HS256", "typ": "JWT"}
    payload: Dict[str, Any] = {"sub": subject, "iat": now, "exp": exp}
    if issuer is not None:
        payload["iss"] = issuer
    if audience is not None:
        payload["aud"] = audience
    if additional_claims:
        payload.update(additional_claims)

    encoded_header = _b64url_encode(_json_dumps(header))
    encoded_payload = _b64url_encode(_json_dumps(payload))
    signing_input = f"{encoded_header}.{encoded_payload}"

    signature = _sign_hs256(secret=secret, signing_input=signing_input)
    return f"{signing_input}.{signature}"


def create_refresh_token(
    *,
    subject: str,
    secret: str,
    issuer: Optional[str] = None,
    audience: Optional[str] = None,
    expires_in_seconds: int = 30 * 24 * 60 * 60,
    additional_claims: Optional[Dict[str, Any]] = None,
) -> str:
    """Create a signed HS256 refresh token.

    Currently identical to access token creation; callers may differentiate using
    `type` claim if desired.
    """

    return create_access_token(
        subject=subject,
        secret=secret,
        issuer=issuer,
        audience=audience,
        expires_in_seconds=expires_in_seconds,
        additional_claims={**({"type": "refresh"} if True else {}), **(additional_claims or {})},
    )


def decode_token(
    token: str,
    *,
    secret: str,
    audience: Optional[str] = None,
    issuer: Optional[str] = None,
    verify_exp: bool = True,
) -> Dict[str, Any]:
    """Decode and verify a HS256 JWT token."""

    if not secret:
        raise JWTSecretError("JWT secret is required")

    if not token or token.count(".") != 2:
        raise JWTInvalidError("Token must have 3 dot-separated parts")

    encoded_header, encoded_payload, signature = token.split(".")
    signing_input = f"{encoded_header}.{encoded_payload}"
    expected_sig = _sign_hs256(secret=secret, signing_input=signing_input)

    if not hmac.compare_digest(expected_sig, signature):
        raise JWTInvalidError("Invalid token signature")

    try:
        payload_bytes = _b64url_decode(encoded_payload)
        payload = json.loads(payload_bytes.decode("utf-8"))
    except Exception as e:  # noqa: BLE001
        raise JWTInvalidError(f"Invalid token payload: {e}") from e

    now = int(time.time())

    if verify_exp and "exp" in payload:
        try:
            if now >= int(payload["exp"]):
                raise JWTExpiredError("Token has expired")
        except JWTExpiredError:
            raise
        except Exception as e:  # noqa: BLE001
            raise JWTInvalidError(f"Invalid exp claim: {e}") from e

    if audience is not None and payload.get("aud") != audience:
        raise JWTInvalidError("Invalid token audience")

    if issuer is not None and payload.get("iss") != issuer:
        raise JWTInvalidError("Invalid token issuer")

    return payload

