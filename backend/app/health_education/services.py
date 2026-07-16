"""
Business logic services for the Health Education module.

Services:
  - SeedService          – idempotent DB seeding (categories + articles)
  - CategoryService      – CRUD for HealthCategory
  - ArticleService       – list, detail, search, featured, recommendations
  - BookmarkService      – add / remove / list user bookmarks
  - ReadingHistoryService – track reading progress
  - DashboardService     – compose the education dashboard payload
"""

from __future__ import annotations

import re
from typing import List, Optional

from sqlalchemy import func, or_, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.health_education.models import (
    HealthArticle,
    HealthCategory,
    ReadingHistory,
    UserBookmark,
)
from app.health_education.schemas import (
    ArticleListResponse,
    BookmarkResponse,
    EducationDashboard,
    HealthArticleDetail,
    HealthArticleSummary,
    HealthCategoryResponse,
    ReadingHistoryResponse,
    SearchResponse,
)


# ─── helpers ─────────────────────────────────────────────────────────────────

def _slugify(text: str) -> str:
    text = text.lower().strip()
    text = re.sub(r"[^\w\s-]", "", text)
    text = re.sub(r"[\s_]+", "-", text)
    return re.sub(r"-+", "-", text)


def _article_to_summary(
    article: HealthArticle,
    category: Optional[HealthCategory],
    bookmarked: bool = False,
) -> HealthArticleSummary:
    return HealthArticleSummary(
        id=article.id,
        category_id=article.category_id,
        category_name=category.name if category else None,
        category_slug=category.slug if category else None,
        category_color=category.color_hex if category else None,
        title=article.title,
        slug=article.slug,
        summary=article.summary,
        language=article.language,
        author=article.author,
        read_time_min=article.read_time_min,
        cover_image=article.cover_image,
        emoji=article.emoji,
        tags=article.tags or [],
        is_featured=article.is_featured,
        view_count=article.view_count,
        bookmark_count=article.bookmark_count,
        published_at=article.published_at,
        is_bookmarked=bookmarked,
    )


async def _get_category(db: AsyncSession, category_id: Optional[str]) -> Optional[HealthCategory]:
    if not category_id:
        return None
    result = await db.execute(select(HealthCategory).where(HealthCategory.id == category_id))
    return result.scalar_one_or_none()


async def _user_bookmark_ids(db: AsyncSession, user_id: str) -> set[str]:
    result = await db.execute(
        select(UserBookmark.article_id).where(UserBookmark.user_id == user_id)
    )
    return {row[0] for row in result.fetchall()}


# ─── SeedService ─────────────────────────────────────────────────────────────

_CATEGORIES = [
    ("Diseases",          "diseases",          "🩺", "#F97316", 1),
    ("Nutrition",         "nutrition",          "🥗", "#2ECC8B", 2),
    ("Vaccination",       "vaccination",        "💉", "#4F94FF", 3),
    ("Maternal Health",   "maternal-health",    "🤰", "#8B5CF6", 4),
    ("Child Health",      "child-health",       "👶", "#FFB829", 5),
    ("Hygiene",           "hygiene",            "🧼", "#18C8C8", 6),
    ("Healthy Lifestyle", "healthy-lifestyle",  "🏃", "#926EFF", 7),
    ("Mental Health",     "mental-health",      "🧠", "#7C3AED", 8),
    ("Heart Health",      "heart-health",       "💙", "#0891B2", 9),
]

