"""Train chatbot baseline (retrieval + templates).

This script creates a lightweight medical-response retrieval baseline.

If datasets contain conversation-like data (prompt/response), it trains a
TF-IDF + nearest-neighbor retrieval.

Otherwise it falls back to template responses and stores them as artifacts.

Outputs:
  ai_models/saved_models/chatbot_model.joblib  (optional)
  ai_models/saved_models/chatbot_artifacts.json
"""

from __future__ import annotations

import argparse
import json
import os
import re
from typing import Any, Dict, List, Optional, Tuple

import pandas as pd


def _normalize_text(s: str) -> str:
    s = s.lower().strip()
    s = re.sub(r"\s+", " ", s)
    return s


def _find_col(df: pd.DataFrame, candidates: List[str]) -> Optional[str]:
    lower_map = {str(c).strip().lower(): c for c in df.columns}
    for cand in candidates:
        if cand in lower_map:
            return lower_map[cand]
    for cand in candidates:
        for c in df.columns:
            if cand in str(c).strip().lower():
                return c
    return None


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--datasets-dir", default="datasets")
    parser.add_argument("--out-dir", default="ai_models/saved_models")
    args = parser.parse_args()

    os.makedirs(args.out_dir, exist_ok=True)

    # Try to find a dataset that might contain Q/A.
    # No strong assumptions—use best-effort column detection.
    qa_pairs: List[Tuple[str, str]] = []

    candidate_files = [
        os.path.join(args.datasets_dir, "emergency.csv"),
        os.path.join(args.datasets_dir, "diseases.csv"),
        os.path.join(args.datasets_dir, "symptoms.csv"),
        os.path.join(args.datasets_dir, "medicines.csv"),
    ]

    for fp in candidate_files:
        if not os.path.exists(fp):
            continue
        try:
            df = pd.read_csv(fp)
        except Exception:
            continue

        prompt_col = _find_col(df, ["question", "prompt", "query", "user", "symptom", "input"])
        response_col = _find_col(df, ["response", "answer", "output", "advice", "recommendation", "diagnosis"])

        if prompt_col and response_col and len(df) > 0:
            for _, row in df.iterrows():
                q = row.get(prompt_col)
                a = row.get(response_col)
                if pd.isna(q) or pd.isna(a):
                    continue
                qn = _normalize_text(str(q))
                an = str(a).strip()
                if qn and an:
                    qa_pairs.append((qn, an))

    artifacts: Dict[str, Any] = {
        "script": "train_chatbot.py",
        "method": None,
        "model": {"file": None},
        "templates": [],
        "meta": {"num_pairs": len(qa_pairs)},
    }

    if len(qa_pairs) >= 20:
        # Train retrieval baseline.
        try:
            from joblib import dump
            from sklearn.feature_extraction.text import TfidfVectorizer
            from sklearn.neighbors import NearestNeighbors
            from scipy.sparse import csr_matrix

            questions = [q for q, _ in qa_pairs]
            answers = [a for _, a in qa_pairs]

            vectorizer = TfidfVectorizer(max_features=50000, ngram_range=(1, 2))
            X = vectorizer.fit_transform(questions)

            # NearestNeighbors works with cosine distance via metric='cosine'.
            nn = NearestNeighbors(n_neighbors=5, metric="cosine")
            nn.fit(X)

            model_path = os.path.join(args.out_dir, "chatbot_model.joblib")
            dump(
                {"vectorizer": vectorizer, "nn": nn, "answers": answers},
                model_path,
            )

            artifacts["method"] = "tfidf_retrieval"
            artifacts["model"]["file"] = os.path.basename(model_path)
            artifacts["meta"]["num_questions"] = len(questions)

            print(f"[OK] Trained chatbot retrieval model. Saved: {model_path}")
        except Exception as e:
            artifacts["method"] = "template_fallback"
            artifacts["meta"]["training_error"] = repr(e)
    else:
        artifacts["method"] = "template_fallback"

    if artifacts["method"] != "tfidf_retrieval":
        # Store basic medical-information templates.
        artifacts["templates"] = [
            "I can share general health information. For emergencies, call your local emergency number.",
            "Describe your symptoms (age, duration, severity). I can suggest possible causes and next steps.",
            "If you have chest pain, trouble breathing, fainting, or severe bleeding, seek urgent care immediately.",
        ]

    with open(os.path.join(args.out_dir, "chatbot_artifacts.json"), "w", encoding="utf-8") as f:
        json.dump(artifacts, f, indent=2)

    print("[OK] Wrote chatbot artifacts.")


if __name__ == "__main__":
    main()

