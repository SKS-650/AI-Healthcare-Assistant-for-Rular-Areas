"""MongoDB client helpers.

Provides a cached Motor client + database handle.

If you are using MongoDB synchronously, you can adapt this module to use
pymongo instead.
"""

from __future__ import annotations

import os
from typing import Any, Optional


_motor_client: Any = None


def get_mongo_client() -> Any:
    """Return a cached Motor client.

    Env vars (optional):
      - MONGODB_URI (default: mongodb://localhost:27017)

    Returns:
      motor.motor_asyncio.AsyncIOMotorClient

    Raises:
      RuntimeError if motor is not installed.
    """

    global _motor_client
    if _motor_client is not None:
        return _motor_client

    try:
        from motor.motor_asyncio import AsyncIOMotorClient
    except ImportError as e:
        raise RuntimeError(
            "motor is not installed. Add it to backend/requirements.txt to use MongoDB."
        ) from e

    mongo_uri = os.getenv("MONGODB_URI", "mongodb://localhost:27017")
    _motor_client = AsyncIOMotorClient(mongo_uri)
    return _motor_client


def get_mongo_database() -> Any:
    """Return the Mongo database handle.

    Env vars:
      - MONGODB_DB (optional; default: ai_healthcare)
    """

    db_name = os.getenv("MONGODB_DB", "ai_healthcare")
    client = get_mongo_client()
    return client[db_name]

