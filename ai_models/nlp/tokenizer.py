"""Tokenizer utilities."""

from __future__ import annotations


def tokenize(text: str) -> list[str]:
    """Tokenize text using simple whitespace splitting."""

    return text.lower().split()
