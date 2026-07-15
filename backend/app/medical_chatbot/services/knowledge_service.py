"""
Knowledge Service - Loads medical datasets + FAISS semantic search.

Upgraded to use:
  1. FAISS vector search (primary — semantic similarity)
  2. Pandas keyword search (fallback when FAISS not built yet)
  3. Translation service (translates non-English queries before search)
"""
from __future__ import annotations

import re
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional

import pandas as pd

from ..utils.logger import logger
from ..utils.exceptions import ChatbotException  # noqa: F401

# ── project root on sys.path so ai_models is importable ──────────────────────
_PROJECT_ROOT = Path(__file__).parent.parent.parent.parent.parent
if str(_PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(_PROJECT_ROOT))

# ── FAISS index directory ─────────────────────────────────────────────────────
_FAISS_INDEX_DIR = _PROJECT_ROOT / "ai_models" / "saved_models" / "faiss_index"

# ── Expanded disease vocabulary (100+ terms) ──────────────────────────────────
_DISEASE_KEYWORDS = [
    "diabetes", "hypertension", "fever", "cold", "cough", "asthma",
    "malaria", "dengue", "typhoid", "tuberculosis", "pneumonia",
    "covid", "coronavirus", "headache", "migraine", "arthritis", "allergy",
    "anemia", "anaemia", "diarrhea", "diarrhoea", "cholera", "hepatitis",
    "jaundice", "kidney", "liver", "heart", "stroke", "epilepsy",
    "depression", "anxiety", "schizophrenia", "bipolar", "insomnia",
    "obesity", "cancer", "tumor", "ulcer", "gastritis", "constipation",
    "appendicitis", "hernia", "fracture", "sprain", "burn", "wound",
    "infection", "rash", "eczema", "psoriasis", "acne", "chickenpox",
    "measles", "mumps", "rubella", "polio", "tetanus", "rabies",
    "leptospirosis", "typhus", "plague", "ebola", "influenza", "flu",
    "sinusitis", "tonsillitis", "bronchitis", "pleurisy", "empyema",
    "meningitis", "encephalitis", "parkinson", "alzheimer", "dementia",
    "osteoporosis", "gout", "lupus", "multiple sclerosis", "fibromyalgia",
    "hypothyroidism", "hyperthyroidism", "goiter", "addison", "cushing",
    "celiac", "crohn", "irritable bowel", "colitis", "appendix",
    "gallstone", "gallbladder", "pancreatitis", "cirrhosis", "fatty liver",
    "glaucoma", "cataract", "conjunctivitis", "stye", "uveitis",
    "otitis", "tinnitus", "vertigo", "meniere", "labyrinthitis",
    "pregnancy", "miscarriage", "ectopic", "preeclampsia", "gestational",
    "endometriosis", "pcos", "fibroids", "menopause",
    "prostate", "erectile", "infertility",
    "scabies", "ringworm", "tinea", "athlete", "nail fungus",
]


