"""Fake data generator."""


def generate_users(count: int = 1) -> list[dict[str, str]]:
    return [{"id": str(index), "name": f"User {index}"} for index in range(count)]
