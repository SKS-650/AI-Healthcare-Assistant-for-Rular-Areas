"""Admin service layer — all business logic for the admin module."""

from __future__ import annotations

import math
from datetime import datetime, timedelta, timezone
from typing import Any, Optional

from sqlalchemy import case, func, select, desc, and_, or_
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.models import UserModel
from app.emergency.models import EmergencyAssessment, SosEvent
from app.health_education.models import HealthArticle, HealthCategory
from app.medical_chatbot.database.models import Conversation, Message
from app.admin.models import (
    AdminActivityLog,
    AdminNotification,
    DatasetVersion,
    SystemSetting,
)
from app.admin import schemas


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


# ─── Dashboard Service ────────────────────────────────────────────────────────

class DashboardService:

    @staticmethod
    async def get_stats(db: AsyncSession) -> schemas.DashboardStats:
        now = _utcnow()
        today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
        week_start  = today_start - timedelta(days=7)

        total_users        = (await db.execute(select(func.count(UserModel.id)))).scalar_one()
        active_users       = (await db.execute(select(func.count(UserModel.id)).where(UserModel.is_active == True))).scalar_one()
        new_today          = (await db.execute(select(func.count(UserModel.id)).where(UserModel.created_at >= today_start))).scalar_one()
        new_week           = (await db.execute(select(func.count(UserModel.id)).where(UserModel.created_at >= week_start))).scalar_one()
        total_chats        = (await db.execute(select(func.count(Conversation.id)))).scalar_one()
        chats_today        = (await db.execute(select(func.count(Conversation.id)).where(Conversation.created_at >= today_start))).scalar_one()
        total_emergency    = (await db.execute(select(func.count(EmergencyAssessment.id)))).scalar_one()
        emergency_today    = (await db.execute(select(func.count(EmergencyAssessment.id)).where(EmergencyAssessment.created_at >= today_start))).scalar_one()
        high_risk          = (await db.execute(select(func.count(EmergencyAssessment.id)).where(EmergencyAssessment.risk_level.in_(["HIGH", "CRITICAL"])))).scalar_one()
        total_articles     = (await db.execute(select(func.count(HealthArticle.id)))).scalar_one()
        published_articles = (await db.execute(select(func.count(HealthArticle.id)).where(HealthArticle.is_published == True))).scalar_one()
        total_sos          = (await db.execute(select(func.count(SosEvent.id)))).scalar_one()

        return schemas.DashboardStats(
            total_users=total_users,
            active_users=active_users,
            new_users_today=new_today,
            new_users_this_week=new_week,
            total_chatbot_conversations=total_chats,
            chatbot_conversations_today=chats_today,
            total_emergency_assessments=total_emergency,
            emergency_assessments_today=emergency_today,
            high_risk_emergencies=high_risk,
            total_health_articles=total_articles,
            published_articles=published_articles,
            total_symptom_checks=0,
            symptom_checks_today=0,
            total_sos_events=total_sos,
        )

    @staticmethod
    async def get_recent_users(db: AsyncSession, limit: int = 5) -> list[schemas.RecentUser]:
        result = await db.execute(
            select(UserModel).order_by(desc(UserModel.created_at)).limit(limit)
        )
        return [schemas.RecentUser.model_validate(u) for u in result.scalars().all()]

    @staticmethod
    async def get_recent_emergencies(db: AsyncSession, limit: int = 5) -> list[schemas.RecentEmergency]:
        result = await db.execute(
            select(EmergencyAssessment).order_by(desc(EmergencyAssessment.created_at)).limit(limit)
        )
        rows = result.scalars().all()
        out = []
        for ea in rows:
            user_name = None
            if ea.user_id:
                u = await db.get(UserModel, ea.user_id)
                user_name = u.full_name if u else None
            out.append(schemas.RecentEmergency(
                id=ea.id, user_id=ea.user_id, user_name=user_name,
                risk_level=ea.risk_level, risk_score=ea.risk_score,
                possible_emergency=ea.possible_emergency, is_emergency=ea.is_emergency,
                created_at=ea.created_at,
            ))
        return out


    @staticmethod
    async def get_user_growth(db: AsyncSession, days: int = 30) -> list[dict[str, Any]]:
        result = []
        now = _utcnow()
        for i in range(days - 1, -1, -1):
            day = now - timedelta(days=i)
            start = day.replace(hour=0, minute=0, second=0, microsecond=0)
            end   = start + timedelta(days=1)
            count = (await db.execute(
                select(func.count(UserModel.id)).where(
                    and_(UserModel.created_at >= start, UserModel.created_at < end)
                )
            )).scalar_one()
            result.append({"date": start.strftime("%Y-%m-%d"), "count": count})
        return result

    @staticmethod
    async def get_emergency_trend(db: AsyncSession, days: int = 14) -> list[dict[str, Any]]:
        result = []
        now = _utcnow()
        for i in range(days - 1, -1, -1):
            day = now - timedelta(days=i)
            start = day.replace(hour=0, minute=0, second=0, microsecond=0)
            end   = start + timedelta(days=1)
            total  = (await db.execute(select(func.count(EmergencyAssessment.id)).where(and_(EmergencyAssessment.created_at >= start, EmergencyAssessment.created_at < end)))).scalar_one()
            high   = (await db.execute(select(func.count(EmergencyAssessment.id)).where(and_(EmergencyAssessment.created_at >= start, EmergencyAssessment.created_at < end, EmergencyAssessment.risk_level.in_(["HIGH","CRITICAL"]))))).scalar_one()
            result.append({"date": start.strftime("%Y-%m-%d"), "total": total, "high_risk": high})
        return result

    @staticmethod
    async def get_chatbot_trend(db: AsyncSession, days: int = 14) -> list[dict[str, Any]]:
        result = []
        now = _utcnow()
        for i in range(days - 1, -1, -1):
            day = now - timedelta(days=i)
            start = day.replace(hour=0, minute=0, second=0, microsecond=0)
            end   = start + timedelta(days=1)
            count = (await db.execute(select(func.count(Conversation.id)).where(and_(Conversation.created_at >= start, Conversation.created_at < end)))).scalar_one()
            result.append({"date": start.strftime("%Y-%m-%d"), "count": count})
        return result

    @staticmethod
    async def get_dashboard(db: AsyncSession) -> schemas.DashboardResponse:
        stats       = await DashboardService.get_stats(db)
        recent_users = await DashboardService.get_recent_users(db)
        recent_emgs  = await DashboardService.get_recent_emergencies(db)
        user_growth  = await DashboardService.get_user_growth(db)
        emg_trend    = await DashboardService.get_emergency_trend(db)
        chat_trend   = await DashboardService.get_chatbot_trend(db)
        health = schemas.SystemHealth(database="healthy", api="healthy", chatbot="healthy", emergency_system="healthy", overall="healthy")
        return schemas.DashboardResponse(
            stats=stats, recent_users=recent_users, recent_emergencies=recent_emgs,
            system_health=health, user_growth=user_growth,
            emergency_trend=emg_trend, chatbot_trend=chat_trend,
        )


