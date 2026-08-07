"""Admin API routes — mounted under /api/v1/admin"""

from __future__ import annotations

import math
from datetime import datetime, timezone
from typing import Optional, List

from fastapi import APIRouter, Depends, HTTPException, Query, Request, Response, status
from sqlalchemy import select, func, desc, update, delete
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.dependencies import AdminUser, CurrentUser, require_role
from app.auth.constants import Role
from app.database.connection import get_async_session as get_db
from app.admin import schemas
from app.admin.service import (
    ActivityLogService,
    AdminChatbotService,
    AdminEducationService,
    AdminEmergencyService,
    AdminUserService,
    DashboardService,
    DatasetService,
    NotificationService,
    ReportsService,
    SymptomAnalyticsService,
    SystemSettingsService,
)
from app.symptom_checker.service import symptom_checker_service as _sc_service

router = APIRouter(prefix="/admin", tags=["Admin Dashboard"])


# ─── Dashboard ────────────────────────────────────────────────────────────────

@router.get(
    "/dashboard",
    response_model=schemas.DashboardResponse,
    summary="Get admin dashboard overview",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def get_dashboard(db: AsyncSession = Depends(get_db)) -> schemas.DashboardResponse:
    return await DashboardService.get_dashboard(db)


@router.get(
    "/dashboard/stats",
    response_model=schemas.DashboardStats,
    summary="Get dashboard statistics",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def get_stats(db: AsyncSession = Depends(get_db)) -> schemas.DashboardStats:
    return await DashboardService.get_stats(db)


# ─── User Management ─────────────────────────────────────────────────────────

@router.get(
    "/users",
    response_model=schemas.AdminUserListResponse,
    summary="List all users (admin)",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def list_users(
    search:         Optional[str]  = Query(None),
    role:           Optional[str]  = Query(None),
    is_active:      Optional[bool] = Query(None),
    email_verified: Optional[bool] = Query(None),
    page:           int            = Query(1, ge=1),
    page_size:      int            = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
) -> schemas.AdminUserListResponse:
    return await AdminUserService.list_users(db, search, role, is_active, page, page_size, email_verified=email_verified)


@router.get(
    "/users/{user_id}",
    response_model=schemas.AdminUserDetail,
    summary="Get user detail",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def get_user(user_id: str, db: AsyncSession = Depends(get_db)) -> schemas.AdminUserDetail:
    user = await AdminUserService.get_user_detail(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.patch(
    "/users/{user_id}/status",
    response_model=schemas.AdminUserItem,
    summary="Activate/deactivate user",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def update_user_status(
    user_id: str,
    payload: schemas.UpdateUserStatusRequest,
    current_user: AdminUser,
    request: Request,
    db: AsyncSession = Depends(get_db),
) -> schemas.AdminUserItem:
    user = await AdminUserService.update_user_status(db, user_id, payload.is_active)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    action = "user.activate" if payload.is_active else "user.deactivate"
    await ActivityLogService.log(db, current_user.id, action, "users", user_id, "User",
                                  ip_address=request.client.host if request.client else None)
    return user


@router.patch(
    "/users/{user_id}/role",
    response_model=schemas.AdminUserItem,
    summary="Change user role",
    dependencies=[Depends(require_role(Role.SUPER_ADMIN))],
)
async def update_user_role(
    user_id: str,
    payload: schemas.UpdateUserRoleRequest,
    current_user: AdminUser,
    request: Request,
    db: AsyncSession = Depends(get_db),
) -> schemas.AdminUserItem:
    user = await AdminUserService.update_user_role(db, user_id, payload.role)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    await ActivityLogService.log(db, current_user.id, "user.change_role", "users", user_id, "User",
                                  description=f"Changed to {payload.role}",
                                  ip_address=request.client.host if request.client else None)
    return user


@router.delete(
    "/users/{user_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    response_class=Response,
    response_model=None,
    summary="Delete user",
    dependencies=[Depends(require_role(Role.SUPER_ADMIN))],
)
async def delete_user(
    user_id: str,
    current_user: AdminUser,
    request: Request,
    db: AsyncSession = Depends(get_db),
) -> None:
    deleted = await AdminUserService.delete_user(db, user_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="User not found")
    await ActivityLogService.log(db, current_user.id, "user.delete", "users", user_id, "User",
                                  severity="warning",
                                  ip_address=request.client.host if request.client else None)

@router.get(
    "/emergency",
    response_model=schemas.AdminEmergencyListResponse,
    summary="List emergency assessments",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def list_emergencies(
    risk_level:   Optional[str]  = Query(None),
    is_emergency: Optional[bool] = Query(None),
    page:         int            = Query(1, ge=1),
    page_size:    int            = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
) -> schemas.AdminEmergencyListResponse:
    return await AdminEmergencyService.list_emergencies(db, risk_level, is_emergency, page, page_size)


@router.get(
    "/emergency/stats",
    response_model=schemas.EmergencyStatsResponse,
    summary="Emergency statistics",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def emergency_stats(db: AsyncSession = Depends(get_db)) -> schemas.EmergencyStatsResponse:
    return await AdminEmergencyService.get_stats(db)


# ─── Chatbot Monitoring ───────────────────────────────────────────────────────

@router.get(
    "/chatbot/conversations",
    response_model=schemas.AdminConversationListResponse,
    summary="List all chatbot conversations",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def list_conversations(
    search:        Optional[str]  = Query(None),
    language:      Optional[str]  = Query(None),
    has_emergency: Optional[bool] = Query(None),
    page:          int            = Query(1, ge=1),
    page_size:     int            = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
) -> schemas.AdminConversationListResponse:
    return await AdminChatbotService.list_conversations(db, search, language, has_emergency, page, page_size)


@router.get(
    "/chatbot/stats",
    response_model=schemas.ChatbotStatsResponse,
    summary="Chatbot statistics",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def chatbot_stats(db: AsyncSession = Depends(get_db)) -> schemas.ChatbotStatsResponse:
    return await AdminChatbotService.get_stats(db)


# ─── Health Education ─────────────────────────────────────────────────────────

@router.get(
    "/education/articles",
    response_model=schemas.AdminArticleListResponse,
    summary="List all education articles",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def list_articles(
    search:       Optional[str]  = Query(None),
    category_id:  Optional[str]  = Query(None),
    language:     Optional[str]  = Query(None),
    is_published: Optional[bool] = Query(None),
    page:         int            = Query(1, ge=1),
    page_size:    int            = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
) -> schemas.AdminArticleListResponse:
    return await AdminEducationService.list_articles(db, search, category_id, language, is_published, page, page_size)


@router.post(
    "/education/articles",
    response_model=schemas.AdminArticleResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create education article",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def create_article(
    payload: schemas.AdminArticleCreate,
    current_user: AdminUser,
    db: AsyncSession = Depends(get_db),
) -> schemas.AdminArticleResponse:
    article = await AdminEducationService.create_article(db, payload, current_user.id)
    await ActivityLogService.log(db, current_user.id, "article.create", "education", article.id, "HealthArticle", description=article.title)
    return article


@router.put(
    "/education/articles/{article_id}",
    response_model=schemas.AdminArticleResponse,
    summary="Update education article",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def update_article(
    article_id: str,
    payload: schemas.AdminArticleUpdate,
    current_user: AdminUser,
    db: AsyncSession = Depends(get_db),
) -> schemas.AdminArticleResponse:
    article = await AdminEducationService.update_article(db, article_id, payload)
    if not article:
        raise HTTPException(status_code=404, detail="Article not found")
    await ActivityLogService.log(db, current_user.id, "article.update", "education", article_id, "HealthArticle")
    return article


@router.delete(
    "/education/articles/{article_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    response_class=Response,
    response_model=None,
    summary="Delete education article",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def delete_article(
    article_id: str,
    current_user: AdminUser,
    db: AsyncSession = Depends(get_db),
) -> None:
    deleted = await AdminEducationService.delete_article(db, article_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Article not found")
    await ActivityLogService.log(db, current_user.id, "article.delete", "education", article_id, "HealthArticle", severity="warning")


# ─── Activity Logs ────────────────────────────────────────────────────────────

@router.get(
    "/logs",
    response_model=schemas.ActivityLogListResponse,
    summary="Get admin activity logs",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def get_logs(
    module:    Optional[str] = Query(None),
    severity:  Optional[str] = Query(None),
    admin_id:  Optional[str] = Query(None),
    page:      int           = Query(1, ge=1),
    page_size: int           = Query(50, ge=1, le=200),
    db: AsyncSession = Depends(get_db),
) -> schemas.ActivityLogListResponse:
    return await ActivityLogService.list_logs(db, module, severity, admin_id, page, page_size)


# ─── Reports ─────────────────────────────────────────────────────────────────

@router.get(
    "/reports",
    response_model=schemas.ReportsResponse,
    summary="Get analytics reports",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def get_reports(
    days: int = Query(30, ge=7, le=365),
    db: AsyncSession = Depends(get_db),
) -> schemas.ReportsResponse:
    return await ReportsService.get_reports(db, days)


# ─── System Settings ─────────────────────────────────────────────────────────

@router.get(
    "/settings",
    response_model=schemas.SystemSettingsResponse,
    summary="Get system settings",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def get_settings(db: AsyncSession = Depends(get_db)) -> schemas.SystemSettingsResponse:
    await SystemSettingsService.seed_defaults(db)
    return await SystemSettingsService.get_all(db)


@router.patch(
    "/settings/{key}",
    response_model=schemas.SystemSettingItem,
    summary="Update a system setting",
    dependencies=[Depends(require_role(Role.SUPER_ADMIN))],
)
async def update_setting(
    key: str,
    payload: schemas.SystemSettingUpdate,
    current_user: AdminUser,
    db: AsyncSession = Depends(get_db),
) -> schemas.SystemSettingItem:
    setting = await SystemSettingsService.update(db, key, payload, current_user.id)
    if not setting:
        raise HTTPException(status_code=404, detail="Setting not found")
    await ActivityLogService.log(db, current_user.id, "settings.update", "settings", key, "SystemSetting")
    return setting


# ─── Notifications ────────────────────────────────────────────────────────────

@router.get(
    "/notifications",
    response_model=schemas.NotificationListResponse,
    summary="Get admin notifications",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def get_notifications(db: AsyncSession = Depends(get_db)) -> schemas.NotificationListResponse:
    return await NotificationService.list_notifications(db)


@router.patch(
    "/notifications/{notification_id}/read",
    summary="Mark notification as read",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def mark_notification_read(
    notification_id: str,
    db: AsyncSession = Depends(get_db),
) -> dict:
    ok = await NotificationService.mark_read(db, notification_id)
    if not ok:
        raise HTTPException(status_code=404, detail="Notification not found")
    return {"success": True}


# ─── Symptom Analytics ───────────────────────────────────────────────────────

@router.get(
    "/analytics/stats",
    summary="Get symptom analytics statistics",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def analytics_stats(db: AsyncSession = Depends(get_db)) -> dict:
    return await SymptomAnalyticsService.get_stats(db)


@router.get(
    "/analytics/symptom-frequency",
    summary="Top symptom frequencies",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def symptom_frequency(
    limit: int = Query(20, ge=5, le=50),
    db: AsyncSession = Depends(get_db),
) -> list:
    return await SymptomAnalyticsService.get_symptom_frequency(db, limit)


@router.get(
    "/analytics/trend",
    summary="Assessment trend over time",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def analytics_trend(
    days: int = Query(30, ge=7, le=90),
    db: AsyncSession = Depends(get_db),
) -> list:
    return await SymptomAnalyticsService.get_symptom_trend(db, days)


@router.get(
    "/analytics/risk-distribution",
    summary="Risk level distribution",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def risk_distribution(db: AsyncSession = Depends(get_db)) -> list:
    return await SymptomAnalyticsService.get_risk_distribution(db)


@router.get(
    "/analytics/gender-distribution",
    summary="Gender distribution of assessments",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def gender_distribution(db: AsyncSession = Depends(get_db)) -> list:
    return await SymptomAnalyticsService.get_gender_distribution(db)


@router.get(
    "/analytics/age-distribution",
    summary="Age group distribution of assessments",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def age_distribution(db: AsyncSession = Depends(get_db)) -> list:
    return await SymptomAnalyticsService.get_age_distribution(db)


@router.get(
    "/analytics/emergency-types",
    summary="Top emergency types",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def emergency_types(db: AsyncSession = Depends(get_db)) -> list:
    return await SymptomAnalyticsService.get_emergency_types(db)


# ─── Dataset Management ───────────────────────────────────────────────────────

@router.get(
    "/datasets",
    summary="List dataset versions",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def list_datasets(
    dataset_type: Optional[str] = Query(None),
    page:         int           = Query(1, ge=1),
    page_size:    int           = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
) -> dict:
    return await DatasetService.list_datasets(db, dataset_type, page, page_size)


@router.get(
    "/datasets/stats",
    summary="Dataset statistics",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def dataset_stats(db: AsyncSession = Depends(get_db)) -> dict:
    return await DatasetService.get_stats(db)


@router.post(
    "/datasets",
    status_code=status.HTTP_201_CREATED,
    summary="Register a new dataset version",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def create_dataset(
    payload: schemas.DatasetVersionCreate,
    current_user: AdminUser,
    db: AsyncSession = Depends(get_db),
) -> dict:
    dataset = await DatasetService.create_dataset(
        db,
        name=payload.name,
        dataset_type=payload.dataset_type,
        version=payload.version,
        description=payload.description,
        admin_id=current_user.id,
    )
    await ActivityLogService.log(
        db, current_user.id, "dataset.create", "datasets",
        dataset["id"], "DatasetVersion", description=payload.name,
    )
    return dataset


@router.patch(
    "/datasets/{dataset_id}/activate",
    summary="Activate a dataset version",
    dependencies=[Depends(require_role(Role.SUPER_ADMIN))],
)
async def activate_dataset(
    dataset_id: str,
    current_user: AdminUser,
    db: AsyncSession = Depends(get_db),
) -> dict:
    result = await DatasetService.activate_dataset(db, dataset_id)
    if not result:
        raise HTTPException(status_code=404, detail="Dataset not found")
    await ActivityLogService.log(
        db, current_user.id, "dataset.activate", "datasets",
        dataset_id, "DatasetVersion", severity="warning",
    )
    return result


@router.delete(
    "/datasets/{dataset_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    response_class=Response,
    response_model=None,
    summary="Delete a dataset version",
    dependencies=[Depends(require_role(Role.SUPER_ADMIN))],
)
async def delete_dataset(
    dataset_id: str,
    current_user: AdminUser,
    db: AsyncSession = Depends(get_db),
) -> None:
    deleted = await DatasetService.delete_dataset(db, dataset_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Dataset not found")
    await ActivityLogService.log(
        db, current_user.id, "dataset.delete", "datasets",
        dataset_id, "DatasetVersion", severity="warning",
    )


# ─── Disease Prediction / Symptom Checker Analytics (admin) ──────────────────

@router.get(
    "/disease-prediction/stats",
    summary="Disease prediction model stats and usage",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def disease_prediction_stats(db: AsyncSession = Depends(get_db)) -> dict:
    """Returns model info plus per-disease prediction counts from history."""
    from sqlalchemy import func, select
    from app.symptom_checker.models import SymptomCheckHistory

    model_info = _sc_service.get_model_info()

    # Top 10 predicted diseases
    result = await db.execute(
        select(
            SymptomCheckHistory.predicted_disease,
            func.count(SymptomCheckHistory.id).label("count"),
        )
        .group_by(SymptomCheckHistory.predicted_disease)
        .order_by(func.count(SymptomCheckHistory.id).desc())
        .limit(10)
    )
    top_diseases = [{"disease": r[0], "count": r[1]} for r in result.all()]

    # Risk level distribution
    risk_result = await db.execute(
        select(
            SymptomCheckHistory.risk_level,
            func.count(SymptomCheckHistory.id).label("count"),
        )
        .group_by(SymptomCheckHistory.risk_level)
    )
    risk_dist = {r[0]: r[1] for r in risk_result.all()}

    total_checks  = (await db.execute(select(func.count(SymptomCheckHistory.id)))).scalar_one()
    emergency_cnt = (await db.execute(
        select(func.count(SymptomCheckHistory.id)).where(SymptomCheckHistory.is_emergency == True)
    )).scalar_one()

    return {
        "model_loaded":        model_info.get("loaded", False),
        "model_version":       model_info.get("model_version"),
        "available_symptoms":  model_info.get("n_symptoms", 0),
        "available_diseases":  model_info.get("n_diseases", 0),
        "total_predictions":   total_checks,
        "emergency_flags":     emergency_cnt,
        "top_diseases":        top_diseases,
        "risk_distribution":   risk_dist,
    }


@router.get(
    "/disease-prediction/history",
    summary="Paginated symptom-check history (all users)",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def disease_prediction_history(
    risk_level: Optional[str] = Query(None),
    is_emergency: Optional[bool] = Query(None),
    page:      int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
) -> dict:
    import math
    from sqlalchemy import func, select, desc, and_
    from app.symptom_checker.models import SymptomCheckHistory
    from app.auth.models import UserModel

    q = select(SymptomCheckHistory)
    if risk_level:
        q = q.where(SymptomCheckHistory.risk_level == risk_level.upper())
    if is_emergency is not None:
        q = q.where(SymptomCheckHistory.is_emergency == is_emergency)

    total  = (await db.execute(select(func.count()).select_from(q.subquery()))).scalar_one()
    offset = (page - 1) * page_size
    result = await db.execute(q.order_by(desc(SymptomCheckHistory.created_at)).offset(offset).limit(page_size))
    rows = result.scalars().all()

    items = []
    for r in rows:
        user_name = None
        if r.user_id:
            u = await db.get(UserModel, r.user_id)
            if u:
                user_name = u.full_name
        items.append({
            "id":                r.id,
            "user_id":           r.user_id,
            "user_name":         user_name,
            "symptoms":          r.symptoms or [],
            "age":               r.age,
            "gender":            r.gender,
            "predicted_disease": r.predicted_disease,
            "confidence":        r.confidence,
            "risk_level":        r.risk_level,
            "risk_score":        r.risk_score,
            "is_emergency":      r.is_emergency,
            "created_at":        r.created_at.isoformat() if r.created_at else None,
        })

    return {
        "predictions": items,
        "total": total,
        "page": page,
        "page_size": page_size,
        "total_pages": math.ceil(total / page_size) if total else 1,
    }


@router.post(
    "/disease-prediction/reload-model",
    summary="Hot-reload symptom checker model",
    dependencies=[Depends(require_role(Role.SUPER_ADMIN))],
)
async def reload_disease_model(current_user: AdminUser) -> dict:
    try:
        info = _sc_service.reload_model()
        await ActivityLogService.log(
            None, current_user.id, "model.reload", "disease_prediction",
            severity="warning",
        )
        return {"status": "reloaded", "model_info": info}
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


# ─── Health Check ─────────────────────────────────────────────────────────────

@router.get("/health", tags=["Health"])
async def health() -> dict:
    return {"status": "ok", "module": "admin"}


# ─── Doctors Management ──────────────────────────────────────────────────────

@router.get(
    "/doctors",
    summary="List all doctors",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def list_doctors(
    search: Optional[str] = Query(None),
    specialization: Optional[str] = Query(None),
    is_active: Optional[bool] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
) -> dict:
    """List all registered doctors with filtering."""
    from sqlalchemy import select, func, or_, and_
    from app.auth.models import UserModel
    
    # Build query
    query = select(UserModel).where(UserModel.role == Role.DOCTOR)
    
    if search:
        query = query.where(
            or_(
                UserModel.full_name.ilike(f"%{search}%"),
                UserModel.email.ilike(f"%{search}%")
            )
        )
    
    if is_active is not None:
        query = query.where(UserModel.is_active == is_active)
    
    # Get total count
    count_query = select(func.count()).select_from(query.subquery())
    total = (await db.execute(count_query)).scalar_one()
    
    # Get paginated results
    offset = (page - 1) * page_size
    result = await db.execute(
        query.order_by(UserModel.created_at.desc())
        .limit(page_size)
        .offset(offset)
    )
    doctors = result.scalars().all()
    
    return {
        "doctors": [
            {
                "id": d.id,
                "full_name": d.full_name,
                "email": d.email,
                "phone": d.phone,
                "is_active": d.is_active,
                "email_verified": d.email_verified,
                "phone_verified": d.phone_verified,
                "profile_image": d.profile_image,
                "created_at": d.created_at.isoformat(),
                "last_login": d.last_login.isoformat() if d.last_login else None,
            }
            for d in doctors
        ],
        "total": total,
        "page": page,
        "page_size": page_size,
        "total_pages": math.ceil(total / page_size) if total > 0 else 1,
    }


class _CreateDoctorBody(schemas.BaseModel):
    full_name: str
    email: str
    password: str
    phone: Optional[str] = None


@router.post(
    "/doctors",
    status_code=status.HTTP_201_CREATED,
    summary="Create doctor account",
    dependencies=[Depends(require_role(Role.SUPER_ADMIN))],
)
async def create_doctor(
    body: _CreateDoctorBody,
    current_user: AdminUser,
    db: AsyncSession = Depends(get_db),
) -> dict:
    """Create a new doctor account, bypassing password-strength validation."""
    import uuid
    from app.auth.models import UserModel
    from app.auth.password import hash_password
    from app.auth import repository as auth_repo

    email = body.email.lower().strip()

    existing = await auth_repo.get_user_by_email(db, email)
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")

    if body.phone:
        existing_phone = await auth_repo.get_user_by_phone(db, body.phone)
        if existing_phone:
            raise HTTPException(status_code=400, detail="Phone already registered")

    user = UserModel(
        id=str(uuid.uuid4()),
        full_name=body.full_name,
        email=email,
        phone=body.phone if body.phone else None,
        password_hash=hash_password(body.password),
        role=Role.DOCTOR,
        language="en",
        is_active=True,
        email_verified=True,
        phone_verified=bool(body.phone),
    )
    await auth_repo.create_user(db, user)
    await db.commit()
    await db.refresh(user)

    await ActivityLogService.log(
        db, current_user.id, "doctor.create", "doctors", user.id, "User",
        description=f"Created doctor account for {email}"
    )

    return {
        "id": user.id,
        "full_name": user.full_name,
        "email": user.email,
        "message": "Doctor account created successfully",
    }


class _UpdateDoctorStatusBody(schemas.BaseModel):
    is_active: bool


@router.patch(
    "/doctors/{doctor_id}/status",
    summary="Activate/deactivate doctor",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def update_doctor_status(
    doctor_id: str,
    body: _UpdateDoctorStatusBody,
    current_user: AdminUser,
    db: AsyncSession = Depends(get_db),
) -> dict:
    """Activate or deactivate a doctor account."""
    from sqlalchemy import select, update
    from app.auth.models import UserModel

    result = await db.execute(
        select(UserModel).where(
            UserModel.id == doctor_id,
            UserModel.role == Role.DOCTOR
        )
    )
    doctor = result.scalar_one_or_none()

    if not doctor:
        raise HTTPException(status_code=404, detail="Doctor not found")

    await db.execute(
        update(UserModel)
        .where(UserModel.id == doctor_id)
        .values(is_active=body.is_active)
    )
    await db.commit()

    action = "doctor.activate" if body.is_active else "doctor.deactivate"
    await ActivityLogService.log(
        db, current_user.id, action, "doctors", doctor_id, "User"
    )

    return {"message": f"Doctor {'activated' if body.is_active else 'deactivated'} successfully"}


# ─── Symptom Checker Configuration ───────────────────────────────────────────

@router.get(
    "/symptom-checker/config",
    summary="Get symptom checker configuration",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def get_symptom_checker_config(db: AsyncSession = Depends(get_db)) -> dict:
    """Get current symptom checker configuration."""
    config = {
        "model_version": _sc_service.get_model_info().get("model_version", "1.0.0"),
        "confidence_threshold": 0.7,
        "emergency_keywords": [
            "chest pain", "difficulty breathing", "severe bleeding",
            "unconscious", "stroke symptoms", "heart attack"
        ],
        "risk_thresholds": {
            "critical": 85,
            "high": 70,
            "medium": 50,
            "low": 0
        }
    }
    return config


# ─── Chatbot Configuration ───────────────────────────────────────────────────

@router.get(
    "/chatbot/config",
    summary="Get chatbot configuration",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def get_chatbot_config(db: AsyncSession = Depends(get_db)) -> dict:
    """Get current chatbot configuration."""
    return {
        "model": "gemini-1.5-flash",
        "temperature": 0.7,
        "max_tokens": 2048,
        "emergency_detection_enabled": True,
        "response_language": "multi",
        "supported_languages": ["en", "ne", "hi", "bh"],
        "context_window": 10,
        "safety_settings": "high"
    }


@router.delete(
    "/chatbot/conversations/{conversation_id}",
    summary="Delete conversation (admin)",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def delete_conversation_admin(
    conversation_id: int,
    current_user: AdminUser,
    db: AsyncSession = Depends(get_db),
) -> dict:
    """Admin can delete any conversation."""
    from sqlalchemy import delete
    from app.medical_chatbot.database.models import Conversation
    
    result = await db.execute(
        delete(Conversation).where(Conversation.id == conversation_id)
    )
    await db.commit()
    
    if result.rowcount == 0:
        raise HTTPException(status_code=404, detail="Conversation not found")
    
    await ActivityLogService.log(
        db, current_user.id, "chatbot.delete_conversation", "chatbot",
        str(conversation_id), "Conversation", severity="warning"
    )
    
    return {"message": "Conversation deleted successfully"}



# ─── System Monitoring ────────────────────────────────────────────────────────

@router.get(
    "/system/health",
    summary="Comprehensive system health check",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def system_health(db: AsyncSession = Depends(get_db)) -> dict:
    """Get comprehensive system health status."""
    health = {
        "database": "healthy",
        "api": "healthy",
        "symptom_checker": "healthy" if _sc_service.is_model_loaded() else "unavailable",
        "chatbot": "healthy",
        "emergency_system": "healthy",
        "storage": "healthy",
        "timestamp": datetime.now(timezone.utc).isoformat()
    }
    
    try:
        # Test database connection
        from app.auth.models import UserModel
        await db.execute(select(func.count(UserModel.id)))
    except Exception:
        health["database"] = "unhealthy"
    
    return health


@router.get(
    "/system/metrics",
    summary="System performance metrics",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def system_metrics(db: AsyncSession = Depends(get_db)) -> dict:
    """Get system performance metrics."""
    try:
        import psutil
        return {
            "cpu_usage_percent": psutil.cpu_percent(interval=0.1),
            "memory_usage_percent": psutil.virtual_memory().percent,
            "disk_usage_percent": psutil.disk_usage('/').percent,
            "active_connections": len(psutil.net_connections()),
            "timestamp": datetime.now(timezone.utc).isoformat()
        }
    except ImportError:
        return {
            "cpu_usage_percent": 0,
            "memory_usage_percent": 0,
            "disk_usage_percent": 0,
            "active_connections": 0,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "note": "psutil not installed - metrics unavailable"
        }


# ─── Bulk Operations ──────────────────────────────────────────────────────────

class _BulkActionBody(schemas.BaseModel):
    user_ids: List[str]
    action: str  # activate, deactivate, delete


@router.post(
    "/users/bulk-action",
    summary="Bulk user operations",
    dependencies=[Depends(require_role(Role.SUPER_ADMIN))],
)
async def bulk_user_action(
    body: _BulkActionBody,
    current_user: AdminUser,
    db: AsyncSession = Depends(get_db),
) -> dict:
    """Perform bulk actions on multiple users."""
    from sqlalchemy import update, delete
    from app.auth.models import UserModel

    if body.action == "activate":
        await db.execute(
            update(UserModel)
            .where(UserModel.id.in_(body.user_ids))
            .values(is_active=True)
        )
    elif body.action == "deactivate":
        await db.execute(
            update(UserModel)
            .where(UserModel.id.in_(body.user_ids))
            .values(is_active=False)
        )
    elif body.action == "delete":
        await db.execute(
            delete(UserModel).where(UserModel.id.in_(body.user_ids))
        )
    else:
        raise HTTPException(status_code=400, detail="Invalid action")

    await db.commit()

    await ActivityLogService.log(
        db, current_user.id, f"users.bulk_{body.action}", "users",
        None, "User", description=f"Bulk {body.action} on {len(body.user_ids)} users",
        severity="warning"
    )

    return {"message": f"Bulk {body.action} completed successfully", "affected_count": len(body.user_ids)}


# ─── Data Export ──────────────────────────────────────────────────────────────

@router.get(
    "/export/users",
    summary="Export users data",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def export_users(
    format: str = Query("csv", regex="^(csv|json)$"),
    db: AsyncSession = Depends(get_db),
) -> dict:
    """Export users data in CSV or JSON format."""
    from sqlalchemy import select
    from app.auth.models import UserModel
    import csv
    import io
    import json
    
    result = await db.execute(select(UserModel).limit(1000))
    users = result.scalars().all()
    
    if format == "csv":
        output = io.StringIO()
        writer = csv.writer(output)
        writer.writerow(["ID", "Full Name", "Email", "Phone", "Role", "Active", "Created At"])
        for u in users:
            writer.writerow([
                u.id, u.full_name, u.email, u.phone, u.role,
                u.is_active, u.created_at.isoformat()
            ])
        return {"data": output.getvalue(), "format": "csv", "count": len(users)}
    else:
        data = [
            {
                "id": u.id,
                "full_name": u.full_name,
                "email": u.email,
                "phone": u.phone,
                "role": u.role,
                "is_active": u.is_active,
                "created_at": u.created_at.isoformat()
            }
            for u in users
        ]
        return {"data": json.dumps(data, indent=2), "format": "json", "count": len(users)}


@router.get(
    "/export/emergency",
    summary="Export emergency assessments",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def export_emergency(
    format: str = Query("csv", regex="^(csv|json)$"),
    db: AsyncSession = Depends(get_db),
) -> dict:
    """Export emergency assessments data."""
    from sqlalchemy import select
    from app.emergency.models import EmergencyAssessment
    import csv
    import io
    import json
    
    result = await db.execute(
        select(EmergencyAssessment)
        .order_by(desc(EmergencyAssessment.created_at))
        .limit(1000)
    )
    assessments = result.scalars().all()
    
    if format == "csv":
        output = io.StringIO()
        writer = csv.writer(output)
        writer.writerow([
            "ID", "User ID", "Age", "Gender", "Risk Level", 
            "Risk Score", "Is Emergency", "Emergency Type", "Created At"
        ])
        for a in assessments:
            writer.writerow([
                a.id, a.user_id, a.age, a.gender, a.risk_level,
                a.risk_score, a.is_emergency, a.emergency_type, a.created_at.isoformat()
            ])
        return {"data": output.getvalue(), "format": "csv", "count": len(assessments)}
    else:
        data = [
            {
                "id": a.id,
                "user_id": a.user_id,
                "age": a.age,
                "gender": a.gender,
                "risk_level": a.risk_level,
                "risk_score": a.risk_score,
                "is_emergency": a.is_emergency,
                "emergency_type": a.emergency_type,
                "created_at": a.created_at.isoformat()
            }
            for a in assessments
        ]
        return {"data": json.dumps(data, indent=2), "format": "json", "count": len(data)}



# ─── Authentication Management ────────────────────────────────────────────────

@router.get(
    "/auth/sessions",
    summary="List all user sessions",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def list_sessions(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
) -> dict:
    from app.auth.models import UserSessionModel, UserModel
    from sqlalchemy.orm import aliased

    q = (
        select(UserSessionModel, UserModel.full_name, UserModel.email)
        .join(UserModel, UserModel.id == UserSessionModel.user_id, isouter=True)
        .where(UserSessionModel.is_active == True)
        .order_by(desc(UserSessionModel.last_activity))
    )
    total = (await db.execute(select(func.count()).select_from(q.subquery()))).scalar_one()
    offset = (page - 1) * page_size
    rows = (await db.execute(q.offset(offset).limit(page_size))).all()

    sessions = []
    for row in rows:
        s = row[0]
        sessions.append({
            "id": s.id, "user_id": s.user_id,
            "user_name": row[1], "user_email": row[2],
            "ip_address": s.ip_address, "device_info": s.user_agent,
            "is_active": s.is_active,
            "expires_at": s.expires_at.isoformat() if s.expires_at else None,
            "created_at": s.created_at.isoformat(),
            "last_active_at": s.last_activity.isoformat() if s.last_activity else None,
        })

    return {
        "sessions": sessions, "total": total,
        "active_count": total,
        "page": page, "page_size": page_size,
        "total_pages": math.ceil(total / page_size) if total else 1,
    }


@router.delete(
    "/auth/sessions/{session_id}",
    summary="Revoke a user session",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def revoke_session(
    session_id: str,
    current_user: AdminUser,
    db: AsyncSession = Depends(get_db),
) -> dict:
    from app.auth.models import UserSessionModel
    result = await db.execute(
        update(UserSessionModel)
        .where(UserSessionModel.id == session_id)
        .values(is_active=False)
    )
    await db.commit()
    if result.rowcount == 0:
        raise HTTPException(status_code=404, detail="Session not found")
    await ActivityLogService.log(
        db, current_user.id, "auth.revoke_session", "authentication",
        session_id, "UserSession", severity="warning"
    )
    return {"message": "Session revoked"}


@router.delete(
    "/auth/sessions/user/{user_id}",
    summary="Revoke all sessions for a user",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def revoke_user_sessions(
    user_id: str,
    current_user: AdminUser,
    db: AsyncSession = Depends(get_db),
) -> dict:
    from app.auth.models import UserSessionModel, RefreshTokenModel
    await db.execute(
        update(UserSessionModel)
        .where(UserSessionModel.user_id == user_id)
        .values(is_active=False)
    )
    await db.execute(
        update(RefreshTokenModel)
        .where(RefreshTokenModel.user_id == user_id)
        .values(is_revoked=True)
    )
    await db.commit()
    await ActivityLogService.log(
        db, current_user.id, "auth.revoke_all_sessions", "authentication",
        user_id, "User", severity="warning"
    )
    return {"message": "All sessions and tokens revoked for user"}


@router.get(
    "/auth/tokens",
    summary="List all refresh tokens",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def list_tokens(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
) -> dict:
    from app.auth.models import RefreshTokenModel, UserModel
    q = (
        select(RefreshTokenModel, UserModel.full_name, UserModel.email)
        .join(UserModel, UserModel.id == RefreshTokenModel.user_id, isouter=True)
        .order_by(desc(RefreshTokenModel.created_at))
    )
    total = (await db.execute(select(func.count()).select_from(q.subquery()))).scalar_one()
    active = (await db.execute(
        select(func.count(RefreshTokenModel.id))
        .where(RefreshTokenModel.is_revoked == False)
    )).scalar_one()
    offset = (page - 1) * page_size
    rows = (await db.execute(q.offset(offset).limit(page_size))).all()

    tokens = []
    for row in rows:
        t = row[0]
        tokens.append({
            "id": t.id, "user_id": t.user_id,
            "user_name": row[1], "user_email": row[2],
            "device_info": t.device_info, "ip_address": t.ip_address,
            "is_revoked": t.is_revoked,
            "expires_at": t.expires_at.isoformat(),
            "created_at": t.created_at.isoformat(),
            "last_used_at": t.last_used_at.isoformat() if t.last_used_at else None,
        })

    return {
        "tokens": tokens, "total": total,
        "active_count": active,
        "page": page, "page_size": page_size,
        "total_pages": math.ceil(total / page_size) if total else 1,
    }


@router.delete(
    "/auth/tokens/{token_id}",
    summary="Revoke a refresh token",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def revoke_token(
    token_id: str,
    current_user: AdminUser,
    db: AsyncSession = Depends(get_db),
) -> dict:
    from app.auth.models import RefreshTokenModel
    result = await db.execute(
        update(RefreshTokenModel)
        .where(RefreshTokenModel.id == token_id)
        .values(is_revoked=True)
    )
    await db.commit()
    if result.rowcount == 0:
        raise HTTPException(status_code=404, detail="Token not found")
    await ActivityLogService.log(
        db, current_user.id, "auth.revoke_token", "authentication",
        token_id, "RefreshToken", severity="warning"
    )
    return {"message": "Token revoked"}


@router.get(
    "/auth/otp-logs",
    summary="List OTP codes (audit log)",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def list_otp_logs(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
) -> dict:
    from app.auth.models import OTPCodeModel, UserModel
    q = (
        select(OTPCodeModel, UserModel.full_name, UserModel.email)
        .join(UserModel, UserModel.id == OTPCodeModel.user_id, isouter=True)
        .order_by(desc(OTPCodeModel.created_at))
    )
    total = (await db.execute(select(func.count()).select_from(q.subquery()))).scalar_one()
    pending = (await db.execute(
        select(func.count(OTPCodeModel.id))
        .where(OTPCodeModel.is_used == False)
    )).scalar_one()
    used = total - pending
    offset = (page - 1) * page_size
    rows = (await db.execute(q.offset(offset).limit(page_size))).all()

    otp_logs = []
    for row in rows:
        o = row[0]
        otp_logs.append({
            "id": o.id, "user_id": o.user_id,
            "user_name": row[1], "user_email": row[2],
            "purpose": o.purpose, "attempts": o.attempts,
            "is_used": o.is_used,
            "expires_at": o.expires_at.isoformat(),
            "created_at": o.created_at.isoformat(),
        })

    return {
        "otp_logs": otp_logs, "total": total,
        "pending_count": pending, "used_count": used,
        "page": page, "page_size": page_size,
        "total_pages": math.ceil(total / page_size) if total else 1,
    }


@router.patch(
    "/auth/verify-email/{user_id}",
    summary="Manually verify user email",
    dependencies=[Depends(require_role(Role.SUPER_ADMIN))],
)
async def manually_verify_email(
    user_id: str,
    current_user: AdminUser,
    db: AsyncSession = Depends(get_db),
) -> dict:
    from app.auth.models import UserModel
    result = await db.execute(
        update(UserModel)
        .where(UserModel.id == user_id)
        .values(email_verified=True)
    )
    await db.commit()
    if result.rowcount == 0:
        raise HTTPException(status_code=404, detail="User not found")
    await ActivityLogService.log(
        db, current_user.id, "auth.verify_email", "authentication",
        user_id, "User"
    )
    return {"message": "Email verified successfully"}


@router.patch(
    "/auth/verify-phone/{user_id}",
    summary="Manually verify user phone",
    dependencies=[Depends(require_role(Role.SUPER_ADMIN))],
)
async def manually_verify_phone(
    user_id: str,
    current_user: AdminUser,
    db: AsyncSession = Depends(get_db),
) -> dict:
    from app.auth.models import UserModel
    result = await db.execute(
        update(UserModel)
        .where(UserModel.id == user_id)
        .values(phone_verified=True)
    )
    await db.commit()
    if result.rowcount == 0:
        raise HTTPException(status_code=404, detail="User not found")
    await ActivityLogService.log(
        db, current_user.id, "auth.verify_phone", "authentication",
        user_id, "User"
    )
    return {"message": "Phone verified successfully"}


# ─── Health Records Admin ─────────────────────────────────────────────────────

@router.get(
    "/health-records/profiles",
    summary="List all user medical profiles (admin)",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def list_medical_profiles(
    search: Optional[str] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
) -> dict:
    from app.health_records.models import UserMedicalProfile
    from app.auth.models import UserModel
    from sqlalchemy import or_

    q = (
        select(UserMedicalProfile, UserModel.full_name, UserModel.email)
        .join(UserModel, UserModel.id == UserMedicalProfile.user_id, isouter=True)
    )
    if search:
        q = q.where(
            or_(
                UserModel.full_name.ilike(f"%{search}%"),
                UserModel.email.ilike(f"%{search}%"),
            )
        )
    total = (await db.execute(select(func.count()).select_from(q.subquery()))).scalar_one()
    offset = (page - 1) * page_size
    rows = (await db.execute(q.offset(offset).limit(page_size))).all()

    profiles = []
    for row in rows:
        p = row[0]
        profiles.append({
            "id": p.id, "user_id": p.user_id,
            "user_name": row[1], "user_email": row[2],
            "blood_group": p.blood_group,
            "height_cm": p.height_cm, "weight_kg": p.weight_kg, "bmi": p.bmi,
            "smoking_status": p.smoking_status,
            "alcohol_status": p.alcohol_status,
            "activity_level": p.activity_level,
            "allergies": p.allergies or [],
            "chronic_diseases": p.chronic_diseases or [],
            "current_medications": p.current_medications or [],
            "family_history": p.family_history or [],
            "created_at": p.created_at.isoformat(),
            "updated_at": p.updated_at.isoformat(),
        })

    return {
        "profiles": profiles, "total": total,
        "page": page, "page_size": page_size,
        "total_pages": math.ceil(total / page_size) if total else 1,
    }


@router.get(
    "/health-records/prescriptions",
    summary="List all prescriptions (admin)",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def list_all_prescriptions(
    search: Optional[str] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
) -> dict:
    from app.health_records.models import Prescription
    from app.auth.models import UserModel
    from sqlalchemy import or_

    q = (
        select(Prescription, UserModel.full_name, UserModel.email)
        .join(UserModel, UserModel.id == Prescription.user_id, isouter=True)
        .order_by(desc(Prescription.created_at))
    )
    if search:
        q = q.where(
            or_(
                Prescription.doctor_name.ilike(f"%{search}%"),
                Prescription.hospital_name.ilike(f"%{search}%"),
                Prescription.diagnosis.ilike(f"%{search}%"),
                UserModel.full_name.ilike(f"%{search}%"),
            )
        )
    total = (await db.execute(select(func.count()).select_from(q.subquery()))).scalar_one()
    offset = (page - 1) * page_size
    rows = (await db.execute(q.offset(offset).limit(page_size))).all()

    prescriptions = []
    for row in rows:
        p = row[0]
        prescriptions.append({
            "id": p.id, "user_id": p.user_id,
            "user_name": row[1], "user_email": row[2],
            "doctor_name": p.doctor_name, "hospital_name": p.hospital_name,
            "diagnosis": p.diagnosis,
            "prescription_date": p.prescription_date.isoformat() if p.prescription_date else None,
            "valid_until": p.valid_until.isoformat() if p.valid_until else None,
            "medicines": p.medicines or [],
            "instructions": p.instructions, "notes": p.notes,
            "created_at": p.created_at.isoformat(),
        })

    return {
        "prescriptions": prescriptions, "total": total,
        "page": page, "page_size": page_size,
        "total_pages": math.ceil(total / page_size) if total else 1,
    }


@router.get(
    "/health-records/images",
    summary="List all medical images (admin)",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def list_all_medical_images(
    image_type: Optional[str] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
) -> dict:
    from app.health_records.models import MedicalImage
    from app.auth.models import UserModel

    q = (
        select(MedicalImage, UserModel.full_name, UserModel.email)
        .join(UserModel, UserModel.id == MedicalImage.user_id, isouter=True)
        .order_by(desc(MedicalImage.created_at))
    )
    if image_type:
        q = q.where(MedicalImage.image_type == image_type)

    total = (await db.execute(select(func.count()).select_from(q.subquery()))).scalar_one()
    offset = (page - 1) * page_size
    rows = (await db.execute(q.offset(offset).limit(page_size))).all()

    images = []
    for row in rows:
        img = row[0]
        images.append({
            "id": img.id, "user_id": img.user_id,
            "user_name": row[1], "user_email": row[2],
            "title": img.title, "image_type": img.image_type,
            "description": img.description, "body_part": img.body_part,
            "doctor_name": img.doctor_name, "hospital_name": img.hospital_name,
            "scan_date": img.scan_date.isoformat() if img.scan_date else None,
            "created_at": img.created_at.isoformat(),
        })

    return {
        "images": images, "total": total,
        "page": page, "page_size": page_size,
        "total_pages": math.ceil(total / page_size) if total else 1,
    }


@router.get(
    "/health-records/medical-history",
    summary="List all medical history entries (admin)",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def list_all_medical_history(
    search: Optional[str] = Query(None),
    category: Optional[str] = Query(None),
    status_filter: Optional[str] = Query(None, alias="status"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
) -> dict:
    from app.health_records.models import MedicalHistory
    from app.auth.models import UserModel
    from sqlalchemy import or_

    q = (
        select(MedicalHistory, UserModel.full_name, UserModel.email)
        .join(UserModel, UserModel.id == MedicalHistory.user_id, isouter=True)
        .order_by(desc(MedicalHistory.created_at))
    )
    if search:
        q = q.where(
            or_(
                MedicalHistory.disease_name.ilike(f"%{search}%"),
                UserModel.full_name.ilike(f"%{search}%"),
            )
        )
    if category:
        q = q.where(MedicalHistory.category == category)
    if status_filter:
        q = q.where(MedicalHistory.status == status_filter)

    total = (await db.execute(select(func.count()).select_from(q.subquery()))).scalar_one()
    offset = (page - 1) * page_size
    rows = (await db.execute(q.offset(offset).limit(page_size))).all()

    entries = []
    for row in rows:
        h = row[0]
        entries.append({
            "id": h.id, "user_id": h.user_id,
            "user_name": row[1], "user_email": row[2],
            "disease_name": h.disease_name, "category": h.category,
            "status": h.status,
            "diagnosis_date": h.diagnosis_date.isoformat() if h.diagnosis_date else None,
            "doctor_name": h.doctor_name, "hospital_name": h.hospital_name,
            "notes": h.notes,
            "created_at": h.created_at.isoformat(),
        })

    return {
        "entries": entries, "total": total,
        "page": page, "page_size": page_size,
        "total_pages": math.ceil(total / page_size) if total else 1,
    }


@router.get(
    "/health-records/medical-history/stats",
    summary="Medical history statistics (admin)",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def medical_history_stats(db: AsyncSession = Depends(get_db)) -> dict:
    from app.health_records.models import MedicalHistory

    total = (await db.execute(select(func.count(MedicalHistory.id)))).scalar_one()

    async def _count_by(col, val):
        return (await db.execute(
            select(func.count(MedicalHistory.id)).where(col == val)
        )).scalar_one()

    return {
        "total": total,
        "current":  await _count_by(MedicalHistory.category, "current"),
        "past":     await _count_by(MedicalHistory.category, "past"),
        "surgery":  await _count_by(MedicalHistory.category, "surgery"),
        "chronic":  await _count_by(MedicalHistory.category, "chronic"),
        "family":   await _count_by(MedicalHistory.category, "family"),
        "active":   await _count_by(MedicalHistory.status, "active"),
        "resolved": await _count_by(MedicalHistory.status, "resolved"),
        "managed":  await _count_by(MedicalHistory.status, "managed"),
    }


@router.get(
    "/health-records/timeline",
    summary="List all medical timeline events (admin)",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def list_all_timeline(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
) -> dict:
    from app.health_records.models import TimelineEvent
    from app.auth.models import UserModel

    q = (
        select(TimelineEvent, UserModel.full_name, UserModel.email)
        .join(UserModel, UserModel.id == TimelineEvent.user_id, isouter=True)
        .order_by(desc(TimelineEvent.event_date))
    )
    total = (await db.execute(select(func.count()).select_from(q.subquery()))).scalar_one()
    offset = (page - 1) * page_size
    rows = (await db.execute(q.offset(offset).limit(page_size))).all()

    events = []
    for row in rows:
        e = row[0]
        events.append({
            "id": e.id, "user_id": e.user_id,
            "user_name": row[1], "user_email": row[2],
            "event_type": e.event_type, "title": e.title,
            "description": e.description, "icon_emoji": e.icon_emoji,
            "event_date": e.event_date.isoformat(),
            "created_at": e.created_at.isoformat(),
        })

    return {
        "events": events, "total": total,
        "page": page, "page_size": page_size,
        "total_pages": math.ceil(total / page_size) if total else 1,
    }


# ── Update health-records stats to include timeline count ─────────────────────

@router.get(
    "/health-records/stats",
    summary="Health records statistics (admin)",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def health_records_stats_full(db: AsyncSession = Depends(get_db)) -> dict:
    from app.health_records.models import (
        UserMedicalProfile, MedicalHistory, Prescription, MedicalImage, TimelineEvent
    )
    return {
        "total_medical_profiles": (await db.execute(select(func.count(UserMedicalProfile.id)))).scalar_one(),
        "total_medical_history_entries": (await db.execute(select(func.count(MedicalHistory.id)))).scalar_one(),
        "total_prescriptions": (await db.execute(select(func.count(Prescription.id)))).scalar_one(),
        "total_medical_images": (await db.execute(select(func.count(MedicalImage.id)))).scalar_one(),
        "total_timeline_events": (await db.execute(select(func.count(TimelineEvent.id)))).scalar_one(),
    }


# ─── Profile / User Data Admin ────────────────────────────────────────────────

@router.get(
    "/profiles/list",
    summary="List all user profiles (admin)",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def list_user_profiles(
    search: Optional[str] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
) -> dict:
    from app.users.models import UserProfile
    from app.auth.models import UserModel
    from sqlalchemy import or_

    q = (
        select(UserProfile, UserModel.full_name, UserModel.email)
        .join(UserModel, UserModel.id == UserProfile.user_id, isouter=True)
        .order_by(desc(UserProfile.created_at))
    )
    if search:
        q = q.where(
            or_(
                UserModel.full_name.ilike(f"%{search}%"),
                UserModel.email.ilike(f"%{search}%"),
            )
        )
    total = (await db.execute(select(func.count()).select_from(q.subquery()))).scalar_one()
    offset = (page - 1) * page_size
    rows = (await db.execute(q.offset(offset).limit(page_size))).all()

    profiles = []
    for row in rows:
        p = row[0]
        profiles.append({
            "id": p.id, "user_id": p.user_id,
            "user_name": row[1] or getattr(p, "full_name", None),
            "user_email": row[2],
            "date_of_birth": p.date_of_birth.isoformat() if getattr(p, "date_of_birth", None) else None,
            "gender": getattr(p, "gender", None),
            "blood_group": getattr(p, "blood_group", None),
            "height_cm": getattr(p, "height_cm", None),
            "weight_kg": getattr(p, "weight_kg", None),
            "occupation": getattr(p, "occupation", None),
            "marital_status": getattr(p, "marital_status", None),
            "bio": getattr(p, "bio", None),
            "profile_image": getattr(p, "profile_image", None),
            "created_at": p.created_at.isoformat() if getattr(p, "created_at", None) else "",
            "updated_at": p.updated_at.isoformat() if getattr(p, "updated_at", None) else "",
        })

    return {
        "profiles": profiles, "total": total,
        "page": page, "page_size": page_size,
        "total_pages": math.ceil(total / page_size) if total else 1,
    }


@router.get(
    "/profiles/addresses",
    summary="List all user addresses (admin)",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def list_all_addresses(
    country: Optional[str] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
) -> dict:
    from app.users.models import UserAddress
    from app.auth.models import UserModel

    q = (
        select(UserAddress, UserModel.full_name, UserModel.email)
        .join(UserModel, UserModel.id == UserAddress.user_id, isouter=True)
        .order_by(desc(UserAddress.created_at))
    )
    if country:
        q = q.where(UserAddress.country.ilike(f"%{country}%"))

    total = (await db.execute(select(func.count()).select_from(q.subquery()))).scalar_one()
    offset = (page - 1) * page_size
    rows = (await db.execute(q.offset(offset).limit(page_size))).all()

    addresses = []
    for row in rows:
        a = row[0]
        addresses.append({
            "id": a.id, "user_id": a.user_id,
            "user_name": row[1], "user_email": row[2],
            "address_type": getattr(a, "address_type", "home"),
            "label": getattr(a, "label", None),
            "country": getattr(a, "country", None),
            "state": getattr(a, "state", None),
            "district": getattr(a, "district", None),
            "municipality": getattr(a, "municipality", None),
            "street": getattr(a, "street", None),
            "postal_code": getattr(a, "postal_code", None),
            "is_primary": getattr(a, "is_primary", False),
            "created_at": a.created_at.isoformat() if getattr(a, "created_at", None) else "",
        })

    return {
        "addresses": addresses, "total": total,
        "page": page, "page_size": page_size,
        "total_pages": math.ceil(total / page_size) if total else 1,
    }


@router.get(
    "/profiles/emergency-contacts",
    summary="List all emergency contacts (admin)",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def list_all_emergency_contacts(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
) -> dict:
    from app.users.models import EmergencyContact
    from app.auth.models import UserModel

    q = (
        select(EmergencyContact, UserModel.full_name, UserModel.email)
        .join(UserModel, UserModel.id == EmergencyContact.user_id, isouter=True)
        .order_by(desc(EmergencyContact.created_at))
    )
    total = (await db.execute(select(func.count()).select_from(q.subquery()))).scalar_one()
    offset = (page - 1) * page_size
    rows = (await db.execute(q.offset(offset).limit(page_size))).all()

    contacts = []
    for row in rows:
        c = row[0]
        contacts.append({
            "id": c.id, "user_id": c.user_id,
            "user_name": row[1], "user_email": row[2],
            "contact_name": getattr(c, "name", getattr(c, "contact_name", "")),
            "contact_relationship": getattr(c, "relation", getattr(c, "relationship", "")),
            "phone": getattr(c, "phone_number", getattr(c, "phone", "")),
            "email": getattr(c, "email", None),
            "priority": getattr(c, "priority", 1),
            "created_at": c.created_at.isoformat() if getattr(c, "created_at", None) else "",
        })

    return {
        "contacts": contacts, "total": total,
        "page": page, "page_size": page_size,
        "total_pages": math.ceil(total / page_size) if total else 1,
    }


@router.get(
    "/profiles/medical-info",
    summary="List all user medical information (admin)",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def list_all_medical_info(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
) -> dict:
    from app.users.models import MedicalInfo
    from app.auth.models import UserModel

    q = (
        select(MedicalInfo, UserModel.full_name, UserModel.email)
        .join(UserModel, UserModel.id == MedicalInfo.user_id, isouter=True)
        .order_by(desc(MedicalInfo.created_at))
    )
    total = (await db.execute(select(func.count()).select_from(q.subquery()))).scalar_one()
    offset = (page - 1) * page_size
    rows = (await db.execute(q.offset(offset).limit(page_size))).all()

    infos = []
    for row in rows:
        m = row[0]
        infos.append({
            "id": m.id, "user_id": m.user_id,
            "user_name": row[1], "user_email": row[2],
            "blood_group": getattr(m, "blood_group", None),
            "allergies": getattr(m, "allergies", []) or [],
            "chronic_diseases": getattr(m, "chronic_diseases", []) or [],
            "current_medications": getattr(m, "current_medications", []) or [],
            "smoking_status": bool(getattr(m, "smoking_status", False)),
            "alcohol_consumption": bool(getattr(m, "alcohol_consumption", False)),
            "notes": getattr(m, "notes", None),
        })

    return {
        "medical_infos": infos, "total": total,
        "page": page, "page_size": page_size,
        "total_pages": math.ceil(total / page_size) if total else 1,
    }



# ─── Create User (admin) ──────────────────────────────────────────────────────

class _CreateUserBody(schemas.BaseModel):
    full_name: str
    email: str
    password: str
    phone: Optional[str] = None
    role: str = "patient"


@router.post(
    "/users",
    status_code=status.HTTP_201_CREATED,
    summary="Create a new user (admin)",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def create_user(
    payload: _CreateUserBody,
    current_user: AdminUser,
    request: Request,
    db: AsyncSession = Depends(get_db),
) -> dict:
    """Admin-creates a user, bypassing password-strength and confirm_password
    requirements so that the admin can set any password they choose."""
    import uuid
    from app.auth.models import UserModel
    from app.auth.password import hash_password
    from app.auth import repository as auth_repo

    email = payload.email.lower().strip()
    role_val = payload.role.lower()
    if role_val not in ("patient", "doctor", "admin", "super_admin"):
        raise HTTPException(status_code=400, detail="Invalid role")

    # Check for duplicate email
    existing = await auth_repo.get_user_by_email(db, email)
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")

    # Check for duplicate phone if provided
    if payload.phone:
        existing_phone = await auth_repo.get_user_by_phone(db, payload.phone)
        if existing_phone:
            raise HTTPException(status_code=400, detail="Phone already registered")

    user = UserModel(
        id=str(uuid.uuid4()),
        full_name=payload.full_name,
        email=email,
        phone=payload.phone if payload.phone else None,
        password_hash=hash_password(payload.password),
        role=role_val,
        language="en",
        is_active=True,
        email_verified=True,   # admin-created accounts are pre-verified
        phone_verified=bool(payload.phone),
    )
    await auth_repo.create_user(db, user)
    await db.commit()
    await db.refresh(user)

    await ActivityLogService.log(
        db, current_user.id, "user.create", "users", user.id, "User",
        description=f"Admin created {role_val} account for {email}",
        ip_address=request.client.host if request.client else None,
    )
    return {
        "id": user.id,
        "full_name": user.full_name,
        "email": user.email,
        "role": user.role,
        "is_active": user.is_active,
        "email_verified": user.email_verified,
        "created_at": user.created_at.isoformat(),
        "message": f"{role_val.replace('_', ' ').title()} account created successfully",
    }


# ─── Emergency Config (persisted to SystemSettings) ──────────────────────────

class _EmergencyConfigBody(schemas.BaseModel):
    critical_threshold: Optional[int] = None
    high_threshold: Optional[int] = None
    medium_threshold: Optional[int] = None
    auto_sos_threshold: Optional[int] = None
    auto_sos_enabled: Optional[bool] = None
    notify_admin_on_sos: Optional[bool] = None


@router.get(
    "/emergency/config",
    summary="Get emergency risk configuration",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def get_emergency_config_v2(db: AsyncSession = Depends(get_db)) -> dict:
    await SystemSettingsService.seed_defaults(db)
    all_settings = await SystemSettingsService.get_all(db)
    m = {s.key: s.value for s in all_settings.settings}
    return {
        "critical_threshold":  int(m.get("emergency_critical_threshold", "90")),
        "high_threshold":      int(m.get("emergency_high_threshold", "75")),
        "medium_threshold":    int(m.get("emergency_medium_threshold", "50")),
        "auto_sos_threshold":  int(m.get("emergency_auto_sos_threshold", "95")),
        "auto_sos_enabled":    m.get("emergency_auto_sos_enabled", "true").lower() == "true",
        "notify_admin_on_sos": m.get("emergency_notify_admin_on_sos", "true").lower() == "true",
    }


@router.put(
    "/emergency/config",
    summary="Update emergency risk configuration (persisted)",
    dependencies=[Depends(require_role(Role.SUPER_ADMIN))],
)
async def update_emergency_config_v2(
    payload: _EmergencyConfigBody,
    current_user: AdminUser,
    db: AsyncSession = Depends(get_db),
) -> dict:
    field_map = {
        "critical_threshold":  "emergency_critical_threshold",
        "high_threshold":      "emergency_high_threshold",
        "medium_threshold":    "emergency_medium_threshold",
        "auto_sos_threshold":  "emergency_auto_sos_threshold",
        "auto_sos_enabled":    "emergency_auto_sos_enabled",
        "notify_admin_on_sos": "emergency_notify_admin_on_sos",
    }
    updates = payload.model_dump(exclude_none=True)
    for field, key in field_map.items():
        if field in updates:
            await SystemSettingsService.update(
                db, key,
                schemas.SystemSettingUpdate(value=str(updates[field]).lower()),
                current_user.id,
            )
    await ActivityLogService.log(
        db, current_user.id, "emergency.config_update", "emergency",
        None, "SystemSetting", description="Updated emergency risk thresholds",
        severity="warning",
    )
    return {"message": "Emergency configuration updated", "updated": list(updates.keys())}


# ─── Chatbot Config (persisted to SystemSettings) ────────────────────────────

class _ChatbotConfigBody(schemas.BaseModel):
    temperature: Optional[float] = None
    max_tokens: Optional[int] = None
    emergency_detection_enabled: Optional[bool] = None
    context_window: Optional[int] = None
    safety_settings: Optional[str] = None


@router.put(
    "/chatbot/config",
    summary="Update chatbot configuration (persisted)",
    dependencies=[Depends(require_role(Role.SUPER_ADMIN))],
)
async def update_chatbot_config_v2(
    payload: _ChatbotConfigBody,
    current_user: AdminUser,
    db: AsyncSession = Depends(get_db),
) -> dict:
    field_map = {
        "temperature":                  "chatbot_temperature",
        "max_tokens":                   "chatbot_max_tokens",
        "emergency_detection_enabled":  "chatbot_emergency_detection_enabled",
        "context_window":               "chatbot_context_window",
        "safety_settings":              "chatbot_safety_settings",
    }
    updates = payload.model_dump(exclude_none=True)
    for field, key in field_map.items():
        if field in updates:
            val = updates[field]
            await SystemSettingsService.update(
                db, key,
                schemas.SystemSettingUpdate(
                    value=str(val).lower() if isinstance(val, bool) else str(val)
                ),
                current_user.id,
            )
    await ActivityLogService.log(
        db, current_user.id, "chatbot.config_update", "chatbot",
        None, "SystemSetting", description=f"Updated: {list(updates.keys())}",
    )
    return {"message": "Chatbot configuration updated", "updated": list(updates.keys())}


# ─── Symptom Checker Config (persisted to SystemSettings) ────────────────────

class _SymptomConfigBody(schemas.BaseModel):
    confidence_threshold: Optional[float] = None
    emergency_keywords: Optional[list] = None
    risk_thresholds: Optional[dict] = None


@router.put(
    "/symptom-checker/config",
    summary="Update symptom checker configuration (persisted)",
    dependencies=[Depends(require_role(Role.SUPER_ADMIN))],
)
async def update_symptom_checker_config_v2(
    payload: _SymptomConfigBody,
    current_user: AdminUser,
    db: AsyncSession = Depends(get_db),
) -> dict:
    import json as _json
    updates: dict = {}
    if payload.confidence_threshold is not None:
        await SystemSettingsService.update(
            db, "symptom_confidence_threshold",
            schemas.SystemSettingUpdate(value=str(payload.confidence_threshold)),
            current_user.id,
        )
        updates["confidence_threshold"] = payload.confidence_threshold
    if payload.emergency_keywords is not None:
        await SystemSettingsService.update(
            db, "symptom_emergency_keywords",
            schemas.SystemSettingUpdate(value=_json.dumps(payload.emergency_keywords)),
            current_user.id,
        )
        updates["emergency_keywords"] = payload.emergency_keywords
    if payload.risk_thresholds is not None:
        await SystemSettingsService.update(
            db, "symptom_risk_thresholds",
            schemas.SystemSettingUpdate(value=_json.dumps(payload.risk_thresholds)),
            current_user.id,
        )
        updates["risk_thresholds"] = payload.risk_thresholds
    await ActivityLogService.log(
        db, current_user.id, "symptom_checker.config_update", "symptom_checker",
        None, "SystemSetting", description=f"Updated: {list(updates.keys())}",
    )
    return {"message": "Symptom checker configuration updated", "updated": list(updates.keys())}


# ─── Update User Profile (admin) ──────────────────────────────────────────────

class _ProfileUpdateBody(schemas.BaseModel):
    gender: Optional[str] = None
    marital_status: Optional[str] = None
    occupation: Optional[str] = None
    bio: Optional[str] = None


@router.patch(
    "/profiles/{profile_id}",
    summary="Update a user profile (admin)",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def update_user_profile(
    profile_id: str,
    payload: _ProfileUpdateBody,
    current_user: AdminUser,
    request: Request,
    db: AsyncSession = Depends(get_db),
) -> dict:
    from app.users.models import UserProfile
    profile = await db.get(UserProfile, profile_id)
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    updates = payload.model_dump(exclude_none=True)
    for field, value in updates.items():
        setattr(profile, field, value)
    await db.commit()
    await db.refresh(profile)
    await ActivityLogService.log(
        db, current_user.id, "profile.update", "profiles", profile_id, "UserProfile",
        description=f"Updated: {list(updates.keys())}",
        ip_address=request.client.host if request.client else None,
    )
    return {
        "id": profile.id,
        "user_id": profile.user_id,
        "gender": getattr(profile, "gender", None),
        "marital_status": getattr(profile, "marital_status", None),
        "occupation": getattr(profile, "occupation", None),
        "bio": getattr(profile, "bio", None),
        "message": "Profile updated successfully",
    }
