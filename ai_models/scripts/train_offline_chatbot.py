#!/usr/bin/env python3
"""
Train Offline Medical Chatbot — Full Pipeline
=============================================
Runs all three training steps in one command:

  Step 1 — Load & process all medical CSV datasets
  Step 2 — Train TF-IDF + Logistic Regression intent classifier
  Step 3 — Build FAISS semantic search index (SentenceTransformer)

Output
------
  ai_models/saved_models/intent_classifier.pkl
  ai_models/saved_models/faiss_index/index.faiss
  ai_models/saved_models/faiss_index/documents.pkl
  ai_models/saved_models/faiss_index/manifest.json

Usage
-----
  python ai_models/scripts/train_offline_chatbot.py
  python ai_models/scripts/train_offline_chatbot.py --force   # rebuild even if exists
  python ai_models/scripts/train_offline_chatbot.py --no-faiss  # intent only
"""

from __future__ import annotations

import argparse
import logging
import sys
import time
from pathlib import Path

# ── project root on sys.path ──────────────────────────────────────────────────
ROOT = Path(__file__).resolve().parent.parent.parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

import numpy as np
import pandas as pd

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(message)s",
    datefmt="%H:%M:%S",
)
log = logging.getLogger("train")

# ── Paths ─────────────────────────────────────────────────────────────────────
DATASETS     = ROOT / "datasets" / "chatbot_dataset"
MEDQUAD_CSV  = DATASETS / "MedQuAD_Dataset"  / "medquad.csv"
DISEASE_CSV  = DATASETS / "DiseaseSymptomPredictionDataset" / "dataset.csv"
DESC_CSV     = DATASETS / "DiseaseSymptomPredictionDataset" / "symptom_Description.csv"
PRECAUTION_CSV = DATASETS / "DiseaseSymptomPredictionDataset" / "symptom_precaution.csv"
SEVERITY_CSV = DATASETS / "DiseaseSymptomPredictionDataset" / "Symptom-severity.csv"
SAVED        = ROOT / "ai_models" / "saved_models"
FAISS_DIR    = SAVED / "faiss_index"
CLF_PATH     = SAVED / "intent_classifier.pkl"

SAVED.mkdir(parents=True, exist_ok=True)

# ─────────────────────────────────────────────────────────────────────────────
# Step 1 — Load Datasets
# ─────────────────────────────────────────────────────────────────────────────

def load_medquad() -> pd.DataFrame:
    if not MEDQUAD_CSV.exists():
        log.warning(f"MedQuAD not found: {MEDQUAD_CSV}")
        return pd.DataFrame()
    df = pd.read_csv(MEDQUAD_CSV)
    df.columns = [c.strip().lower() for c in df.columns]
    log.info(f"MedQuAD loaded: {len(df):,} rows — columns: {df.columns.tolist()}")
    return df


def load_disease_data() -> dict:
    """Load all disease-symptom CSVs and return as a dict of DataFrames."""
    result = {}
    for label, path in [
        ("symptoms", DISEASE_CSV),
        ("descriptions", DESC_CSV),
        ("precautions", PRECAUTION_CSV),
        ("severity", SEVERITY_CSV),
    ]:
        if path.exists():
            df = pd.read_csv(path)
            df.columns = [c.strip() for c in df.columns]
            result[label] = df
            log.info(f"Loaded {label}: {len(df):,} rows")
        else:
            log.warning(f"Missing: {path}")
    return result


# ─────────────────────────────────────────────────────────────────────────────
# Step 2 — Build Training Data for Intent Classifier
# ─────────────────────────────────────────────────────────────────────────────