# ─── User Management Service ──────────────────────────────────────────────────

class AdminUserService:

    @staticmethod
    async def list_users(
        db: AsyncSession,
        search: Optional[str] = None,
        role: Optional[str] = None,
        is_active: Optional[bool] = None,
        page: int = 1,
        page_size: int = 20,
    ) -> schemas.AdminUserListResponse:
        q = select(UserModel)
        if search:
            term = f"%{search}%"
            q = q.where(or_(UserModel.full_name.ilike(term), UserModel.email.ilike(term)))
        if role:
            q = q.where(UserModel.role == role)
        if is_active is not None:
            q = q.where(UserModel.is_active == is_active)

        total = (await db.execute(select(func.count()).select_from(q.subquery()))).scalar_one()
        offset = (page - 1) * page_size
        result = await db.execute(q.order_by(desc(UserModel.created_at)).offset(offset).limit(page_size))
        users = [schemas.AdminUserItem.model_validate(u) for u in result.scalars().all()]

        return schemas.AdminUserListResponse(
            users=users, total=total, page=page,
            page_size=page_size, total_pages=math.ceil(total / page_size) if total else 1,
        )

    @staticmethod
    async def get_user_detail(db: AsyncSession, user_id: str) -> Optional[schemas.AdminUserDetail]:
        user = await db.get(UserModel, user_id)
        if not user:
            return None
        conv_count = (await db.execute(select(func.count(Conversation.id)).where(Conversation.user_id == user_id))).scalar_one()
        emg_count  = (await db.execute(select(func.count(EmergencyAssessment.id)).where(EmergencyAssessment.user_id == user_id))).scalar_one()
        detail = schemas.AdminUserDetail.model_validate(user)
        detail.total_conversations = conv_count
        detail.total_emergency_assessments = emg_count
        return detail

    @staticmethod
    async def update_user_status(db: AsyncSession, user_id: str, is_active: bool) -> Optional[schemas.AdminUserItem]:
        user = await db.get(UserModel, user_id)
        if not user:
            return None
        user.is_active = is_active
        await db.commit()
        await db.refresh(user)
        return schemas.AdminUserItem.model_validate(user)

    @staticmethod
    async def update_user_role(db: AsyncSession, user_id: str, role: str) -> Optional[schemas.AdminUserItem]:
        user = await db.get(UserModel, user_id)
        if not user:
            return None
        user.role = role
        await db.commit()
        await db.refresh(user)
        return schemas.AdminUserItem.model_validate(user)

    @staticmethod
    async def delete_user(db: AsyncSession, user_id: str) -> bool:
        user = await db.get(UserModel, user_id)
        if not user:
            return False
        await db.delete(user)
        await db.commit()
        return True