class KnowledgeService:
    """Medical knowledge retrieval with FAISS + CSV fallback."""

    def __init__(self, dataset_path: Optional[str] = None) -> None:
        self.dataset_path = Path(dataset_path) if dataset_path else self._find_dataset_path()

        # DataFrames
        self.disease_symptoms_df:   Optional[pd.DataFrame] = None
        self.symptom_description_df: Optional[pd.DataFrame] = None
        self.symptom_precaution_df:  Optional[pd.DataFrame] = None
        self.symptom_severity_df:    Optional[pd.DataFrame] = None
        self.medquad_df:             Optional[pd.DataFrame] = None

        # AI services (lazy)
        self._faiss       = None
        self._embeddings  = None
        self._translator  = None
        self._faiss_ready = False

        self._load_datasets()
        self._try_load_faiss()

        logger.info(f"KnowledgeService ready — datasets={self.get_stats()}, faiss={self._faiss_ready}")

    # ─── dataset path detection ───────────────────────────────────────────────

    def _find_dataset_path(self) -> Path:
        candidates = [
            Path("datasets/chatbot_dataset"),
            Path("../datasets/chatbot_dataset"),
            Path("../../datasets/chatbot_dataset"),
            _PROJECT_ROOT / "datasets" / "chatbot_dataset",
        ]
        for p in candidates:
            if p.exists():
                logger.info(f"Dataset path: {p.absolute()}")
                return p.absolute()
        default = Path("datasets/chatbot_dataset")
        logger.warning(f"Dataset path not found, using default: {default}")
        return default

    # ─── CSV loading ──────────────────────────────────────────────────────────

    def _load_datasets(self) -> None:
        disease_path = self.dataset_path / "DiseaseSymptomPredictionDataset"
        medquad_path = self.dataset_path / "MedQuAD_Dataset"

        def _read(p: Path, label: str) -> Optional[pd.DataFrame]:
            if p.exists():
                df = pd.read_csv(p)
                logger.info(f"Loaded {label}: {len(df)} rows")
                return df
            logger.warning(f"CSV not found: {p}")
            return None

        self.disease_symptoms_df    = _read(disease_path / "dataset.csv",                "disease_symptoms")
        self.symptom_description_df = _read(disease_path / "symptom_Description.csv",    "symptom_descriptions")
        self.symptom_precaution_df  = _read(disease_path / "symptom_precaution.csv",     "symptom_precautions")
        self.symptom_severity_df    = _read(disease_path / "Symptom-severity.csv",       "symptom_severity")
        self.medquad_df             = _read(medquad_path  / "medquad.csv",               "medquad")

    # ─── FAISS lazy load ──────────────────────────────────────────────────────

    def _try_load_faiss(self) -> None:
        try:
            from ai_models.vector_database.faiss_engine import get_faiss_engine
            from ai_models.embeddings.embedding_service import get_embedding_service

            self._faiss      = get_faiss_engine()
            self._embeddings = get_embedding_service()

            if _FAISS_INDEX_DIR.exists():
                self._faiss_ready = self._faiss.load(_FAISS_INDEX_DIR)
            else:
                logger.info("FAISS index not built yet — run build_faiss_index.py")
        except Exception as exc:
            logger.warning(f"FAISS not available: {exc}")

    def _get_translator(self):
        if self._translator is None:
            try:
                from ai_models.translation.translator import get_translator
                self._translator = get_translator()
            except Exception:
                pass
        return self._translator

    # ─── Semantic search (FAISS) ──────────────────────────────────────────────

    def semantic_search(self, query: str, top_k: int = 3) -> List[Dict[str, Any]]:
        """Vector search over the FAISS index.  Returns [] if index not loaded."""
        if not self._faiss_ready or self._embeddings is None or self._faiss is None:
            return []
        try:
            emb     = self._embeddings.embed(query)
            results = self._faiss.search(emb, top_k=top_k, min_score=0.30)
            return [
                {
                    "question": r.doc.text,
                    "answer":   r.doc.answer or "",
                    "category": r.doc.category,
                    "score":    r.score,
                }
                for r in results
            ]
        except Exception as exc:
            logger.debug(f"FAISS search error: {exc}")
            return []

    # ─── Disease search ───────────────────────────────────────────────────────

    def search_disease(self, disease_name: str) -> Optional[Dict[str, Any]]:
        if self.disease_symptoms_df is None:
            return None
        try:
            name_lower = disease_name.strip().lower()
            mask   = self.disease_symptoms_df["Disease"].str.lower().str.contains(name_lower, na=False)
            matches = self.disease_symptoms_df[mask]
            if matches.empty:
                return None

            row  = matches.iloc[0]
            exact = row["Disease"]
            sym_cols  = [c for c in row.index if c.startswith("Symptom")]
            symptoms  = [row[c] for c in sym_cols if pd.notna(row[c])]

            return {
                "name":        exact,
                "symptoms":    symptoms,
                "description": self.get_symptom_description(exact),
                "precautions": self.get_precautions(exact),
            }
        except Exception as exc:
            logger.error(f"search_disease error: {exc}")
            return None

    def get_symptom_description(self, disease_name: str) -> Optional[str]:
        if self.symptom_description_df is None:
            return None
        try:
            mask = self.symptom_description_df["Disease"].str.lower() == disease_name.lower()
            m    = self.symptom_description_df[mask]
            return m.iloc[0]["Description"] if not m.empty else None
        except Exception:
            return None

    def get_precautions(self, disease_name: str) -> List[str]:
        if self.symptom_precaution_df is None:
            return []
        try:
            mask = self.symptom_precaution_df["Disease"].str.lower() == disease_name.lower()
            m    = self.symptom_precaution_df[mask]
            if m.empty:
                return []
            row  = m.iloc[0]
            return [
                row[f"Precaution_{i}"]
                for i in range(1, 5)
                if f"Precaution_{i}" in row.index and pd.notna(row[f"Precaution_{i}"])
            ]
        except Exception:
            return []

    def search_symptoms(self, query: str) -> List[str]:
        if self.disease_symptoms_df is None:
            return []
        try:
            ql = query.lower()
            sym_cols = [c for c in self.disease_symptoms_df.columns if c.startswith("Symptom")]
            found: set = set()
            for col in sym_cols:
                for s in self.disease_symptoms_df[col].dropna().unique():
                    if ql in str(s).lower():
                        found.add(s)
            return sorted(found)[:10]
        except Exception:
            return []

    def search_medquad(self, query: str, limit: int = 3) -> List[Dict[str, str]]:
        if self.medquad_df is None:
            return []
        try:
            ql = query.lower()
            if "question" not in self.medquad_df.columns:
                return []
            mask = (
                self.medquad_df["question"].str.lower().str.contains(ql, na=False) |
                self.medquad_df.get("answer", pd.Series(dtype=str)).str.lower().str.contains(ql, na=False)
            )
            rows = self.medquad_df[mask].head(limit)
            return [
                {"question": r["question"], "answer": str(r.get("answer", ""))[:300]}
                for _, r in rows.iterrows()
            ]
        except Exception:
            return []

    # ─── Main entry point ─────────────────────────────────────────────────────

    def get_relevant_knowledge(self, user_message: str) -> Dict[str, Any]:
        """
        Return all relevant knowledge for a user message.

        Steps:
          1. Translate non-English to English (if translator available)
          2. Try FAISS semantic search
          3. Fallback: keyword disease search + MedQuAD
        """
        knowledge: Dict[str, Any] = {
            "disease_info": None,
            "symptom_info": None,
            "medquad_info": None,
            "general_info": None,
            "semantic_results": [],
        }

        # Translate to English for search
        search_query = user_message
        translator = self._get_translator()
        if translator:
            try:
                det = translator.detect(user_message)
                if det.language_code not in ("en", "auto"):
                    tr = translator.translate_to_english(user_message)
                    if tr.success:
                        search_query = tr.translated_text
            except Exception:
                pass

        try:
            # 1. FAISS semantic search
            semantic = self.semantic_search(search_query, top_k=3)
            if semantic:
                knowledge["semantic_results"] = semantic
                best = semantic[0]
                if best.get("answer"):
                    knowledge["general_info"] = best["answer"][:400]

            # 2. Disease keyword search
            msg_lower = search_query.lower()
            for kw in _DISEASE_KEYWORDS:
                if kw in msg_lower:
                    di = self.search_disease(kw)
                    if di:
                        knowledge["disease_info"] = di
                        break

            # 3. Symptom search
            syms = self.search_symptoms(search_query)
            if syms:
                knowledge["symptom_info"] = syms

            # 4. MedQuAD keyword search (only if no FAISS result)
            if not semantic:
                medquad = self.search_medquad(search_query, limit=2)
                if medquad:
                    knowledge["medquad_info"] = medquad
                    parts = [f"Q: {qa['question']}\nA: {qa['answer']}" for qa in medquad]
                    knowledge["general_info"] = "\n\n".join(parts)

        except Exception as exc:
            logger.error(f"get_relevant_knowledge error: {exc}", exc_info=True)

        return knowledge

    # ─── Stats / health ───────────────────────────────────────────────────────

    def get_stats(self) -> Dict[str, Any]:
        return {
            "diseases":        len(self.disease_symptoms_df)    if self.disease_symptoms_df    is not None else 0,
            "descriptions":    len(self.symptom_description_df) if self.symptom_description_df is not None else 0,
            "precautions":     len(self.symptom_precaution_df)  if self.symptom_precaution_df  is not None else 0,
            "medquad_entries": len(self.medquad_df)             if self.medquad_df             is not None else 0,
            "faiss_loaded":    self._faiss_ready,
            "faiss_docs":      self._faiss.total_documents       if self._faiss                 is not None else 0,
        }

    def is_loaded(self) -> bool:
        return any([
            self.disease_symptoms_df    is not None,
            self.symptom_description_df is not None,
            self.medquad_df             is not None,
        ])


# ── Singleton ─────────────────────────────────────────────────────────────────

_knowledge_service_instance: Optional[KnowledgeService] = None


def get_knowledge_service() -> KnowledgeService:
    global _knowledge_service_instance
    if _knowledge_service_instance is None:
        _knowledge_service_instance = KnowledgeService()
    return _knowledge_service_instance
