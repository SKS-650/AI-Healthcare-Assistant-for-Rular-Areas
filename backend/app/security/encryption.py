"""Encryption helpers."""

from __future__ import annotations

import base64


def encode_text(value: str) -> str:
    """Encode text for non-sensitive placeholder storage."""

    return base64.b64encode(value.encode("utf-8")).decode("utf-8")


def decode_text(value: str) -> str:
    """Decode text encoded by encode_text."""

    return base64.b64decode(value.encode("utf-8")).decode("utf-8")