# ─── Emergency Service ────────────────────────────────────────────────────────

class AdminEmergencyService:

    @staticmethod
    async def list_emergencies(
        db: AsyncSession,
        risk_level: Optional[str] = None,
        is_emergency: Optional[bool] = None,
        page: int = 1,
        page_size: int = 20,
    ) -> schemas.AdminEmergencyListResponse:
        q = select(EmergencyAssessment)
        if risk_level:
            q = q.where(EmergencyAssessment.risk_level == risk_level.upper())
        if is_emergency is not None:
            q = q.where(EmergencyAssessment.is_emergency == is_emergency)

        total  = (await db.execute(select(func.count()).select_from(q.subquery()))).scalar_one()
        offset = (page - 1) * page_size
        result = await db.execute(q.order_by(desc(EmergencyAssessment.created_at)).offset(offset).limit(page_size))
        rows = result.scalars().all()

        items = []
        for ea in rows:
            user_name = user_email = None
            if ea.user_id:
                u = await db.get(UserModel, ea.user_id)
                if u:
                    user_name, user_email = u.full_name, u.email
            sos_count = (await db.execute(select(func.count(SosEvent.id)).where(SosEvent.assessment_id == ea.id))).scalar_one()
            items.append(schemas.AdminEmergencyItem(
                id=ea.id, user_id=ea.user_id, user_name=user_name, user_email=user_email,
                age=ea.age, gender=ea.gender, symptoms=ea.symptoms or [],
                risk_level=ea.risk_level, risk_score=ea.risk_score,
                is_emergency=ea.is_emergency, emergency_type=ea.emergency_type,
                possible_emergency=ea.possible_emergency, sos_required=ea.sos_required,
                sos_count=sos_count, created_at=ea.created_at,
            ))

        return schemas.AdminEmergencyListResponse(
            emergencies=items, total=total, page=page,
            page_size=page_size, total_pages=math.ceil(total / page_size) if total else 1,
        )

    @staticmethod
    async def get_stats(db: AsyncSession) -> schemas.EmergencyStatsResponse:
        now   = _utcnow()
        today = now.replace(hour=0, minute=0, second=0, microsecond=0)
        week  = today - timedelta(days=7)
        total    = (await db.execute(select(func.count(EmergencyAssessment.id)))).scalar_one()
        critical = (await db.execute(select(func.count(EmergencyAssessment.id)).where(EmergencyAssessment.risk_level == "CRITICAL"))).scalar_one()
        high     = (await db.execute(select(func.count(EmergencyAssessment.id)).where(EmergencyAssessment.risk_level == "HIGH"))).scalar_one()
        medium   = (await db.execute(select(func.count(EmergencyAssessment.id)).where(EmergencyAssessment.risk_level == "MEDIUM"))).scalar_one()
        low      = (await db.execute(select(func.count(EmergencyAssessment.id)).where(EmergencyAssessment.risk_level == "LOW"))).scalar_one()
        sos      = (await db.execute(select(func.count(SosEvent.id)))).scalar_one()
        today_c  = (await db.execute(select(func.count(EmergencyAssessment.id)).where(EmergencyAssessment.created_at >= today))).scalar_one()
        week_c   = (await db.execute(select(func.count(EmergencyAssessment.id)).where(EmergencyAssessment.created_at >= week))).scalar_one()
        return schemas.EmergencyStatsResponse(
            total=total, critical=critical, high=high, medium=medium, low=low,
            sos_triggered=sos, today_count=today_c, this_week=week_c,
        )


# ─── Chatbot Service ──────────────────────────────────────────────────────────

