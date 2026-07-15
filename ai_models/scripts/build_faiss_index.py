#!/usr/bin/env python3
"""
Build FAISS Index from MedQuAD + DiseaseSymptom datasets.

Run once (or whenever the datasets change):
    python ai_models/scripts/build_faiss_index.py

Takes ~5–20 minutes depending on hardware. Uses all-MiniLM-L6-v2
(downloaded automatically by sentence-transformers on first run).

Output:
    ai_models/saved_models/faiss_index/index.faiss
    ai_models/saved_models/faiss_index/documents.pkl
    ai_models/saved_models/faiss_index/manifest.json
"""

from __future__ import annotations

import logging
import sys
import time
from pathlib import Path

# ── ensure project root is on sys.path ───────────────────────────────────────
_ROOT = Path(__file__).parent.parent.parent          # project root
if str(_ROOT) not in sys.path:
    sys.path.insert(0, str(_ROOT))

import numpy as np
import pandas as pd

from ai_models.vector_database.faiss_engine import FAISSEngine, IndexedDocument
from ai_models.embeddings.embedding_service import EmbeddingService

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(message)s",
    datefmt="%H:%M:%S",
)
log = logging.getLogger("build_faiss_index")

# ── Paths ─────────────────────────────────────────────────────────────────────
DATASETS_ROOT  = _ROOT / "datasets" / "chatbot_dataset"
OUTPUT_DIR     = _ROOT / "ai_models" / "saved_models" / "faiss_index"
MEDQUAD_CSV    = DATASETS_ROOT / "MedQuAD_Dataset"   / "medquad.csv"
DISEASE_CSV    = DATASETS_ROOT / "DiseaseSymptomPredictionDataset" / "dataset.csv"
DESC_CSV       = DATASETS_ROOT / "DiseaseSymptomPredictionDataset" / "symptom_Description.csv"
PRECAUTION_CSV = DATASETS_ROOT / "DiseaseSymptomPredictionDataset" / "symptom_precaution.csv"

# ── Config ────────────────────────────────────────────────────────────────────
BATCH_SIZE   = 128
MAX_MEDQUAD  = 16_000    # cap to keep index manageable; set None for all
MIN_ANSWER_LEN = 20      # skip answers shorter than this


# ─── Loaders ─────────────────────────────────────────────────────────────────

def load_medquad(path: Path) -> list[IndexedDocument]:
    """Load MedQuAD Q&A pairs."""
    if not path.exists():
        log.warning(f"MedQuAD CSV not found: {path}")
        return []

    df = pd.read_csv(path, na_filter=True)
    log.info(f"MedQuAD raw rows: {len(df)}")

    # Normalise column names (some versions use different capitalisation)
    df.columns = [c.strip().lower() for c in df.columns]
    if "question" not in df.columns:
        log.error("MedQuAD CSV missing 'question' column — columns: %s", df.columns.tolist())
        return []

    answer_col = next((c for c in ("answer", "answers", "response") if c in df.columns), None)

    docs: list[IndexedDocument] = []
    for i, row in df.iterrows():
        if MAX_MEDQUAD and len(docs) >= MAX_MEDQUAD:
            break
        q = str(row.get("question", "")).strip()
        a = str(row.get(answer_col, "")).strip() if answer_col else ""
        if not q or q == "nan":
            continue
        if answer_col and (not a or a == "nan" or len(a) < MIN_ANSWER_LEN):
            a = ""
        # Index question text; answer stored as payload
        docs.append(IndexedDocument(
            doc_id   = f"mq_{i}",
            text     = q,
            answer   = a[:600] if a else None,
            category = "medquad",
            metadata = {"source": "MedQuAD"},
        ))

    log.info(f"MedQuAD documents prepared: {len(docs)}")
    return docs


