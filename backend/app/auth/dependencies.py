"""FastAPI security dependencies for the auth module.

Usage example in a route:
    from backend.app.auth.dependencies import get_current_user, require_role

    @router.get("/me")
    async def me(user = Depends(get_current_user)):
        ...

    @router.delete("/admin/user/{uid}")
    async def delete_user(
        uid: str,
        user = Depends(require_role(Role.ADMIN)),
        db: AsyncSession = Depends(get_db),
    ):
        ...
"""

from __future__ import annotations

from typing import Annotated

from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from backend.app.auth.constants import Role
from backend.app.auth.exceptions import (
    AccountInactiveError,
    InsufficientPermissionsError,
    TokenExpiredError,
    TokenInvalidError,
    TokenRevokedError,
    auth_error_to_http,
)
from backend.app.auth.jwt_handler import decode_access_token
from backend.app.auth.models import UserModel
from backend.app.auth.permissions import has_permission, require_permission
from backend.app.auth import service as auth_service

from backend.app.database.connection import get_async_session as _get_db

_bearer = HTTPBearer(auto_error=False)


# ─── Token extraction ────────────────────────────────────────────────────────


def _extract_token(
    credentials: HTTPAuthorizationCredentials | None,
) -> str:
    """Pull the raw token string from the Authorization header."""
    if credentials is None or credentials.scheme.lower() != "bearer":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing or invalid Authorization header.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return credentials.credentials


# ─── Core dependency ─────────────────────────────────────────────────────────


async def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(_bearer)],
    db=Depends(_get_db),
) -> UserModel:
    """
    Decode the Bearer token and return the authenticated UserModel.
    Raises HTTP 401 on any token problem.
    """
    token = _extract_token(credentials)
    try:
        payload = decode_access_token(token)
    except (TokenExpiredError, TokenInvalidError, TokenRevokedError) as e:
        raise auth_error_to_http(e)

    user_id: str = payload.get("sub", "")
    if not user_id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token subject.")

    try:
        user = await auth_service.get_current_user(db, user_id)
    except (AccountInactiveError,) as e:
        raise auth_error_to_http(e)

    return user


# ─── Optional auth (routes accessible to anonymous users too) ────────────────


async def get_optional_user(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(_bearer)],
    db=Depends(_get_db),
) -> UserModel | None:
    """Return the authenticated user, or None if no valid token is provided."""
    if credentials is None:
        return None
    try:
        return await get_current_user(credentials=credentials, db=db)
    except HTTPException:
        return None


# ─── Role guard factory ──────────────────────────────────────────────────────


def require_role(*roles: str):
    """
    Dependency factory: only allow users whose role is in `roles`.

    Usage:
        @router.get("/admin")
        async def admin_page(user = Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))):
            ...
    """

    async def _check(current_user: Annotated[UserModel, Depends(get_current_user)]) -> UserModel:
        if current_user.role not in roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access restricted to roles: {', '.join(roles)}.",
            )
        return current_user

    return _check


# ─── Permission guard factory ────────────────────────────────────────────────


def require_permission_dep(permission: str):
    """
    Dependency factory: only allow users whose role includes `permission`.

    Usage:
        @router.delete("/records/{id}")
        async def delete_record(user = Depends(require_permission_dep(Permission.WRITE_ANY_RECORDS))):
            ...
    """

    async def _check(current_user: Annotated[UserModel, Depends(get_current_user)]) -> UserModel:
        if not has_permission(current_user.role, permission):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Missing permission: {permission}.",
            )
        return current_user

    return _check


# ─── Typed aliases (convenience) ─────────────────────────────────────────────

CurrentUser = Annotated[UserModel, Depends(get_current_user)]
OptionalUser = Annotated[UserModel | None, Depends(get_optional_user)]
AdminUser = Annotated[UserModel, Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))]
DoctorUser = Annotated[UserModel, Depends(require_role(Role.DOCTOR, Role.ADMIN, Role.SUPER_ADMIN))]
