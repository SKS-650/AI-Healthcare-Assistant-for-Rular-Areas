"""
Dependencies for Medical Chatbot API endpoints.

Authentication is fully delegated to the shared app.auth.dependencies module
so there is a single auth code-path across the entire application.
"""
from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.constants import Role
from app.auth.dependencies import get_current_user as _shared_get_current_user
from app.auth.models import UserModel
from app.database.connection import get_async_session as get_session

from ..repositories.conversation_repository import ConversationRepository
from ..repositories.feedback_repository import FeedbackRepository
from ..services.chatbot_service import ChatbotService
from ..utils.logger import logger


# ─── Repository / Service factories ──────────────────────────────────────────


async def get_conversation_repository(
    session: AsyncSession = Depends(get_session),
) -> ConversationRepository:
    """Get conversation repository instance."""
    return ConversationRepository(session)


async def get_feedback_repository(
    session: AsyncSession = Depends(get_session),
) -> FeedbackRepository:
    """Get feedback repository instance."""
    return FeedbackRepository(session)


async def get_chatbot_service(
    conversation_repo: ConversationRepository = Depends(get_conversation_repository),
    feedback_repo: FeedbackRepository = Depends(get_feedback_repository),
) -> ChatbotService:
    """Get chatbot service instance."""
    return ChatbotService(conversation_repo, feedback_repo)


# ─── Auth dependencies (thin wrappers around the shared auth module) ──────────


async def get_current_user(
    user: UserModel = Depends(_shared_get_current_user),
) -> dict:
    """Return the current authenticated user as a plain dict.

    Delegates all token decoding and DB lookup to the shared auth module,
    which is the single source of truth for authentication.
    """
    return {
        "id": str(user.id),
        "email": user.email,
        "full_name": user.full_name,
        "role": user.role,
        "is_active": user.is_active,
    }


async def get_current_active_user(
    current_user: dict = Depends(get_current_user),
) -> dict:
    """Return the current user; the shared auth module already checks is_active."""
    return current_user


async def get_admin_user(
    current_user: dict = Depends(get_current_active_user),
) -> dict:
    """Verify the current user has admin or doctor role."""
    from fastapi import HTTPException, status
    if current_user.get("role") not in [Role.ADMIN, Role.SUPER_ADMIN, Role.DOCTOR]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required.",
        )
    return current_user


def get_user_id(current_user: dict = Depends(get_current_active_user)) -> str:
    """Extract user ID string from current user dict."""
    return current_user["id"]


def is_admin(current_user: dict = Depends(get_current_active_user)) -> bool:
    """Return True when the current user has an elevated role."""
    return current_user.get("role") in [Role.ADMIN, Role.SUPER_ADMIN, Role.DOCTOR]