def load_disease_symptom(
    disease_csv: Path,
    desc_csv: Path,
    precaution_csv: Path,
) -> list[IndexedDocument]:
    """Convert disease-symptom dataset rows into searchable QA documents."""
    if not disease_csv.exists():
        log.warning(f"Disease CSV not found: {disease_csv}")
        return []

    df        = pd.read_csv(disease_csv)
    desc_df   = pd.read_csv(desc_csv)   if desc_csv.exists()       else None
    prec_df   = pd.read_csv(precaution_csv) if precaution_csv.exists() else None

    # Build lookup dicts
    desc_map: dict[str, str] = {}
    prec_map: dict[str, list[str]] = {}

    if desc_df is not None:
        desc_df.columns = [c.strip() for c in desc_df.columns]
        for _, r in desc_df.iterrows():
            name = str(r.get("Disease", "")).strip()
            desc = str(r.get("Description", "")).strip()
            if name and desc and desc != "nan":
                desc_map[name.lower()] = desc

    if prec_df is not None:
        prec_df.columns = [c.strip() for c in prec_df.columns]
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

    df.columns = [c.strip() for c in df.columns]
    sym_cols   = [c for c in df.columns if c.lower().startswith("symptom")]
    docs: list[IndexedDocument] = []
    seen: set[str] = set()

    for _, row in df.iterrows():
        disease = str(row.get("Disease", "")).strip()
        if not disease or disease == "nan" or disease.lower() in seen:
            continue
        seen.add(disease.lower())

        symptoms = [
            str(row[c]).strip().replace("_", " ")
            for c in sym_cols
            if pd.notna(row[c]) and str(row[c]).strip() not in ("", "nan")
        ]

        desc  = desc_map.get(disease.lower(), "")
        precs = prec_map.get(disease.lower(), [])

        # Build a natural-language question + answer pair
        sym_str  = ", ".join(symptoms[:8]) if symptoms else "various symptoms"
        prec_str = "; ".join(precs[:4])   if precs    else "consult a doctor"

        question = f"What are the symptoms and precautions for {disease}?"
        answer   = (
            f"{disease}: {desc}  " if desc else f"{disease}: "
        ) + (
            f"Common symptoms include {sym_str}. "
            f"Precautions: {prec_str}."
        )

        docs.append(IndexedDocument(
            doc_id   = f"ds_{disease.lower().replace(' ', '_')}",
            text     = question,
            answer   = answer[:600],
            category = "disease_symptom",
            metadata = {"disease": disease, "symptoms": symptoms[:8]},
        ))

        # Also add individual symptom → disease lookup docs
        for sym in symptoms[:5]:
            docs.append(IndexedDocument(
                doc_id   = f"sym_{disease.lower().replace(' ','_')}_{sym[:20]}",
                text     = f"I have {sym}. What disease could it be?",
                answer   = (
                    f"Having {sym} can be associated with {disease}. "
                    f"{desc[:200] if desc else ''} "
                    f"Precautions: {prec_str}."
                ).strip(),
                category = "symptom_lookup",
                metadata = {"disease": disease, "symptom": sym},
            ))

    log.info(f"Disease-symptom documents prepared: {len(docs)}")
    return docs


# ─── Main ─────────────────────────────────────────────────────────────────────

def build(force: bool = False) -> None:
    manifest = OUTPUT_DIR / "manifest.json"
    if manifest.exists() and not force:
        log.info("FAISS index already exists at %s. Use --force to rebuild.", OUTPUT_DIR)
        return

    t_start = time.time()

    # 1. Load documents
    log.info("Loading MedQuAD dataset …")
    medquad_docs  = load_medquad(MEDQUAD_CSV)

    log.info("Loading disease-symptom datasets …")
    disease_docs  = load_disease_symptom(DISEASE_CSV, DESC_CSV, PRECAUTION_CSV)

    all_docs = medquad_docs + disease_docs
    if not all_docs:
        log.error("No documents loaded — check dataset paths and CSVs.")
        sys.exit(1)

    log.info(f"Total documents: {len(all_docs):,}  (medquad={len(medquad_docs)}, disease={len(disease_docs)})")

    # 2. Load embedding model
    log.info("Loading sentence-transformer model (all-MiniLM-L6-v2) …")
    emb_service = EmbeddingService()
    log.info(f"Embedding dim = {emb_service.dim}")

    # 3. Encode all texts in batches
    log.info("Encoding documents …")
    texts = [doc.text for doc in all_docs]

    all_embeddings: list[np.ndarray] = []
    for start in range(0, len(texts), BATCH_SIZE):
        batch = texts[start: start + BATCH_SIZE]
        vecs  = emb_service.embed_batch(batch)
        all_embeddings.append(vecs)
        if (start // BATCH_SIZE) % 10 == 0:
            log.info(f"  Encoded {min(start + BATCH_SIZE, len(texts)):,} / {len(texts):,}")

    embeddings = np.vstack(all_embeddings).astype(np.float32)
    log.info(f"Embeddings shape: {embeddings.shape}")

    # 4. Build FAISS index
    log.info("Building FAISS index …")
    engine = FAISSEngine(dim=emb_service.dim)
    engine.build_index(all_docs, embeddings)

    # 5. Save
    log.info(f"Saving index to {OUTPUT_DIR} …")
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    engine.save(OUTPUT_DIR)

    elapsed = time.time() - t_start
    log.info(f"Done! Index built in {elapsed:.1f}s — {engine.total_documents:,} vectors saved.")
    log.info(f"Stats: {engine.get_stats()}")


if __name__ == "__main__":
    force_rebuild = "--force" in sys.argv
    build(force=force_rebuild)