class AdminChatbotService:

    @staticmethod
    async def list_conversations(
        db: AsyncSession,
        search: Optional[str] = None,
        language: Optional[str] = None,
        has_emergency: Optional[bool] = None,
        page: int = 1,
        page_size: int = 20,
    ) -> schemas.AdminConversationListResponse:
        q = select(Conversation)
        if search:
            q = q.where(Conversation.title.ilike(f"%{search}%"))
        if language:
            q = q.where(Conversation.language == language)

        total  = (await db.execute(select(func.count()).select_from(q.subquery()))).scalar_one()
        offset = (page - 1) * page_size
        result = await db.execute(q.order_by(desc(Conversation.updated_at)).offset(offset).limit(page_size))
        rows = result.scalars().all()

        items = []
        for conv in rows:
            user_name = None
            u = await db.get(UserModel, conv.user_id)
            if u: user_name = u.full_name
            msg_count = (await db.execute(select(func.count(Message.id)).where(Message.conversation_id == conv.id))).scalar_one()
            emg_count = (await db.execute(select(func.count(Message.id)).where(and_(Message.conversation_id == conv.id, Message.emergency_detected == True)))).scalar_one()
            if has_emergency is not None and bool(emg_count) != has_emergency:
                continue
            items.append(schemas.AdminConversationItem(
                id=conv.id, user_id=conv.user_id, user_name=user_name,
                title=conv.title, language=conv.language,
                message_count=msg_count, emergency_count=emg_count,
                is_active=conv.is_active,
                created_at=conv.created_at, updated_at=conv.updated_at,
            ))
        return schemas.AdminConversationListResponse(
            conversations=items, total=total, page=page,
            page_size=page_size, total_pages=math.ceil(total / page_size) if total else 1,
        )

    @staticmethod
    async def get_stats(db: AsyncSession) -> schemas.ChatbotStatsResponse:
        now   = _utcnow()
        today = now.replace(hour=0, minute=0, second=0, microsecond=0)
        total   = (await db.execute(select(func.count(Conversation.id)))).scalar_one()
        active  = (await db.execute(select(func.count(Conversation.id)).where(Conversation.is_active == True))).scalar_one()
        t_msgs  = (await db.execute(select(func.count(Message.id)))).scalar_one()
        e_msgs  = (await db.execute(select(func.count(Message.id)).where(Message.emergency_detected == True))).scalar_one()
        today_c = (await db.execute(select(func.count(Conversation.id)).where(Conversation.created_at >= today))).scalar_one()
        avg = round(t_msgs / total, 2) if total else 0.0

        lang_result = await db.execute(select(Conversation.language, func.count(Conversation.id)).group_by(Conversation.language))
        lang_dist = {row[0]: row[1] for row in lang_result.all()}

        return schemas.ChatbotStatsResponse(
            total_conversations=total, active_conversations=active,
            total_messages=t_msgs, emergency_messages=e_msgs,
            avg_messages_per_conversation=avg,
            today_conversations=today_c, language_distribution=lang_dist,
        )


# ─── Education Article Service ────────────────────────────────────────────────

class AdminEducationService:

    @staticmethod
    async def list_articles(
        db: AsyncSession,
        search: Optional[str] = None,
        category_id: Optional[str] = None,
        language: Optional[str] = None,
        is_published: Optional[bool] = None,
        page: int = 1,
        page_size: int = 20,
    ) -> schemas.AdminArticleListResponse:
        q = select(HealthArticle)
        if search:
            q = q.where(or_(HealthArticle.title.ilike(f"%{search}%"), HealthArticle.summary.ilike(f"%{search}%")))
        if category_id:
            q = q.where(HealthArticle.category_id == category_id)
        if language:
            q = q.where(HealthArticle.language == language)
        if is_published is not None:
            q = q.where(HealthArticle.is_published == is_published)

        total  = (await db.execute(select(func.count()).select_from(q.subquery()))).scalar_one()
        offset = (page - 1) * page_size
        result = await db.execute(q.order_by(desc(HealthArticle.created_at)).offset(offset).limit(page_size))
        articles = result.scalars().all()

        items = []
        for a in articles:
            cat_name = None
            if a.category_id:
                cat = await db.get(HealthCategory, a.category_id)
                if cat: cat_name = cat.name
            items.append(schemas.AdminArticleResponse(
                id=a.id, title=a.title, summary=a.summary, content=a.content,
                category_id=a.category_id, category_name=cat_name,
                language=a.language, author=a.author, source=a.source,
                read_time_min=a.read_time_min, tags=a.tags or [],
                is_featured=a.is_featured, is_published=a.is_published,
                view_count=a.view_count, bookmark_count=a.bookmark_count,
                emoji=a.emoji, created_at=a.created_at, updated_at=a.updated_at,
            ))

        return schemas.AdminArticleListResponse(
            articles=items, total=total, page=page,
            page_size=page_size, total_pages=math.ceil(total / page_size) if total else 1,
        )

    @staticmethod
    async def create_article(db: AsyncSession, payload: schemas.AdminArticleCreate, admin_id: str) -> schemas.AdminArticleResponse:
        import uuid, re
        slug = re.sub(r"[^a-z0-9]+", "-", payload.title.lower()).strip("-") + "-" + str(uuid.uuid4())[:8]
        article = HealthArticle(
            title=payload.title, summary=payload.summary, content=payload.content,
            category_id=payload.category_id, language=payload.language,
            author=payload.author, source=payload.source,
            read_time_min=payload.read_time_min, tags=payload.tags,
            is_featured=payload.is_featured, is_published=payload.is_published,
            emoji=payload.emoji, slug=slug,
        )
        db.add(article)
        await db.commit()
        await db.refresh(article)
        return schemas.AdminArticleResponse(
            id=article.id, title=article.title, summary=article.summary,
            content=article.content, category_id=article.category_id, category_name=None,
            language=article.language, author=article.author, source=article.source,
            read_time_min=article.read_time_min, tags=article.tags or [],
            is_featured=article.is_featured, is_published=article.is_published,
            view_count=article.view_count, bookmark_count=article.bookmark_count,
            emoji=article.emoji, created_at=article.created_at, updated_at=article.updated_at,
        )

    @staticmethod
    async def update_article(db: AsyncSession, article_id: str, payload: schemas.AdminArticleUpdate) -> Optional[schemas.AdminArticleResponse]:
        article = await db.get(HealthArticle, article_id)
        if not article:
            return None
        for field, val in payload.model_dump(exclude_none=True).items():
            setattr(article, field, val)
        await db.commit()
        await db.refresh(article)
        return schemas.AdminArticleResponse(
            id=article.id, title=article.title, summary=article.summary,
            content=article.content, category_id=article.category_id, category_name=None,
            language=article.language, author=article.author, source=article.source,
            read_time_min=article.read_time_min, tags=article.tags or [],
            is_featured=article.is_featured, is_published=article.is_published,
            view_count=article.view_count, bookmark_count=article.bookmark_count,
            emoji=article.emoji, created_at=article.created_at, updated_at=article.updated_at,
        )

    @staticmethod
    async def delete_article(db: AsyncSession, article_id: str) -> bool:
        article = await db.get(HealthArticle, article_id)
        if not article:
            return False
        await db.delete(article)
        await db.commit()
        return True


