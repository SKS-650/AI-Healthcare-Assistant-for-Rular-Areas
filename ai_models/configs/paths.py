"""Central paths for AI model assets."""

from __future__ import annotations

from pathlib import Path


AI_MODELS_ROOT = Path(__file__).resolve().parents[1]
DATASETS_DIR = AI_MODELS_ROOT / "datasets"
SAVED_MODELS_DIR = AI_MODELS_ROOT / "saved_models"
LOGS_DIR = AI_MODELS_ROOT / "logs"