_SEED_ARTICLES = [
    # (title, category_slug, summary, content, emoji, lang, read_time, tags, is_featured)
    (
        "Understanding Diabetes: Causes, Symptoms & Prevention",
        "diseases", "Learn how diabetes develops, early warning signs, and proven prevention strategies.",
        """## What is Diabetes?
Diabetes is a chronic condition where the body cannot properly regulate blood sugar (glucose) levels.

## Types
- **Type 1** – Autoimmune; insulin-producing cells are destroyed.
- **Type 2** – Most common; body becomes resistant to insulin.
- **Gestational** – Occurs during pregnancy.

## Causes
- Genetics and family history
- Obesity and physical inactivity
- Poor diet high in refined carbohydrates
- Hormonal imbalances

## Symptoms
- Frequent urination and excessive thirst
- Unexplained weight loss
- Blurry vision and fatigue
- Slow-healing wounds

## Prevention
1. Maintain a healthy weight (BMI 18.5–24.9)
2. Exercise at least 30 minutes daily
3. Eat whole grains, vegetables, and lean proteins
4. Avoid sugary drinks and processed foods
5. Get regular blood sugar checkups

## Emergency Signs 🚨
Seek immediate care for: extreme confusion, difficulty breathing, or loss of consciousness.""",
        "🩸", "en", 5, ["diabetes", "sugar", "chronic disease", "prevention"], True,
    ),
    (
        "Malaria Prevention and Treatment Guide",
        "diseases", "Essential guide on malaria causes, prevention with mosquito nets, and treatment.",
        """## What is Malaria?
Malaria is a life-threatening disease caused by *Plasmodium* parasites, transmitted through infected Anopheles mosquito bites.

## Causes
- Plasmodium falciparum (most dangerous)
- Transmitted by female Anopheles mosquitoes

## Symptoms
- High fever (39–41°C) with chills and sweating
- Headache, muscle pain, nausea
- Symptoms appear 10–15 days after mosquito bite

## Prevention
1. Sleep under insecticide-treated bed nets (ITN)
2. Use mosquito repellent (DEET-based)
3. Wear long-sleeved clothes at dusk/dawn
4. Eliminate standing water near homes
5. Indoor Residual Spraying (IRS) programs

## Treatment
- Artemisinin-based Combination Therapy (ACT) is first-line
- Seek medical care within 24 hours of symptom onset

## Emergency Signs 🚨
Convulsions, difficulty breathing, or dark urine — go to hospital immediately.""",
        "🦟", "en", 4, ["malaria", "mosquito", "fever", "prevention", "rural health"], True,
    ),
    (
        "Nutrition During Pregnancy: What to Eat for a Healthy Baby",
        "nutrition", "A complete pregnancy nutrition guide covering essential nutrients, meal plans, and foods to avoid.",
        """## Why Nutrition Matters in Pregnancy
Proper nutrition ensures healthy fetal growth, prevents birth defects, and keeps the mother strong.

## Key Nutrients
| Nutrient | Why It Matters | Sources |
|---|---|---|
| Folic Acid | Prevents neural tube defects | Leafy greens, lentils |
| Iron | Prevents anemia | Red meat, spinach, beans |
| Calcium | Bone development | Milk, yogurt, tofu |
| Iodine | Brain development | Iodized salt, dairy |
| Protein | Tissue growth | Eggs, fish, chicken |

## Recommended Foods
- Dark leafy vegetables (spinach, fenugreek)
- Whole grains (brown rice, oats)
- Legumes (lentils, chickpeas, kidney beans)
- Fresh fruits (banana, papaya, guava)
- Dairy (milk, curd, paneer)

## Foods to Avoid
- Raw/undercooked meat and fish
- Unpasteurized dairy
- Excess caffeine (>200 mg/day)
- Alcohol completely
- Processed and junk foods

## Meal Plan (Daily)
- **Breakfast:** Oats with banana + 1 glass milk
- **Mid-morning:** Handful of nuts + fruits
- **Lunch:** Dal + rice + vegetables + curd
- **Snack:** Boiled egg + fruits
- **Dinner:** Roti + sabzi + dal soup""",
        "🤰", "en", 6, ["pregnancy", "nutrition", "maternal health", "diet"], True,
    ),
    (
        "BCG, Polio & Childhood Vaccination Schedule",
        "vaccination", "Complete childhood vaccination schedule from birth to 5 years with dose timing.",
        """## Why Vaccinate Children?
Vaccines protect children from life-threatening diseases before they are exposed. Every rupee spent on vaccination saves many more in treatment costs.

## Vaccination Schedule (0–5 Years)

| Vaccine | Disease | When |
|---|---|---|
| BCG | Tuberculosis | At birth |
| OPV-0 | Polio | At birth |
| Hepatitis B (1st) | Hepatitis B | At birth |
| DPT + Hib + Hep B | Diphtheria, Pertussis, Tetanus | 6, 10, 14 weeks |
| OPV | Polio | 6, 10, 14 weeks |
| PCV | Pneumococcal | 6, 10, 14 weeks |
| Rotavirus | Diarrhea | 6, 10 weeks |
| MR | Measles, Rubella | 9–12 months |
| JE | Japanese Encephalitis | 9–12 months |
| DPT Booster | Booster | 16–24 months |
| OPV Booster | Polio Booster | 16–24 months |

## Side Effects (Normal)
- Mild fever for 1–2 days
- Redness or soreness at injection site
- Slight swelling — goes away on its own

## When to See a Doctor
High fever (>39°C), seizures, or breathing difficulty after vaccination.""",
        "💉", "en", 5, ["vaccination", "children", "BCG", "polio", "immunization"], True,
    ),
    (
        "Hand Washing: The Most Powerful Disease Prevention Tool",
        "hygiene", "Learn the correct 7-step hand washing technique that prevents diarrhea, cholera, and flu.",
        """## Why Hand Washing Saves Lives
Proper hand washing can reduce diarrheal disease by 40% and respiratory infections by 20%.

## The 7-Step WHO Hand Washing Technique
1. **Wet** hands with clean running water
2. **Apply** soap and lather both palms
3. **Rub** back of hands and between fingers
4. **Interlock** fingers and scrub
5. **Clean** thumbs by rotating
6. **Scrub** fingertips and nails on palms
7. **Rinse** thoroughly and dry with clean cloth

**Duration:** At least 20 seconds

## When to Wash Hands
- Before eating or preparing food
- After using toilet
- After touching animals
- After coughing, sneezing, or blowing nose
- Before feeding a baby
- After touching garbage

## Alternatives When Water is Unavailable
- Use alcohol-based hand sanitizer (60%+ alcohol)
- Apply thoroughly and rub until dry

## Making Handwashing a Habit for Children
- Make it fun with songs (sing "Happy Birthday" twice = 20 sec)
- Use colorful soap and reward charts""",
        "🧼", "en", 3, ["hygiene", "hand washing", "disease prevention", "sanitation"], False,
    ),
    (
        "Managing High Blood Pressure (Hypertension) Naturally",
        "diseases", "Understand what raises your blood pressure and how diet, exercise, and stress management can help.",
        """## What is Hypertension?
Blood pressure above 130/80 mmHg consistently is considered hypertension. It is called the "silent killer" because it often has no symptoms.

## Risk Factors
- High salt diet
- Obesity and physical inactivity
- Smoking and alcohol
- Chronic stress
- Family history
- Age (risk increases after 40)

## Symptoms (When Present)
- Severe headache (especially in the morning)
- Nosebleeds
- Shortness of breath
- Blurred vision

## Lifestyle Changes That Work
1. **DASH Diet** – Fruits, vegetables, whole grains, low-fat dairy
2. **Reduce salt** – Less than 5g (1 teaspoon) per day
3. **Exercise** – 30 minutes brisk walking, 5 days a week
4. **Stop smoking** – Immediate benefit to blood vessels
5. **Limit alcohol** – Max 1 drink/day for women, 2 for men
6. **Manage stress** – Yoga, meditation, deep breathing

## Monitoring
Measure BP regularly. Home BP monitors are affordable and accurate.

## Emergency Signs 🚨
BP > 180/120 with chest pain, severe headache, or vision loss — call emergency immediately.""",
        "❤️", "en", 5, ["hypertension", "blood pressure", "heart health", "lifestyle"], True,
    ),
    (
        "Child Fever: When to Worry and Home Care Guide",
        "child-health", "Practical guide for parents to manage child fever safely at home and know when to rush to hospital.",
        """## What is Fever in Children?
A temperature above 38°C (100.4°F) is a fever. It is the body's natural response to infection.

## Taking Temperature
- Rectal (most accurate for infants): 38°C+ = fever
- Armpit: 37.5°C+ = fever
- Forehead thermometer: useful but less accurate

## Home Care for Mild Fever (38–38.9°C)
- Keep child well-hydrated (water, ORS, breast milk)
- Dress lightly — do not wrap in blankets
- Lukewarm sponge bath (not cold water)
- Paracetamol: 10–15 mg/kg every 4–6 hours (pediatric dose)
- Rest in a cool, ventilated room

## Foods During Fever
- ORS (Oral Rehydration Solution) for dehydration
- Soft foods: rice porridge, banana, boiled potato
- Avoid forcing food if child refuses

## When to See a Doctor 🏥
- Fever above 39°C that does not reduce with paracetamol
- Child is under 3 months old
- Fever lasting more than 3 days
- Child has rash, stiff neck, or difficulty breathing

## Emergency Signs 🚨
Febrile seizures, extreme difficulty breathing, blue lips — call emergency immediately.""",
        "👶", "en", 4, ["child fever", "pediatric", "children health", "home care"], False,
    ),
    (
        "Mental Wellness for Rural Communities",
        "mental-health", "Practical mental health strategies designed for rural communities facing stigma, stress, and limited access.",
        """## Mental Health in Rural Areas
Rural communities face unique mental health challenges: isolation, agricultural stress, limited access to specialists, and social stigma.

## Common Mental Health Issues
- **Depression** – Persistent sadness, loss of interest, fatigue
- **Anxiety** – Excessive worry, restlessness, physical symptoms
- **Substance Use** – Alcohol, tobacco as coping mechanisms
- **Farmer Stress** – Crop failure, debt, and climate uncertainty

## Signs You Need Help
- Feeling sad or hopeless for more than 2 weeks
- Unable to perform daily activities
- Thinking about harming yourself
- Withdrawing from family and friends

## Self-Care Strategies
1. **Talk to someone trusted** – friend, family member, or community leader
2. **Physical activity** – Even farming work counts as exercise
3. **Sleep hygiene** – Regular sleep and wake times
4. **Spiritual practice** – Prayer, meditation, community rituals
5. **Limit alcohol** – A major risk factor for depression
6. **Social connection** – Attend community events and festivals

## Breaking the Stigma
Mental illness is a medical condition, not a character weakness. Seeking help is a sign of strength.

## Free Help Available
- National Mental Health Helpline: 1800-599-0019 (India)
- NIMHANS Helpline: 080-46110007""",
        "🧠", "en", 5, ["mental health", "depression", "anxiety", "rural", "wellness"], False,
    ),
    (
        "Breastfeeding: Benefits and Best Practices for New Mothers",
        "maternal-health", "Everything a new mother needs to know about breastfeeding, positions, and overcoming challenges.",
        """## Why Breastfeed?
Breast milk is the perfect food for infants. It provides complete nutrition and immunity for the first 6 months of life.

## Benefits for Baby
- Protection against infections (diarrhea, pneumonia, ear infections)
- Optimal brain development (DHA in breast milk)
- Lower risk of allergies, obesity, and diabetes
- Comfort and emotional bonding

## Benefits for Mother
- Helps uterus return to normal size faster
- Reduces risk of breast and ovarian cancer
- Natural contraceptive (lactational amenorrhea)
- Saves money on formula

## How to Breastfeed (Latch Technique)
1. Position baby with tummy facing your tummy
2. Support baby's head and neck
3. Tickle baby's lip with nipple to open mouth wide
4. Bring baby to breast (not breast to baby)
5. A good latch: no pain, baby's chin touches breast

## Breastfeeding Positions
- **Cradle hold** – Most common, baby across your front
- **Football hold** – Baby under arm, good after C-section
- **Side-lying** – Rest while feeding, good for night feeds

## Common Challenges & Solutions
- **Sore nipples** – Check latch; apply expressed milk to soothe
- **Low supply** – Feed more frequently; stay hydrated
- **Engorgement** – Feed often; warm compress before feeding

## WHO Recommendation
Exclusive breastfeeding for 6 months, then continued with complementary foods up to 2 years.""",
        "🤱", "en", 6, ["breastfeeding", "maternal health", "newborn", "infant nutrition"], False,
    ),
    (
        "Tuberculosis (TB): Facts, Prevention, and Treatment",
        "diseases", "Complete guide on TB spread, DOTS treatment, and prevention for households and communities.",
        """## What is Tuberculosis?
TB is a bacterial infection caused by *Mycobacterium tuberculosis*, mainly affecting the lungs.

## How TB Spreads
TB spreads through the air when an infected person coughs, sneezes, or speaks. You CANNOT get TB from:
- Shaking hands
- Sharing food or drink
- Touching surfaces

## Symptoms
- Persistent cough for 2+ weeks
- Coughing up blood or mucus
- Night sweats and fever
- Unexplained weight loss and fatigue
- Chest pain

## Risk Factors
- HIV infection (30x higher risk)
- Malnutrition and poverty
- Overcrowded living conditions
- Smoking and alcohol use
- Diabetes

## Treatment (DOTS — Directly Observed Treatment)
TB is curable with a 6-month course of antibiotics:
- **Phase 1 (2 months):** 4 drugs: Rifampicin + Isoniazid + Pyrazinamide + Ethambutol
- **Phase 2 (4 months):** 2 drugs: Rifampicin + Isoniazid

**Critical:** Complete the full course even if feeling better. Stopping early creates drug-resistant TB.

## Prevention
- BCG vaccination at birth (protects children)
- Good ventilation in homes and workplaces
- Cough etiquette (cover mouth when coughing)
- Early diagnosis and treatment

## Free Treatment
TB treatment is **free** at all government health centers under the National TB Elimination Programme (NTEP).""",
        "🫁", "en", 5, ["tuberculosis", "TB", "respiratory", "DOTS", "treatment"], False,
    ),
]