# ─── Activity Log Service ─────────────────────────────────────────────────────

class ActivityLogService:

    @staticmethod
    async def log(
        db: AsyncSession,
        admin_id: Optional[str],
        action: str,
        module: str,
        target_id: Optional[str] = None,
        target_type: Optional[str] = None,
        description: Optional[str] = None,
        ip_address: Optional[str] = None,
        severity: str = "info",
        extra_data: Optional[dict] = None,
    ) -> None:
        entry = AdminActivityLog(
            admin_id=admin_id, action=action, module=module,
            target_id=target_id, target_type=target_type,
            description=description, ip_address=ip_address,
            severity=severity, extra_data=extra_data,
        )
        db.add(entry)
        await db.commit()

    @staticmethod
    async def list_logs(
        db: AsyncSession,
        module: Optional[str] = None,
        severity: Optional[str] = None,
        admin_id: Optional[str] = None,
        page: int = 1,
        page_size: int = 50,
    ) -> schemas.ActivityLogListResponse:
        q = select(AdminActivityLog)
        if module:
            q = q.where(AdminActivityLog.module == module)
        if severity:
            q = q.where(AdminActivityLog.severity == severity)
        if admin_id:
            q = q.where(AdminActivityLog.admin_id == admin_id)

        total  = (await db.execute(select(func.count()).select_from(q.subquery()))).scalar_one()
        offset = (page - 1) * page_size
        result = await db.execute(q.order_by(desc(AdminActivityLog.created_at)).offset(offset).limit(page_size))
        rows = result.scalars().all()

        items = []
        for log in rows:
            admin_name = None
            if log.admin_id:
                u = await db.get(UserModel, log.admin_id)
                if u: admin_name = u.full_name
            items.append(schemas.ActivityLogItem(
                id=log.id, admin_id=log.admin_id, admin_name=admin_name,
                action=log.action, module=log.module, target_id=log.target_id,
                target_type=log.target_type, description=log.description,
                ip_address=log.ip_address, severity=log.severity, created_at=log.created_at,
            ))

        return schemas.ActivityLogListResponse(
            logs=items, total=total, page=page,
            page_size=page_size, total_pages=math.ceil(total / page_size) if total else 1,
        )


# ─── Settings Service ─────────────────────────────────────────────────────────

