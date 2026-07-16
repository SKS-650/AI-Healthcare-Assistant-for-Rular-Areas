"""Admin API routes — mounted under /api/v1/admin"""

from __future__ import annotations

from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, Request, Response, status
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
    search:    Optional[str]  = Query(None),
    role:      Optional[str]  = Query(None),
    is_active: Optional[bool] = Query(None),
    page:      int            = Query(1, ge=1),
    page_size: int            = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
) -> schemas.AdminUserListResponse:
    return await AdminUserService.list_users(db, search, role, is_active, page, page_size)


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


# ─── Emergency Monitoring ────────────────────────────────────────────────────

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