class SeedService:
    """Idempotent seed — safe to call on every startup."""

    @staticmethod
    async def seed(db: AsyncSession) -> None:
        # 1. Seed categories — upsert so colour changes take effect immediately
        for name, slug, icon, color, order in _CATEGORIES:
            result = await db.execute(
                select(HealthCategory).where(HealthCategory.slug == slug)
            )
            existing = result.scalar_one_or_none()
            if existing:
                # Always update icon and colour so changes are applied live
                existing.icon      = icon
                existing.color_hex = color
                existing.sort_order = order
            else:
                db.add(HealthCategory(
                    name=name, slug=slug, icon=icon,
                    color_hex=color, sort_order=order,
                    description=f"Educational content about {name.lower()}.",
                ))
        await db.flush()

        # 2. Seed articles
        for (title, cat_slug, summary, content, emoji, lang, read_time, tags, featured) in _SEED_ARTICLES:
            slug = _slugify(title)
            exists = await db.execute(select(HealthArticle).where(HealthArticle.slug == slug))
            if exists.scalar_one_or_none():
                continue
            cat_row = await db.execute(select(HealthCategory).where(HealthCategory.slug == cat_slug))
            category = cat_row.scalar_one_or_none()
            db.add(HealthArticle(
                category_id=category.id if category else None,
                title=title, slug=slug, summary=summary, content=content,
                emoji=emoji, language=lang, read_time_min=read_time,
                tags=tags, is_featured=featured, is_published=True,
                author="AI Healthcare Team",
            ))
        await db.commit()


