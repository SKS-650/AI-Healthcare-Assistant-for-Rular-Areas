"""
ai_models.emergency_detection
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Production-quality emergency detection module for the AI Healthcare Assistant.

Public API
----------
from ai_models.emergency_detection import (
    run_emergency_pipeline,
    EmergencyPipelineInput,
    EmergencyPipelineResult,
    EmergencyCategory,
    RiskLevel,
)
"""

from ai_models.emergency_detection.emergency_rules import EmergencyCategory, RiskLevel
from ai_models.emergency_detection.emergency_pipeline import (
    EmergencyPipelineInput,
    EmergencyPipelineResult,
    run_emergency_pipeline,
)
from ai_models.emergency_detection.first_aid_engine import (
    FirstAidGuide,
    get_first_aid,
    get_all_guides,
)

__all__ = [
    "EmergencyCategory",
    "RiskLevel",
    "EmergencyPipelineInput",
    "EmergencyPipelineResult",
    "run_emergency_pipeline",
    "FirstAidGuide",
    "get_first_aid",
    "get_all_guides",
]