class SystemSettingsService:

    @staticmethod
    async def get_all(db: AsyncSession) -> schemas.SystemSettingsResponse:
        result = await db.execute(select(SystemSetting).order_by(SystemSetting.category, SystemSetting.key))
        settings = [schemas.SystemSettingItem.model_validate(s) for s in result.scalars().all()]
        categories = list({s.category for s in settings})
        return schemas.SystemSettingsResponse(settings=settings, categories=categories)

    @staticmethod
    async def update(db: AsyncSession, key: str, payload: schemas.SystemSettingUpdate, admin_id: str) -> Optional[schemas.SystemSettingItem]:
        result = await db.execute(select(SystemSetting).where(SystemSetting.key == key))
        setting = result.scalar_one_or_none()
        if not setting:
            return None
        if payload.value is not None:
            setting.value = payload.value
        if payload.description is not None:
            setting.description = payload.description
        setting.updated_by = admin_id
        await db.commit()
        await db.refresh(setting)
        return schemas.SystemSettingItem.model_validate(setting)

    @staticmethod
    async def seed_defaults(db: AsyncSession) -> None:
        defaults = [
            ("app_name", "AI Healthcare Assistant", "string", "general", "Application name"),
            ("app_version", "1.0.0", "string", "general", "Application version"),
            ("maintenance_mode", "false", "bool", "general", "Enable maintenance mode"),
            ("emergency_threshold_high", "70", "int", "ai", "Risk score threshold for HIGH level"),
            ("emergency_threshold_critical", "85", "int", "ai", "Risk score threshold for CRITICAL level"),
            ("chatbot_max_tokens", "1000", "int", "ai", "Max tokens per chatbot response"),
            ("chatbot_temperature", "0.7", "float", "ai", "Chatbot generation temperature"),
            ("session_timeout_minutes", "60", "int", "security", "Admin session timeout in minutes"),
            ("max_login_attempts", "5", "int", "security", "Max failed login attempts before lockout"),
            ("supported_languages", '["en","ne","hi"]', "json", "general", "Supported app languages"),
        ]
        for key, value, vtype, cat, desc in defaults:
            existing = (await db.execute(select(SystemSetting).where(SystemSetting.key == key))).scalar_one_or_none()
            if not existing:
                db.add(SystemSetting(key=key, value=value, value_type=vtype, category=cat, description=desc))
        await db.commit()


# ─── Reports Service ──────────────────────────────────────────────────────────

class ReportsService:

    @staticmethod
    async def get_reports(db: AsyncSession, days: int = 30) -> schemas.ReportsResponse:
        user_trend  = await DashboardService.get_user_growth(db, days)
        emg_trend   = await DashboardService.get_emergency_trend(db, days)
        chat_trend  = await DashboardService.get_chatbot_trend(db, days)

        reg_trend = [schemas.UserRegistrationTrend(date=d["date"], count=d["count"]) for d in user_trend]

        risk_levels = ["LOW", "MEDIUM", "HIGH", "CRITICAL"]
        total_e = (await db.execute(select(func.count(EmergencyAssessment.id)))).scalar_one() or 1
        risk_dist = []
        for lvl in risk_levels:
            cnt = (await db.execute(select(func.count(EmergencyAssessment.id)).where(EmergencyAssessment.risk_level == lvl))).scalar_one()
            risk_dist.append(schemas.RiskDistribution(risk_level=lvl, count=cnt, percentage=round(cnt/total_e*100, 1)))

        return schemas.ReportsResponse(
            user_registration_trend=reg_trend,
            symptom_frequency=[],
            risk_distribution=risk_dist,
            chatbot_daily_usage=chat_trend,
            emergency_weekly=emg_trend[-7:],
            education_engagement=[],
        )


# ─── Symptom Analytics Service ───────────────────────────────────────────────

