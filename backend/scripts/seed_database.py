"""Seed backend databases."""

from __future__ import annotations

from backend.app.database.seed import seed_database


def main() -> None:
    """Run database seed tasks."""

    seed_database()
    print("Database seed placeholder.")


if __name__ == "__main__":
    main()