INTENT_KEYWORDS = {
    "EMERGENCY_QUERY": [
        "heart attack", "chest pain", "stroke", "can't breathe", "bleeding",
        "unconscious", "fainted", "snake bite", "poisoning", "overdose",
        "difficulty breathing", "severe pain", "ambulance", "emergency",
        "dil ka dora", "sans nahi", "behosh", "marne wala",
        "haart attak", "seena dard", "nali cut",
    ],
    "SYMPTOM_QUERY": [
        "fever", "cough", "headache", "dizziness", "nausea", "vomiting",
        "diarrhea", "rash", "itching", "swelling", "fatigue", "weakness",
        "sore throat", "body pain", "stomach pain", "chest pain",
        "bukhar", "sardard", "ulti", "dast", "khasi", "pet dard",
        "jwaro", "tauko dukyo", "khoki", "bet dukyo",
        "hamar pet dukhata ba", "sar mein dard",
    ],
    "MEDICATION_QUERY": [
        "medicine", "tablet", "drug", "paracetamol", "ibuprofen", "antibiotic",
        "dose", "dosage", "side effect", "prescription", "pharmacy",
        "dawai", "dawa", "goli", "aushadhi",
    ],
    "NUTRITION_QUERY": [
        "food", "diet", "eat", "nutrition", "vitamin", "protein", "calories",
        "weight", "healthy food", "what to eat", "foods for",
        "khana", "khaana", "kha", "bhojan", "khaana kha",
    ],
    "EXERCISE_QUERY": [
        "exercise", "workout", "yoga", "walk", "fitness", "gym",
        "physical activity", "running", "weight loss",
        "vyayam", "kasrat", "daud",
    ],
    "PREGNANCY_QUERY": [
        "pregnant", "pregnancy", "prenatal", "trimester", "baby",
        "delivery", "labor", "breastfeeding", "fetus",
        "garbhwati", "prasav", "baccha", "dudh pilana",
    ],
    "CHILDCARE_QUERY": [
        "child", "baby", "infant", "toddler", "vaccination", "kid",
        "pediatric", "newborn", "immunization",
        "bacha", "shishu", "tikakaran",
    ],
    "ELDERLYCARE_QUERY": [
        "elderly", "old age", "senior", "arthritis", "osteoporosis",
        "dementia", "aging", "blood pressure elderly",
        "buzurg", "vriddha", "budha",
    ],
    "MENTAL_HEALTH_QUERY": [
        "stress", "anxiety", "depression", "sad", "lonely", "mental health",
        "sleep", "insomnia", "panic", "fear", "therapy",
        "chinta", "ghabrahat", "udaas", "nind nahi",
    ],
    "GENERAL_MEDICAL": [
        "disease", "condition", "health", "doctor", "hospital", "treatment",
        "diabetes", "hypertension", "asthma", "allergy", "infection",
        "bimari", "doctor", "aspatal",
    ],
    "GENERAL_CHAT": [
        "hello", "hi", "how are you", "good morning", "thank you",
        "what can you do", "help", "who are you", "namaste", "namaskar",
    ],
    "FOLLOW_UP_QUERY": [
        "what about", "tell me more", "and also", "what else",
        "can you explain", "you said", "continue", "go on",
    ],
}

TEMPLATES = [
    "{kw}", "I have {kw}", "what is {kw}", "tell me about {kw}",
    "help me with {kw}", "I feel {kw}", "my {kw} is bad",
    "suffering from {kw}", "dealing with {kw}", "{kw} problem",
    "question about {kw}", "{kw} treatment", "{kw} ho raha hai",
    "{kw} lag raha hai", "{kw} bhayo", "mujhe {kw} hai",
    "hamar {kw} ba",
]