class SymptomAnalyticsService:
    """Aggregates symptom and disease-prediction data from EmergencyAssessments."""

    @staticmethod
    async def get_stats(db: AsyncSession) -> dict[str, Any]:
        now = _utcnow()
        today = now.replace(hour=0, minute=0, second=0, microsecond=0)
        week  = today - timedelta(days=7)

        total   = (await db.execute(select(func.count(EmergencyAssessment.id)))).scalar_one()
        today_c = (await db.execute(
            select(func.count(EmergencyAssessment.id)).where(EmergencyAssessment.created_at >= today)
        )).scalar_one()
        week_c  = (await db.execute(
            select(func.count(EmergencyAssessment.id)).where(EmergencyAssessment.created_at >= week)
        )).scalar_one()
        emergency_c = (await db.execute(
            select(func.count(EmergencyAssessment.id)).where(EmergencyAssessment.is_emergency == True)
        )).scalar_one()
        avg_risk = (await db.execute(
            select(func.avg(EmergencyAssessment.risk_score))
        )).scalar_one() or 0.0

        return {
            "total_assessments": total,
            "today_assessments": today_c,
            "week_assessments": week_c,
            "emergency_cases": emergency_c,
            "avg_risk_score": round(float(avg_risk), 1),
        }

    @staticmethod
    async def get_symptom_frequency(db: AsyncSession, limit: int = 20) -> list[dict[str, Any]]:
        """Explode JSON symptom arrays and count occurrences."""
        result = await db.execute(
            select(EmergencyAssessment.symptoms).where(EmergencyAssessment.symptoms.isnot(None))
        )
        rows = result.scalars().all()
        freq: dict[str, int] = {}
        for symptom_list in rows:
            if isinstance(symptom_list, list):
                for sym in symptom_list:
                    s = str(sym).strip().lower()
                    if s:
                        freq[s] = freq.get(s, 0) + 1
        sorted_items = sorted(freq.items(), key=lambda x: x[1], reverse=True)[:limit]
        return [{"symptom": s, "count": c} for s, c in sorted_items]

    @staticmethod
    async def get_symptom_trend(db: AsyncSession, days: int = 30) -> list[dict[str, Any]]:
        result = []
        now = _utcnow()
        for i in range(days - 1, -1, -1):
            day = now - timedelta(days=i)
            start = day.replace(hour=0, minute=0, second=0, microsecond=0)
            end   = start + timedelta(days=1)
            total = (await db.execute(
                select(func.count(EmergencyAssessment.id)).where(
                    and_(EmergencyAssessment.created_at >= start, EmergencyAssessment.created_at < end)
                )
            )).scalar_one()
            emergency = (await db.execute(
                select(func.count(EmergencyAssessment.id)).where(
                    and_(EmergencyAssessment.created_at >= start,
                         EmergencyAssessment.created_at < end,
                         EmergencyAssessment.is_emergency == True)
                )
            )).scalar_one()
            result.append({
                "date": start.strftime("%Y-%m-%d"),
                "total": total,
                "emergency": emergency,
            })
        return result

    @staticmethod
    async def get_risk_distribution(db: AsyncSession) -> list[dict[str, Any]]:
        levels = ["LOW", "MEDIUM", "HIGH", "CRITICAL"]
        total = (await db.execute(select(func.count(EmergencyAssessment.id)))).scalar_one() or 1
        result = []
        for lvl in levels:
            cnt = (await db.execute(
                select(func.count(EmergencyAssessment.id)).where(EmergencyAssessment.risk_level == lvl)
            )).scalar_one()
            result.append({
                "risk_level": lvl,
                "count": cnt,
                "percentage": round(cnt / total * 100, 1),
            })
        return result

    @staticmethod
    async def get_gender_distribution(db: AsyncSession) -> list[dict[str, Any]]:
        result = await db.execute(
            select(EmergencyAssessment.gender, func.count(EmergencyAssessment.id))
            .where(EmergencyAssessment.gender.isnot(None))
            .group_by(EmergencyAssessment.gender)
        )
        return [{"gender": r[0] or "unknown", "count": r[1]} for r in result.all()]

    @staticmethod
    async def get_age_distribution(db: AsyncSession) -> list[dict[str, Any]]:
        """Group ages into buckets: 0-17, 18-30, 31-45, 46-60, 60+."""
        buckets = [
            ("0-17",  0,  17),
            ("18-30", 18, 30),
            ("31-45", 31, 45),
            ("46-60", 46, 60),
            ("60+",   61, 999),
        ]
        result = []
        for label, lo, hi in buckets:
            cnt = (await db.execute(
                select(func.count(EmergencyAssessment.id)).where(
                    and_(EmergencyAssessment.age >= lo, EmergencyAssessment.age <= hi)
                )
            )).scalar_one()
            result.append({"age_group": label, "count": cnt})
        return result

    @staticmethod
    async def get_emergency_types(db: AsyncSession) -> list[dict[str, Any]]:
        result = await db.execute(
            select(EmergencyAssessment.emergency_type, func.count(EmergencyAssessment.id))
            .where(EmergencyAssessment.emergency_type.isnot(None))
            .group_by(EmergencyAssessment.emergency_type)
            .order_by(func.count(EmergencyAssessment.id).desc())
            .limit(10)
        )
        return [{"type": r[0], "count": r[1]} for r in result.all()]


# ─── Dataset Management Service ───────────────────────────────────────────────