# ─── CategoryService ─────────────────────────────────────────────────────────

class CategoryService:
    @staticmethod
    async def list_categories(db: AsyncSession) -> list[HealthCategoryResponse]:
        result = await db.execute(
            select(HealthCategory)
            .where(HealthCategory.is_active == True)
            .order_by(HealthCategory.sort_order)
        )
        cats = result.scalars().all()
        return [HealthCategoryResponse.model_validate(c) for c in cats]


# ─── ArticleService ───────────────────────────────────────────────────────────

class ArticleService:

    @staticmethod
    async def list_articles(
        db: AsyncSession,
        user_id: Optional[str],
        category_slug: Optional[str] = None,
        language: str = "en",
        page: int = 1,
        per_page: int = 20,
    ) -> ArticleListResponse:
        stmt = (
            select(HealthArticle)
            .where(HealthArticle.is_published == True)
            .where(HealthArticle.language == language)
        )
        if category_slug:
            cat = await db.execute(select(HealthCategory).where(HealthCategory.slug == category_slug))
            cat_obj = cat.scalar_one_or_none()
            if cat_obj:
                stmt = stmt.where(HealthArticle.category_id == cat_obj.id)

        total_result = await db.execute(select(func.count()).select_from(stmt.subquery()))
        total = total_result.scalar_one()

        stmt = stmt.order_by(HealthArticle.published_at.desc()).offset((page - 1) * per_page).limit(per_page)
        rows = await db.execute(stmt)
        articles = rows.scalars().all()

        bookmarked_ids = await _user_bookmark_ids(db, user_id) if user_id else set()
        summaries = []
        for a in articles:
            cat = await _get_category(db, a.category_id)
            summaries.append(_article_to_summary(a, cat, a.id in bookmarked_ids))

        return ArticleListResponse(total=total, page=page, per_page=per_page, articles=summaries)

    @staticmethod
    async def get_article_detail(
        db: AsyncSession,
        article_id: str,
        user_id: Optional[str],
    ) -> Optional[HealthArticleDetail]:
        result = await db.execute(select(HealthArticle).where(HealthArticle.id == article_id))
        article = result.scalar_one_or_none()
        if not article:
            return None

        # bump view count
        await db.execute(
            update(HealthArticle)
            .where(HealthArticle.id == article_id)
            .values(view_count=HealthArticle.view_count + 1)
        )
        await db.commit()

        cat = await _get_category(db, article.category_id)
        bookmarked_ids = await _user_bookmark_ids(db, user_id) if user_id else set()

        return HealthArticleDetail(
            id=article.id,
            category_id=article.category_id,
            category_name=cat.name if cat else None,
            category_slug=cat.slug if cat else None,
            category_color=cat.color_hex if cat else None,
            title=article.title,
            slug=article.slug,
            summary=article.summary,
            content=article.content,
            language=article.language,
            author=article.author,
            source=article.source,
            read_time_min=article.read_time_min,
            cover_image=article.cover_image,
            emoji=article.emoji,
            tags=article.tags or [],
            is_featured=article.is_featured,
            view_count=article.view_count,
            bookmark_count=article.bookmark_count,
            published_at=article.published_at,
            created_at=article.created_at,
            updated_at=article.updated_at,
            is_bookmarked=article.id in bookmarked_ids,
        )

    @staticmethod
    async def get_featured(
        db: AsyncSession, user_id: Optional[str], language: str = "en", limit: int = 5,
    ) -> list[HealthArticleSummary]:
        result = await db.execute(
            select(HealthArticle)
            .where(HealthArticle.is_featured == True)
            .where(HealthArticle.is_published == True)
            .where(HealthArticle.language == language)
            .order_by(HealthArticle.published_at.desc())
            .limit(limit)
        )
        articles = result.scalars().all()
        bookmarked_ids = await _user_bookmark_ids(db, user_id) if user_id else set()
        summaries = []
        for a in articles:
            cat = await _get_category(db, a.category_id)
            summaries.append(_article_to_summary(a, cat, a.id in bookmarked_ids))
        return summaries

    @staticmethod
    async def search(
        db: AsyncSession, query: str, user_id: Optional[str], language: str = "en", limit: int = 20,
    ) -> SearchResponse:
        like = f"%{query}%"
        result = await db.execute(
            select(HealthArticle)
            .where(HealthArticle.is_published == True)
            .where(HealthArticle.language == language)
            .where(
                or_(
                    HealthArticle.title.ilike(like),
                    HealthArticle.summary.ilike(like),
                    HealthArticle.content.ilike(like),
                )
            )
            .order_by(HealthArticle.view_count.desc())
            .limit(limit)
        )
        articles = result.scalars().all()
        bookmarked_ids = await _user_bookmark_ids(db, user_id) if user_id else set()
        summaries = []
        for a in articles:
            cat = await _get_category(db, a.category_id)
            summaries.append(_article_to_summary(a, cat, a.id in bookmarked_ids))
        return SearchResponse(query=query, total=len(summaries), articles=summaries)

    @staticmethod
    async def get_recommendations(
        db: AsyncSession,
        user_id: Optional[str],
        language: str = "en",
        limit: int = 8,
    ) -> list[HealthArticleSummary]:
        """Simple content-based recommendation: most viewed + bookmarked articles."""
        result = await db.execute(
            select(HealthArticle)
            .where(HealthArticle.is_published == True)
            .where(HealthArticle.language == language)
            .order_by(
                (HealthArticle.view_count + HealthArticle.bookmark_count * 3).desc()
            )
            .limit(limit)
        )
        articles = result.scalars().all()
        bookmarked_ids = await _user_bookmark_ids(db, user_id) if user_id else set()
        summaries = []
        for a in articles:
            cat = await _get_category(db, a.category_id)
            summaries.append(_article_to_summary(a, cat, a.id in bookmarked_ids))
        return summaries


