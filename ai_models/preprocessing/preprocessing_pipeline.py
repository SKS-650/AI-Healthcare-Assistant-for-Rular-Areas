"""Preprocessing pipeline for model training and inference."""

from __future__ import annotations

from typing import Any

from ai_models.preprocessing.data_cleaning import remove_empty_records


class PreprocessingPipeline:
    """Simple preprocessing pipeline."""

    def run(self, records: list[dict[str, Any]]) -> list[dict[str, Any]]:
        """Clean records before feature engineering."""

        return remove_empty_records(records)
