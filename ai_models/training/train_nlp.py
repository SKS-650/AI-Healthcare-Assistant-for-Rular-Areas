"""Train NLP preprocessing/classification baseline.

This script trains a simple text classifier on disease-related text, if
available.

Best-effort behavior:
- If diseases.csv has disease labels and a text column, it trains TF-IDF +
  LinearSVC.
- If not, it trains a "dummy" preprocessor that normalizes text and saves
  artifacts only.

Outputs:
  ai_models/saved_models/nlp_model.joblib (optional)
  ai_models/saved_models/nlp_preprocessor.joblib
  ai_models/saved_models/nlp_artifacts.json
"""

from __future__ import annotations

import argparse
import json
import os
import re
from dataclasses import dataclass
from typing import Any, Dict, Optional, Tuple

import pandas as pd


def _normalize_text(s: str) -> str:
    s = s.lower().strip()
    s = re.sub(r"[^a-z0-9\s]", " ", s)
    s = re.sub(r"\s+", " ", s)
    return s


def _find_col(df: pd.DataFrame, candidates: list[str]) -> Optional[str]:
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
    parser.add_argument("--diseases-csv", default="datasets/diseases.csv")
    parser.add_argument("--out-dir", default="ai_models/saved_models")
    args = parser.parse_args()

    os.makedirs(args.out_dir, exist_ok=True)

    df = pd.read_csv(args.diseases_csv)

    label_col = _find_col(df, ["disease", "disease_name", "label", "diagnosis", "condition"])
    text_col = _find_col(df, ["description", "symptoms", "text", "notes", "summary", "definition"])

    artifacts: Dict[str, Any] = {
        "script": "train_nlp.py",
        "method": None,
        "model": {"file": None},
        "meta": {
            "has_label": bool(label_col),
            "has_text": bool(text_col),
        },
    }

    # Always save preprocessor.
    try:
        from joblib import dump

        class Preprocessor:
            def transform(self, texts: list[str]) -> list[str]:
                return [_normalize_text(t or "") for t in texts]

        pre = Preprocessor()
        pre_path = os.path.join(args.out_dir, "nlp_preprocessor.joblib")
        dump(pre, pre_path)
        artifacts["preprocessor"] = {"file": os.path.basename(pre_path)}
    except Exception as e:
        artifacts["preprocessor_error"] = repr(e)

    if label_col and text_col:
        # Train classifier.
        try:
            from joblib import dump
            from sklearn.feature_extraction.text import TfidfVectorizer
            from sklearn.svm import LinearSVC
            from sklearn.pipeline import Pipeline

            X = [_normalize_text(str(v)) for v in df[text_col].fillna("").tolist()]
            y = [str(v) for v in df[label_col].fillna("").tolist()]

            # Filter empty.
            filtered = [(xx, yy) for xx, yy in zip(X, y) if xx and yy]
            if len(filtered) >= 10 and len(set([yy for _, yy in filtered])) >= 2:
                Xf = [xx for xx, _ in filtered]
                yf = [yy for _, yy in filtered]

                clf = Pipeline(
                    [
                        ("tfidf", TfidfVectorizer(max_features=50000, ngram_range=(1, 2))),
                        ("clf", LinearSVC()),
                    ]
                )
                clf.fit(Xf, yf)

                model_path = os.path.join(args.out_dir, "nlp_model.joblib")
                dump(clf, model_path)

                artifacts["method"] = "tfidf_linear_svc"
                artifacts["model"]["file"] = os.path.basename(model_path)
                artifacts["meta"]["training_size"] = len(yf)
                artifacts["meta"]["num_labels"] = len(set(yf))
            else:
                artifacts["method"] = "preprocessor_only"
        except Exception as e:
            artifacts["method"] = "preprocessor_only"
            artifacts["meta"]["training_error"] = repr(e)
    else:
        artifacts["method"] = "preprocessor_only"

    with open(os.path.join(args.out_dir, "nlp_artifacts.json"), "w", encoding="utf-8") as f:
        json.dump(artifacts, f, indent=2)

    print("[OK] Wrote NLP artifacts.")


if __name__ == "__main__":
    main()

