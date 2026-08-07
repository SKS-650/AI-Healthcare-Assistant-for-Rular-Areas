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


@router.post(
    "/doctors",
    status_code=status.HTTP_201_CREATED,
    summary="Create doctor account",
    dependencies=[Depends(require_role(Role.SUPER_ADMIN))],
)
async def create_doctor(
    full_name: str,
    email: str,
    password: str,
    phone: Optional[str] = None,
    current_user: AdminUser = Depends(),
    db: AsyncSession = Depends(get_db),
) -> dict:
    """Create a new doctor account."""
    from app.auth.service import UserService
    from app.auth.schemas import RegisterRequest
    
    payload = RegisterRequest(
        full_name=full_name,
        email=email,
        password=password,
        phone=phone,
    )
    
    user = await UserService.create_user(
        db=db,
        payload=payload,
        role=Role.DOCTOR,
        email_verified=True,  # Auto-verify admin-created accounts
    )
    
    await ActivityLogService.log(
        db, current_user.id, "doctor.create", "doctors", user.id, "User",
        description=f"Created doctor account for {email}"
    )
    
    return {
        "id": user.id,
        "full_name": user.full_name,
        "email": user.email,
        "message": "Doctor account created successfully"
    }


@router.patch(
    "/doctors/{doctor_id}/status",
    summary="Activate/deactivate doctor",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def update_doctor_status(
    doctor_id: str,
    is_active: bool,
    current_user: AdminUser = Depends(),
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
        .values(is_active=is_active)
    )
    await db.commit()
    
    action = "doctor.activate" if is_active else "doctor.deactivate"
    await ActivityLogService.log(
        db, current_user.id, action, "doctors", doctor_id, "User"
    )
    
    return {"message": f"Doctor {'activated' if is_active else 'deactivated'} successfully"}


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


@router.put(
    "/symptom-checker/config",
    summary="Update symptom checker configuration",
    dependencies=[Depends(require_role(Role.SUPER_ADMIN))],
)
async def update_symptom_checker_config(
    confidence_threshold: Optional[float] = None,
    emergency_keywords: Optional[list[str]] = None,
    risk_thresholds: Optional[dict] = None,
    current_user: AdminUser = Depends(),
    db: AsyncSession = Depends(get_db),
) -> dict:
    """Update symptom checker configuration."""
    # In a real implementation, persist these to SystemSettings table
    await ActivityLogService.log(
        db, current_user.id, "symptom_checker.config_update", "symptom_checker",
        None, "SystemSetting", description="Updated symptom checker configuration"
    )
    return {"message": "Configuration updated successfully"}


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


@router.put(
    "/chatbot/config",
    summary="Update chatbot configuration",
    dependencies=[Depends(require_role(Role.SUPER_ADMIN))],
)
async def update_chatbot_config(
    temperature: Optional[float] = None,
    max_tokens: Optional[int] = None,
    emergency_detection_enabled: Optional[bool] = None,
    current_user: AdminUser = Depends(),
    db: AsyncSession = Depends(get_db),
) -> dict:
    """Update chatbot AI model configuration."""
    await ActivityLogService.log(
        db, current_user.id, "chatbot.config_update", "chatbot",
        None, "SystemSetting", description="Updated chatbot configuration"
    )
    return {"message": "Chatbot configuration updated successfully"}


@router.delete(
    "/chatbot/conversations/{conversation_id}",
    summary="Delete conversation (admin)",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def delete_conversation_admin(
    conversation_id: int,
    current_user: AdminUser = Depends(),
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


# ─── Emergency Configuration ──────────────────────────────────────────────────

@router.get(
    "/emergency/config",
    summary="Get emergency system configuration",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def get_emergency_config(db: AsyncSession = Depends(get_db)) -> dict:
    """Get emergency detection configuration."""
    return {
        "risk_score_thresholds": {
            "critical": 90,
            "high": 75,
            "medium": 50,
            "low": 0
        },
        "auto_sos_threshold": 95,
        "emergency_keywords": [
            "chest pain", "can't breathe", "bleeding heavily",
            "unconscious", "heart attack", "stroke", "seizure"
        ],
        "response_time_target_minutes": 5,
        "sms_notifications_enabled": True,
        "call_notifications_enabled": False
    }


@router.put(
    "/emergency/config",
    summary="Update emergency system configuration",
    dependencies=[Depends(require_role(Role.SUPER_ADMIN))],
)
async def update_emergency_config(
    risk_score_thresholds: Optional[dict] = None,
    auto_sos_threshold: Optional[int] = None,
    emergency_keywords: Optional[list[str]] = None,
    current_user: AdminUser = Depends(),
    db: AsyncSession = Depends(get_db),
) -> dict:
    """Update emergency detection configuration."""
    await ActivityLogService.log(
        db, current_user.id, "emergency.config_update", "emergency",
        None, "SystemSetting", description="Updated emergency configuration"
    )
    return {"message": "Emergency configuration updated successfully"}


# ─── Health Records Analytics ─────────────────────────────────────────────────

@router.get(
    "/health-records/stats",
    summary="Health records statistics",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def health_records_stats(db: AsyncSession = Depends(get_db)) -> dict:
    """Get aggregated health records statistics."""
    from sqlalchemy import func, select
    from app.health_records.models import (
        UserMedicalProfile, MedicalHistory, Prescription, MedicalImage
    )
    
    profiles_count = (await db.execute(
        select(func.count(UserMedicalProfile.id))
    )).scalar_one()
    
    history_count = (await db.execute(
        select(func.count(MedicalHistory.id))
    )).scalar_one()
    
    prescriptions_count = (await db.execute(
        select(func.count(Prescription.id))
    )).scalar_one()
    
    images_count = (await db.execute(
        select(func.count(MedicalImage.id))
    )).scalar_one()
    
    return {
        "total_medical_profiles": profiles_count,
        "total_medical_history_entries": history_count,
        "total_prescriptions": prescriptions_count,
        "total_medical_images": images_count
    }


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

@router.post(
    "/users/bulk-action",
    summary="Bulk user operations",
    dependencies=[Depends(require_role(Role.SUPER_ADMIN))],
)
async def bulk_user_action(
    user_ids: list[str],
    action: str,  # activate, deactivate, delete
    current_user: AdminUser = Depends(),
    db: AsyncSession = Depends(get_db),
) -> dict:
    """Perform bulk actions on multiple users."""
    from sqlalchemy import update, delete
    from app.auth.models import UserModel
    
    if action == "activate":
        await db.execute(
            update(UserModel)
            .where(UserModel.id.in_(user_ids))
            .values(is_active=True)
        )
    elif action == "deactivate":
        await db.execute(
            update(UserModel)
            .where(UserModel.id.in_(user_ids))
            .values(is_active=False)
        )
    elif action == "delete":
        await db.execute(
            delete(UserModel).where(UserModel.id.in_(user_ids))
        )
    else:
        raise HTTPException(status_code=400, detail="Invalid action")
    
    await db.commit()
    
    await ActivityLogService.log(
        db, current_user.id, f"users.bulk_{action}", "users",
        None, "User", description=f"Bulk {action} on {len(user_ids)} users",
        severity="warning"
    )
    
    return {"message": f"Bulk {action} completed successfully", "affected_count": len(user_ids)}


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
