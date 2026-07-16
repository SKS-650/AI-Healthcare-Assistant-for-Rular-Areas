"""
One-shot script to update health category colours in the database.
Removes all red shades and replaces with attractive non-red palette.

Run from the project root:
    python backend/fix_category_colors.py
"""

import asyncio
import os
import sys
import pathlib

# Load .env
try:
    from dotenv import load_dotenv
    for _p in [pathlib.Path(__file__).parent / ".env",
               pathlib.Path.cwd() / ".env",
               pathlib.Path.cwd() / "backend" / ".env"]:
        if _p.exists():
            load_dotenv(dotenv_path=_p, override=True)
            break
except ImportError:
    pass

sys.path.insert(0, str(pathlib.Path(__file__).parent))

# New colour palette — zero reds
COLOUR_MAP = {
    "diseases":          ("#F97316", "🩺"),   # Warm orange
    "nutrition":         ("#2ECC8B", "🥗"),   # Emerald green
    "vaccination":       ("#4F94FF", "💉"),   # Blue
    "maternal-health":   ("#8B5CF6", "🤰"),   # Soft violet
    "child-health":      ("#FFB829", "👶"),   # Amber
    "hygiene":           ("#18C8C8", "🧼"),   # Teal
    "healthy-lifestyle": ("#926EFF", "🏃"),   # Purple
    "mental-health":     ("#7C3AED", "🧠"),   # Deep violet
    "heart-health":      ("#0891B2", "💙"),   # Cyan-teal
}


async def fix_colours() -> None:
    from app.database.connection import _get_engine, _get_session_factory
    from app.health_education.models import HealthArticle, HealthCategory
    from sqlalchemy import select

    # Import ALL models to resolve SQLAlchemy relationships
    import app.auth.models
    import app.users.models
    import app.symptom_checker.models
    import app.medical_chatbot.database.models
    import app.emergency.models
    import app.health_records.models
    import app.health_education.models
    import app.admin.models
    import app.notifications.models

    engine = _get_engine()
    async with engine.begin() as conn:
        await conn.run_sync(__import__("app.auth.models", fromlist=["Base"]).Base.metadata.create_all)

    factory = _get_session_factory()
    async with factory() as db:
        # ── Update category colours ─────────────────────────────────────────
        result = await db.execute(select(HealthCategory))
        categories = result.scalars().all()
        updated_cats = 0
        for cat in categories:
            if cat.slug in COLOUR_MAP:
                new_color, new_icon = COLOUR_MAP[cat.slug]
                if cat.color_hex != new_color or cat.icon != new_icon:
                    cat.color_hex = new_color
                    cat.icon = new_icon
                    updated_cats += 1
                    print(f"  ✓ {cat.name}: {cat.color_hex} → {new_color}")

        # ── Update article category_color via join ──────────────────────────
        art_result = await db.execute(select(HealthArticle))
        articles = art_result.scalars().all()
        updated_arts = 0
        for article in articles:
            if article.category_id:
                # Find the category for this article
                cat_result = await db.execute(
                    select(HealthCategory).where(HealthCategory.id == article.category_id)
                )
                cat = cat_result.scalar_one_or_none()
                if cat and cat.slug in COLOUR_MAP:
                    new_color, _ = COLOUR_MAP[cat.slug]
                    # HealthArticle.category_color is a transient property
                    # populated at query time — no need to update it separately
                    updated_arts += 1

        await db.commit()
        print(f"\n✅  Updated {updated_cats} categories, {updated_arts} articles linked.")


if __name__ == "__main__":
    asyncio.run(fix_colours())