class DatasetService:
    """Manages dataset version records in the dataset_versions table."""

    @staticmethod
    async def list_datasets(
        db: AsyncSession,
        dataset_type: Optional[str] = None,
        page: int = 1,
        page_size: int = 20,
    ) -> dict[str, Any]:
        q = select(DatasetVersion)
        if dataset_type:
            q = q.where(DatasetVersion.dataset_type == dataset_type)

        total  = (await db.execute(select(func.count()).select_from(q.subquery()))).scalar_one()
        offset = (page - 1) * page_size
        result = await db.execute(q.order_by(desc(DatasetVersion.created_at)).offset(offset).limit(page_size))
        rows = result.scalars().all()

        items = []
        for d in rows:
            uploader_name = None
            if d.uploaded_by:
                u = await db.get(UserModel, d.uploaded_by)
                if u:
                    uploader_name = u.full_name
            items.append({
                "id": d.id,
                "name": d.name,
                "dataset_type": d.dataset_type,
                "version": d.version,
                "file_size_kb": d.file_size_kb,
                "record_count": d.record_count,
                "description": d.description,
                "is_active": d.is_active,
                "uploaded_by": d.uploaded_by,
                "uploader_name": uploader_name,
                "created_at": d.created_at.isoformat(),
            })

        import math
        return {
            "datasets": items,
            "total": total,
            "page": page,
            "page_size": page_size,
            "total_pages": math.ceil(total / page_size) if total else 1,
        }

    @staticmethod
    async def get_stats(db: AsyncSession) -> dict[str, Any]:
        total    = (await db.execute(select(func.count(DatasetVersion.id)))).scalar_one()
        active   = (await db.execute(
            select(func.count(DatasetVersion.id)).where(DatasetVersion.is_active == True)
        )).scalar_one()
        types_result = await db.execute(
            select(DatasetVersion.dataset_type, func.count(DatasetVersion.id))
            .group_by(DatasetVersion.dataset_type)
        )
        type_counts = {r[0]: r[1] for r in types_result.all()}
        return {
            "total_datasets": total,
            "active_datasets": active,
            "inactive_datasets": total - active,
            "type_counts": type_counts,
        }

    @staticmethod
    async def create_dataset(
        db: AsyncSession,
        name: str,
        dataset_type: str,
        version: str,
        description: Optional[str],
        admin_id: str,
        file_size_kb: Optional[int] = None,
        record_count: Optional[int] = None,
    ) -> dict[str, Any]:
        dataset = DatasetVersion(
            name=name,
            dataset_type=dataset_type,
            version=version,
            description=description,
            uploaded_by=admin_id,
            file_size_kb=file_size_kb,
            record_count=record_count,
            is_active=False,
        )
        db.add(dataset)
        await db.commit()
        await db.refresh(dataset)
        return {
            "id": dataset.id,
            "name": dataset.name,
            "dataset_type": dataset.dataset_type,
            "version": dataset.version,
            "file_size_kb": dataset.file_size_kb,
            "record_count": dataset.record_count,
            "description": dataset.description,
            "is_active": dataset.is_active,
            "uploaded_by": dataset.uploaded_by,
            "uploader_name": None,
            "created_at": dataset.created_at.isoformat(),
        }

    @staticmethod
    async def activate_dataset(db: AsyncSession, dataset_id: str) -> Optional[dict[str, Any]]:
        """Activate a dataset version and deactivate others of the same type."""
        dataset = await db.get(DatasetVersion, dataset_id)
        if not dataset:
            return None
        # Deactivate all others of same type
        others = await db.execute(
            select(DatasetVersion).where(
                and_(DatasetVersion.dataset_type == dataset.dataset_type,
                     DatasetVersion.id != dataset_id)
            )
        )
        for other in others.scalars().all():
            other.is_active = False
        dataset.is_active = True
        await db.commit()
        await db.refresh(dataset)
        return {
            "id": dataset.id, "name": dataset.name,
            "dataset_type": dataset.dataset_type, "version": dataset.version,
            "file_size_kb": dataset.file_size_kb, "record_count": dataset.record_count,
            "description": dataset.description, "is_active": dataset.is_active,
            "uploaded_by": dataset.uploaded_by, "uploader_name": None,
            "created_at": dataset.created_at.isoformat(),
        }

    @staticmethod
    async def delete_dataset(db: AsyncSession, dataset_id: str) -> bool:
        dataset = await db.get(DatasetVersion, dataset_id)
        if not dataset:
            return False
        await db.delete(dataset)
        await db.commit()
        return True


# ─── Notifications Service ────────────────────────────────────────────────────

class NotificationService:

    @staticmethod
    async def list_notifications(db: AsyncSession) -> schemas.NotificationListResponse:
        result = await db.execute(select(AdminNotification).order_by(desc(AdminNotification.created_at)).limit(50))
        notes = [schemas.NotificationItem.model_validate(n) for n in result.scalars().all()]
        unread = sum(1 for n in notes if not n.is_read)
        return schemas.NotificationListResponse(notifications=notes, unread_count=unread)

    @staticmethod
    async def mark_read(db: AsyncSession, notification_id: str) -> bool:
        n = await db.get(AdminNotification, notification_id)
        if not n:
            return False
        n.is_read = True
        await db.commit()
        return True
