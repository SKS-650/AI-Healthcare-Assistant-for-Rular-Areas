"""backend/app/security/oauth.py

Minimal OAuth helper utilities using only the Python standard library.

This module is intentionally generic and does not perform provider-specific
logic (Google/GitHub/etc.).

Use cases
---------
- Build an authorization URL for a given provider.
- Create/parse a `state` value.
- Exchange an authorization code for a token (bearer/access token).

Production note
----------------
Real OAuth flows are complex and should be implemented using a mature
framework/library when possible.
"""

from __future__ import annotations

import base64
import hashlib
import hmac
import json
import secrets
import time
import urllib.parse
import urllib.request
from dataclasses import dataclass
from typing import Any, Dict, Optional, Tuple


class OAuthError(ValueError):
    pass


def build_oauth_authorize_url(
    *,
    authorization_endpoint: str,
    client_id: str,
    redirect_uri: str,
    scope: str,
    state: Optional[str] = None,
    response_type: str = "code",
    extra_params: Optional[Dict[str, Any]] = None,
) -> str:
    """Create an OAuth authorization URL."""

    if not authorization_endpoint:
        raise OAuthError("authorization_endpoint is required")

    params: Dict[str, Any] = {
        "response_type": response_type,
        "client_id": client_id,
        "redirect_uri": redirect_uri,
        "scope": scope,
    }
    if state is not None:
        params["state"] = state

    if extra_params:
        params.update(extra_params)

    return authorization_endpoint + "?" + urllib.parse.urlencode(params)


def generate_state(*, secret: str, ttl_seconds: int = 10 * 60) -> str:
    """Generate a signed state value.

    state format (base64url(payload).sig)
    where payload includes {"ts": <unix>, "nonce": <rand>}.
    """

    if not secret:
        raise OAuthError("secret is required")

    payload = {"ts": int(time.time()), "ttl": int(ttl_seconds), "nonce": secrets.token_hex(16)}
    payload_bytes = json.dumps(payload, separators=(",", ":"), sort_keys=True).encode("utf-8")
    payload_b64 = base64.urlsafe_b64encode(payload_bytes).decode("utf-8").rstrip("=")

    sig = hmac.new(secret.encode("utf-8"), payload_b64.encode("utf-8"), hashlib.sha256).digest()
    sig_b64 = base64.urlsafe_b64encode(sig).decode("utf-8").rstrip("=")

    return f"{payload_b64}.{sig_b64}"


def parse_oauth_state(*, state: str, secret: str) -> Dict[str, Any]:
    """Validate and parse a signed state value."""

    if not secret:
        raise OAuthError("secret is required")
    if not state or state.count(".") != 1:
        raise OAuthError("Invalid state")

    payload_b64, sig_b64 = state.split(".")
    expected_sig = hmac.new(secret.encode("utf-8"), payload_b64.encode("utf-8"), hashlib.sha256).digest()

    sig = base64.urlsafe_b64decode(sig_b64 + "=" * (-len(sig_b64) % 4))
    if not hmac.compare_digest(expected_sig, sig):
        raise OAuthError("Invalid state signature")

    payload_bytes = base64.urlsafe_b64decode(payload_b64 + "=" * (-len(payload_b64) % 4))
    payload = json.loads(payload_bytes.decode("utf-8"))

    ts = int(payload.get("ts"))
    ttl = int(payload.get("ttl", 0))
    if ttl <= 0 or int(time.time()) > ts + ttl:
        raise OAuthError("State has expired")

    return payload


def exchange_code_for_token(
    *,
    token_endpoint: str,
    client_id: str,
    client_secret: str,
    redirect_uri: str,
    code: str,
    extra_params: Optional[Dict[str, Any]] = None,
    timeout_seconds: int = 20,
) -> Dict[str, Any]:
    """Exchange an authorization code for a token.

    Uses application/x-www-form-urlencoded body.

    Returns decoded JSON response.
    """

    if not token_endpoint:
        raise OAuthError("token_endpoint is required")

    data: Dict[str, Any] = {
        "grant_type": "authorization_code",
        "code": code,
        "redirect_uri": redirect_uri,
        "client_id": client_id,
        "client_secret": client_secret,
    }
    if extra_params:
        data.update(extra_params)

    body = urllib.parse.urlencode(data).encode("utf-8")
    req = urllib.request.Request(
        token_endpoint,
        data=body,
        headers={"Content-Type": "application/x-www-form-urlencoded"},
        method="POST",
    )

    try:
        with urllib.request.urlopen(req, timeout=timeout_seconds) as resp:
            raw = resp.read().decode("utf-8")
    except Exception as e:  # noqa: BLE001
        raise OAuthError(f"Token exchange failed: {e}") from e

    try:
        return json.loads(raw)
    except Exception as e:  # noqa: BLE001
        raise OAuthError(f"Token endpoint returned non-JSON response: {e}. Raw: {raw[:200]}") from e