# ─── BookmarkService ──────────────────────────────────────────────────────────

class BookmarkService:
    @staticmethod
    async def list_bookmarks(
        db: AsyncSession, user_id: str, language: str = "en",
    ) -> list[HealthArticleSummary]:
        result = await db.execute(
            select(UserBookmark).where(UserBookmark.user_id == user_id)
            .order_by(UserBookmark.created_at.desc())
        )
        bookmarks = result.scalars().all()
        summaries = []
        for bm in bookmarks:
            a_result = await db.execute(
                select(HealthArticle).where(HealthArticle.id == bm.article_id)
            )
            article = a_result.scalar_one_or_none()
            if article and article.is_published:
                cat = await _get_category(db, article.category_id)
                summaries.append(_article_to_summary(article, cat, True))
        return summaries

    @staticmethod
    async def add_bookmark(
        db: AsyncSession, user_id: str, article_id: str,
    ) -> BookmarkResponse:
        exists = await db.execute(
            select(UserBookmark)
            .where(UserBookmark.user_id == user_id)
            .where(UserBookmark.article_id == article_id)
        )
        bm = exists.scalar_one_or_none()
        if not bm:
            bm = UserBookmark(user_id=user_id, article_id=article_id)
            db.add(bm)
            await db.execute(
                update(HealthArticle)
                .where(HealthArticle.id == article_id)
                .values(bookmark_count=HealthArticle.bookmark_count + 1)
            )
            await db.commit()
            await db.refresh(bm)
        return BookmarkResponse.model_validate(bm)

    @staticmethod
    async def remove_bookmark(db: AsyncSession, user_id: str, bookmark_id: str) -> bool:
        result = await db.execute(
            select(UserBookmark)
            .where(UserBookmark.id == bookmark_id)
            .where(UserBookmark.user_id == user_id)
        )
        bm = result.scalar_one_or_none()
        if not bm:
            return False
        await db.execute(
            update(HealthArticle)
            .where(HealthArticle.id == bm.article_id)
            .values(bookmark_count=func.greatest(HealthArticle.bookmark_count - 1, 0))
        )
        await db.delete(bm)
        await db.commit()
        return True


