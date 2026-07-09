"""Check DB is reachable and tables exist."""
import asyncio, sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.core.startup import initialize_application
initialize_application()

async def main():
    from app.database.connection import _get_engine
    from app.auth.models import Base
    import app.auth.models       # noqa
    import app.users.models      # noqa
    import app.symptom_checker.models  # noqa

    engine = _get_engine()
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    print("DB tables created/verified OK")

    from sqlalchemy import text
    async with engine.connect() as conn:
        r = await conn.execute(text("SELECT COUNT(*) FROM users"))
        print("Users in DB:", r.scalar())

asyncio.run(main())