def build_training_data(
    disease_data: dict,
    medquad: pd.DataFrame,
) -> tuple[list[str], list[str]]:
    """Build (texts, labels) training pairs."""
    X, y = [], []

    # ── 1. Keyword templates ──────────────────────────────────────────────
    for intent, keywords in INTENT_KEYWORDS.items():
        for kw in keywords:
            for tpl in TEMPLATES:
                X.append(tpl.format(kw=kw).lower())
                y.append(intent)

    # ── 2. MedQuAD questions → GENERAL_MEDICAL / intent by keyword ────────
    if not medquad.empty and "question" in medquad.columns:
        for _, row in medquad.sample(min(8000, len(medquad)), random_state=42).iterrows():
            q = str(row.get("question", "")).strip().lower()
            if not q or q == "nan":
                continue
            label = _classify_by_keyword(q)
            X.append(q)
            y.append(label)

    # ── 3. Disease descriptions → SYMPTOM / GENERAL_MEDICAL ──────────────
    desc_df = disease_data.get("descriptions")
    if desc_df is not None and "Disease" in desc_df.columns:
        col = "Description" if "Description" in desc_df.columns else desc_df.columns[-1]
        for _, row in desc_df.iterrows():
            disease = str(row.get("Disease", "")).strip().lower()
            desc    = str(row.get(col, "")).strip().lower()
            if disease and disease != "nan":
                X.append(f"what is {disease}")
                y.append("GENERAL_MEDICAL")
                X.append(f"symptoms of {disease}")
                y.append("SYMPTOM_QUERY")
            if desc and len(desc) > 20:
                X.append(desc[:200])
                y.append("GENERAL_MEDICAL")

    # ── 4. Symptom names → SYMPTOM_QUERY ──────────────────────────────────
    sym_df = disease_data.get("symptoms")
    if sym_df is not None:
        sym_cols = [c for c in sym_df.columns if c.lower().startswith("symptom")]
        symptoms: set[str] = set()
        for col in sym_cols:
            for s in sym_df[col].dropna().unique():
                s = str(s).strip().replace("_", " ").lower()
                if s and s != "nan":
                    symptoms.add(s)
        for sym in symptoms:
            X.append(f"I have {sym}")
            y.append("SYMPTOM_QUERY")
            X.append(f"what does {sym} mean")
            y.append("SYMPTOM_QUERY")

    log.info(f"Training data: {len(X):,} samples, {len(set(y))} classes")
    return X, y


def _classify_by_keyword(text: str) -> str:
    """Quick rule-based intent assignment for MedQuAD rows."""
    text = text.lower()
    if any(k in text for k in ["emergency", "urgent", "stroke", "heart attack", "overdose"]):
        return "EMERGENCY_QUERY"
    if any(k in text for k in ["symptom", "sign", "feel", "experience", "pain", "ache"]):
        return "SYMPTOM_QUERY"
    if any(k in text for k in ["medicine", "drug", "dose", "treatment", "therapy"]):
        return "MEDICATION_QUERY"
    if any(k in text for k in ["diet", "food", "eat", "nutrition", "vitamin"]):
        return "NUTRITION_QUERY"
    if any(k in text for k in ["exercise", "physical", "workout", "yoga"]):
        return "EXERCISE_QUERY"
    if any(k in text for k in ["pregnancy", "pregnant", "fetus", "baby"]):
        return "PREGNANCY_QUERY"
    if any(k in text for k in ["child", "infant", "vaccine", "newborn"]):
        return "CHILDCARE_QUERY"
    if any(k in text for k in ["mental", "stress", "depression", "anxiety"]):
        return "MENTAL_HEALTH_QUERY"
    return "GENERAL_MEDICAL"


# ─────────────────────────────────────────────────────────────────────────────
# Step 2b — Train Intent Classifier
# ─────────────────────────────────────────────────────────────────────────────

def train_classifier(X: list[str], y: list[str], output_path: Path) -> None:
    from sklearn.feature_extraction.text import TfidfVectorizer
    from sklearn.linear_model import LogisticRegression
    from sklearn.model_selection import cross_val_score
    import pickle

    log.info("Training TF-IDF + Logistic Regression intent classifier …")
    t0 = time.time()

    vectorizer = TfidfVectorizer(
        ngram_range=(1, 3),
        max_features=30_000,
        sublinear_tf=True,
    )
    X_vec = vectorizer.fit_transform(X)

    model = LogisticRegression(
        max_iter=2000,
        C=2.0,
        class_weight="balanced",
        solver="lbfgs",
        multi_class="multinomial",
    )
    model.fit(X_vec, y)
    model.classes_ = model.classes_

    # Quick cross-val estimate
    try:
        scores = cross_val_score(model, X_vec, y, cv=3, scoring="accuracy")
        log.info(f"Cross-val accuracy: {scores.mean():.3f} ± {scores.std():.3f}")
    except Exception as e:
        log.debug(f"Cross-val skipped: {e}")

    bundle = {"vectorizer": vectorizer, "model": model}
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "wb") as f:
        pickle.dump(bundle, f)

    elapsed = time.time() - t0
    log.info(f"Intent classifier saved → {output_path}  ({elapsed:.1f}s)")