# ─── ReadingHistoryService ────────────────────────────────────────────────────

class ReadingHistoryService:
    @staticmethod
    async def update_progress(
        db: AsyncSession,
        user_id: str,
        article_id: str,
        position: int,
        is_completed: bool,
    ) -> ReadingHistoryResponse:
        result = await db.execute(
            select(ReadingHistory)
            .where(ReadingHistory.user_id == user_id)
            .where(ReadingHistory.article_id == article_id)
        )
        rh = result.scalar_one_or_none()
        if rh:
            rh.last_read_position = position
            rh.is_completed = is_completed
            rh.read_count = rh.read_count + 1
        else:
            rh = ReadingHistory(
                user_id=user_id, article_id=article_id,
                last_read_position=position, is_completed=is_completed,
            )
            db.add(rh)
        await db.commit()
        await db.refresh(rh)
        return ReadingHistoryResponse.model_validate(rh)

    @staticmethod
    async def get_recent(
        db: AsyncSession, user_id: str, limit: int = 10,
    ) -> list[HealthArticleSummary]:
        result = await db.execute(
            select(ReadingHistory)
            .where(ReadingHistory.user_id == user_id)
            .order_by(ReadingHistory.updated_at.desc())
            .limit(limit)
        )
        history = result.scalars().all()
        bookmarked_ids = await _user_bookmark_ids(db, user_id)
        summaries = []
        for rh in history:
            a_result = await db.execute(select(HealthArticle).where(HealthArticle.id == rh.article_id))
            article = a_result.scalar_one_or_none()
            if article and article.is_published:
                cat = await _get_category(db, article.category_id)
                summaries.append(_article_to_summary(article, cat, rh.article_id in bookmarked_ids))
        return summaries


# ─── DashboardService ─────────────────────────────────────────────────────────

class DashboardService:
    @staticmethod
    async def get_dashboard(
        db: AsyncSession,
        user_id: Optional[str],
        language: str = "en",
    ) -> EducationDashboard:
        featured    = await ArticleService.get_featured(db, user_id, language, limit=5)
        categories  = await CategoryService.list_categories(db)
        recommended = await ArticleService.get_recommendations(db, user_id, language, limit=8)
        recent      = await ReadingHistoryService.get_recent(db, user_id) if user_id else []
        bookmarks   = await BookmarkService.list_bookmarks(db, user_id, language) if user_id else []

        return EducationDashboard(
            featured_articles=featured,
            categories=categories,
            recommended_articles=recommended,
            recent_articles=recent,
            bookmarks=bookmarks[:5],
        )
