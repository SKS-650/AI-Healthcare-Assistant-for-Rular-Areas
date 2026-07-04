"""LLM client abstraction."""

from __future__ import annotations


class LlmClient:
    """Placeholder client for future LLM providers."""

    def complete(self, prompt: str) -> str:
        """Return a placeholder completion."""

        return f"LLM response placeholder for: {prompt[:80]}"