# ─────────────────────────────────────────────────────────────────────────────
# Step 3 — Build FAISS Index
# ─────────────────────────────────────────────────────────────────────────────

def build_faiss_index(
    disease_data: dict,
    medquad: pd.DataFrame,
    output_dir: Path,
    force: bool = False,
) -> None:
    manifest = output_dir / "manifest.json"
    if manifest.exists() and not force:
        log.info(f"FAISS index already exists at {output_dir}. Use --force to rebuild.")
        return

    try:
        from ai_models.vector_database.faiss_engine import FAISSEngine, IndexedDocument
        from ai_models.embeddings.embedding_service import EmbeddingService
    except ImportError as e:
        log.error(f"Cannot import AI modules: {e}. Run from project root.")
        return

    log.info("Loading embedding model (all-MiniLM-L6-v2) …")
    emb = EmbeddingService()
    log.info(f"Embedding dim = {emb.dim}")

    # ── Collect documents ─────────────────────────────────────────────────
    docs: list[IndexedDocument] = []

    # MedQuAD
    if not medquad.empty and "question" in medquad.columns:
        ans_col = next(
            (c for c in ("answer", "answers", "response") if c in medquad.columns),
            None,
        )
        for i, row in medquad.iterrows():
            if len(docs) >= 16_000:
                break
            q = str(row.get("question", "")).strip()
            a = str(row.get(ans_col, "")).strip() if ans_col else ""
            if not q or q == "nan":
                continue
            docs.append(
                IndexedDocument(
                    doc_id=f"mq_{i}",
                    text=q,
                    answer=a[:500] if a and a != "nan" else None,
                    category="medquad",
                )
            )
        log.info(f"MedQuAD docs: {len(docs):,}")

    # Disease descriptions
    desc_df = disease_data.get("descriptions")
    prec_df = disease_data.get("precautions")
    sym_df  = disease_data.get("symptoms")

    desc_map: dict[str, str] = {}
    prec_map: dict[str, list[str]] = {}

    if desc_df is not None and "Disease" in desc_df.columns:
        desc_col = "Description" if "Description" in desc_df.columns else desc_df.columns[-1]
        for _, r in desc_df.iterrows():
            name = str(r.get("Disease", "")).strip()
            desc = str(r.get(desc_col, "")).strip()
            if name and name != "nan" and desc and desc != "nan":
                desc_map[name.lower()] = desc

    if prec_df is not None and "Disease" in prec_df.columns:
        for _, r in prec_df.iterrows():
            name = str(r.get("Disease", "")).strip()
            if not name or name == "nan":
                continue
            precs = [
                str(r.get(f"Precaution_{i}", "")).strip()
                for i in range(1, 5)
                if str(r.get(f"Precaution_{i}", "")).strip() not in ("", "nan")
            ]
            if precs:
                prec_map[name.lower()] = precs

    if sym_df is not None and "Disease" in sym_df.columns:
        sym_cols = [c for c in sym_df.columns if c.lower().startswith("symptom")]
        seen: set[str] = set()
        for _, row in sym_df.iterrows():
            disease = str(row.get("Disease", "")).strip()
            if not disease or disease == "nan" or disease.lower() in seen:
                continue
            seen.add(disease.lower())

            symptoms = [
                str(row[c]).strip().replace("_", " ")
                for c in sym_cols
                if pd.notna(row[c]) and str(row[c]).strip() not in ("", "nan")
            ]
            desc   = desc_map.get(disease.lower(), "")
            precs  = prec_map.get(disease.lower(), [])
            sym_str  = ", ".join(symptoms[:8])
            prec_str = "; ".join(precs[:4]) if precs else "consult a doctor"

            q = f"What are the symptoms and precautions for {disease}?"
            a = (
                f"{disease}: {desc}  " if desc else f"{disease}: "
            ) + f"Symptoms: {sym_str}. Precautions: {prec_str}."

            docs.append(
                IndexedDocument(
                    doc_id=f"ds_{disease.lower().replace(' ', '_')}",
                    text=q,
                    answer=a[:600],
                    category="disease_symptom",
                    metadata={"disease": disease},
                )
            )
            for sym in symptoms[:4]:
                docs.append(
                    IndexedDocument(
                        doc_id=f"sym_{disease.lower()[:20]}_{sym[:20]}",
                        text=f"I have {sym}. What could it be?",
                        answer=(
                            f"Having {sym} can be associated with {disease}. "
                            f"{desc[:200] if desc else ''} Precautions: {prec_str}."
                        ).strip(),
                        category="symptom_lookup",
                    )
                )

    log.info(f"Total documents to index: {len(docs):,}")

    # ── Encode in batches ─────────────────────────────────────────────────
    BATCH = 128
    all_embs: list[np.ndarray] = []
    texts = [d.text for d in docs]

    for start in range(0, len(texts), BATCH):
        batch = texts[start: start + BATCH]
        vecs  = emb.embed_batch(batch)
        all_embs.append(vecs)
        if (start // BATCH) % 20 == 0:
            log.info(f"  Encoded {min(start + BATCH, len(texts)):,} / {len(texts):,}")

    embeddings = np.vstack(all_embs).astype(np.float32)
    log.info(f"Embeddings shape: {embeddings.shape}")

    # ── Build & save ──────────────────────────────────────────────────────
    engine = FAISSEngine(dim=emb.dim)
    engine.build_index(docs, embeddings)
    output_dir.mkdir(parents=True, exist_ok=True)
    engine.save(output_dir)
    log.info(f"FAISS index saved → {output_dir}  (docs={engine.total_documents:,})")


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

def main() -> None:
    parser = argparse.ArgumentParser(description="Train AI Medical Chatbot offline models")
    parser.add_argument("--force",    action="store_true", help="Rebuild even if models exist")
    parser.add_argument("--no-faiss", action="store_true", help="Skip FAISS index build")
    parser.add_argument("--no-clf",   action="store_true", help="Skip intent classifier training")
    args = parser.parse_args()

    t_total = time.time()

    log.info("=" * 60)
    log.info("  AI Medical Chatbot — Offline Training Pipeline")
    log.info("=" * 60)

    # ── Load datasets ─────────────────────────────────────────────────────
    log.info("\n[Step 1/3] Loading datasets …")
    medquad       = load_medquad()
    disease_data  = load_disease_data()

    # ── Train intent classifier ───────────────────────────────────────────
    if not args.no_clf:
        if CLF_PATH.exists() and not args.force:
            log.info(f"\n[Step 2/3] Intent classifier already exists. Use --force to retrain.")
        else:
            log.info("\n[Step 2/3] Building training data & training classifier …")
            X, y = build_training_data(disease_data, medquad)
            train_classifier(X, y, CLF_PATH)
    else:
        log.info("\n[Step 2/3] Skipped (--no-clf)")

    # ── Build FAISS index ─────────────────────────────────────────────────
    if not args.no_faiss:
        log.info("\n[Step 3/3] Building FAISS semantic search index …")
        build_faiss_index(disease_data, medquad, FAISS_DIR, force=args.force)
    else:
        log.info("\n[Step 3/3] Skipped (--no-faiss)")

    elapsed = time.time() - t_total
    log.info(f"\n{'=' * 60}")
    log.info(f"  Training complete in {elapsed:.1f}s")
    log.info(f"  Intent classifier : {CLF_PATH}")
    log.info(f"  FAISS index       : {FAISS_DIR}")
    log.info(f"{'=' * 60}")


if __name__ == "__main__":
    main()
