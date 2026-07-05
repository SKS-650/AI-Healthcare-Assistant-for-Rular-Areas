from app.config.settings import Settings


def test_database_url_defaults_to_sqlite_when_not_configured(monkeypatch):
    monkeypatch.delenv("DATABASE_URL", raising=False)
    monkeypatch.setenv("ENVIRONMENT", "development")

    settings = Settings()

    assert settings.database_url.startswith("sqlite+aiosqlite")
