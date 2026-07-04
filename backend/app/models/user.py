"""User domain models.

These are lightweight Python data structures intended to be imported by
services/controllers.

For now, they are kept framework-agnostic (no FastAPI/Pydantic dependency)
so they can be reused in multiple layers.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Optional


@dataclass
class User:
    """Represents an application user."""

    id: str
    email: Optional[str] = None
    display_name: Optional[str] = None
    roles: list[str] = field(default_factory=list)

    # Free-form profile data (medical preferences, settings, etc.)
    metadata: dict[str, Any] = field(default_factory=dict)

