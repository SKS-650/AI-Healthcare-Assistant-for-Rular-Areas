"""Firebase client helpers.

This module is intentionally lightweight: it provides a lazy singleton
for Firestore access.

If you do not use Firebase yet, you can still import this module safely.
"""

from __future__ import annotations

import os
from typing import Any, Optional


_firestore_client: Any = None


def get_firestore_client() -> Any:
    """Return a cached Firestore client (firebase-admin).

    Environment variables (optional):
      - GOOGLE_APPLICATION_CREDENTIALS: path to a service account JSON
      - FIREBASE_PROJECT_ID: project id (fallback)

    Returns:
      firebase_admin.firestore.Client

    Raises:
      RuntimeError: if firebase-admin is not installed.
    """

    global _firestore_client
    if _firestore_client is not None:
        return _firestore_client

    try:
        import firebase_admin
        from firebase_admin import credentials, firestore
    except ImportError as e:
        raise RuntimeError(
            "firebase-admin is not installed. Add it to backend/requirements.txt to use Firebase."
        ) from e

    cred_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
    project_id = os.getenv("FIREBASE_PROJECT_ID")

    if not firebase_admin._apps:  # type: ignore[attr-defined]
        if cred_path:
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred, {"projectId": project_id} if project_id else None)
        else:
            # Falls back to application default credentials.
            firebase_admin.initialize_app()

    _firestore_client = firestore.client()
    return _firestore_client

