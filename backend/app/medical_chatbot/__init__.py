"""
Medical Chatbot Module for AI Healthcare Assistant

This module provides a conversational medical assistant that:
- Answers general health questions
- Explains diseases, symptoms, and medicines
- Provides health education and first-aid guidance
- Detects emergency situations
- Recommends when to seek medical attention

IMPORTANT: This chatbot does NOT replace doctors and cannot:
- Make definitive diagnoses
- Prescribe treatments or medications
- Provide emergency medical care

Always consult qualified healthcare professionals for medical advice.
"""

__version__ = "1.0.0"
__author__ = "AI Healthcare Assistant Team"

from .api import router
from .config import settings

__all__ = ["router", "settings"]
