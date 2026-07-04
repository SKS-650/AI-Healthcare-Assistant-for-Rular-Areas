"""Train disease model (baseline).

This script is intentionally lightweight and designed to work even if the
CSV schemas are minimal.

It tries, in order:
1) If datasets contain explicit symptom -> disease mapping, train a text-like
   classifier on symptom sets.
2) Otherwise, train a simple baseline that predicts the most frequent disease
   label it can find.

Artifacts are written to:
  ai_models/saved_models/

Usage:
  python ai_models/training/train_disease_model.py \
    --diseases-csv datasets/diseases.csv \
    --symptoms-csv datasets/symptoms.csv \
    --out-dir ai_models/saved_models
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
from dataclasses import dataclass
from typing import Any, Dict, List, Optional, Tuple

import pandas as pd


def _sha256_file(path: str) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def _normalize_colnames(df: pd.DataFrame) -> Dict[str, str]:
    mapping: Dict[str, str] = {}
    for c in df.columns:
        key = str(c).strip().lower().replace(" ", "_")
        mapping[c] = key
    return mapping


def _find_first_column(df: pd.DataFrame, candidates: List[str]) -> Optional[str]:
    cols = {str(c).strip().lower(): c for c in df.columns}
    for cand in candidates:
        if cand in cols:
            return cols[cand]
    # also allow partial matches
    lower_cols = [str(c).strip().lower() for c in df.columns]
    for cand in candidates:
        for c in df.columns:
            if cand in str(c).strip().lower():
                return c
    return None


@dataclass
class TrainOutcome:
    method: str
    info: Dict[str, Any]


def _load_diseases(diseases_csv: str) -> pd.DataFrame:
    return pd.read_csv(diseases_csv)


def _load_symptoms(symptoms_csv: str) -> pd.DataFrame:
    return pd.read_csv(symptoms_csv)


def _extract_label_column(df: pd.DataFrame) -> Optional[str]:
    return _find_first_column(df, [
        "disease",
        "disease_name",
        "label",
        "diagnosis",
        "condition",
    ])


def _extract_symptom_column(df: pd.DataFrame) -> Optional[str]:
    return _find_first_column(df, [
        "symptom",
        "symptom_name",
        "symptoms",
        "feature",
    ])


def _extract_mapping(diseases_df: pd.DataFrame, symptoms_df: pd.DataFrame) -> Tuple[Optional[List[str]], Optional[List[str]]]:
    """Try to get (symptom_text, disease_label) pairs.

    Returns (x_symptoms, y_diseases) or (None, None) if not possible.
    """

    # Prefer explicit mapping column in symptoms_df if exists.
    symptom_col = _extract_symptom_column(symptoms_df)
    disease_col = _extract_label_column(symptoms_df)

    if symptom_col and disease_col:
        x = symptoms_df[symptom_col].astype(str).fillna("").tolist()
        y = symptoms_df[disease_col].astype(str).fillna("").tolist()
        return x, y

    # If diseases_df has symptom lists, try to use them.
    diseasename_col = _extract_label_column(diseases_df)
    if not diseasename_col:
        return None, None

    # Look for columns that might store symptoms.
    symptom_list_col = _find_first_column(diseases_df, [
        "symptoms",
        "symptom_list",
        "has_symptoms",
        "symptom_names",
    ])

    if symptom_list_col:
        x = diseases_df[symptom_list_col].astype(str).fillna("").tolist()
        y = diseases_df[diseasename_col].astype(str).fillna("").tolist()
        return x, y

    return None, None


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--diseases-csv", default="datasets/diseases.csv")
    parser.add_argument("--symptoms-csv", default="datasets/symptoms.csv")
    parser.add_argument("--out-dir", default="ai_models/saved_models")
    args = parser.parse_args()

    os.makedirs(args.out_dir, exist_ok=True)
    diseases_df = _load_diseases(args.diseases_csv)
    symptoms_df = _load_symptoms(args.symptoms_csv)

    outcome = TrainOutcome(method="unknown", info={})

    x_sym, y = _extract_mapping(diseases_df, symptoms_df)

    meta: Dict[str, Any] = {
        "script": "train_disease_model.py",
        "dataset_files": {
            "diseases_csv": args.diseases_csv,
            "symptoms_csv": args.symptoms_csv,
        },
    }

    # Always store dataset hashes if files exist.
    for p in [args.diseases_csv, args.symptoms_csv]:
        try:
            meta.setdefault("dataset_hashes", {})[p] = _sha256_file(p)
        except OSError:
            pass

    if x_sym is not None and y is not None and len(y) > 0 and len(set(y)) > 1:
        # Try to train a sklearn model.
        try:
            from joblib import dump
            from sklearn.feature_extraction.text import TfidfVectorizer
            from sklearn.linear_model import LogisticRegression
            from sklearn.pipeline import Pipeline

            # Treat input as "text" (symptom name(s)).
            # If the symptom field contains comma-separated lists, TF-IDF still works.
            X = [str(s) for s in x_sym]
            y_labels = [str(lbl) for lbl in y]

            pipe = Pipeline(
                [
                    ("tfidf", TfidfVectorizer(ngram_range=(1, 2), max_features=50000)),
                    ("clf", LogisticRegression(max_iter=200, n_jobs=1)),
                ]
            )
            pipe.fit(X, y_labels)

            model_path = os.path.join(args.out_dir, "disease_model.joblib")
            dump(pipe, model_path)

            outcome.method = "tfidf_logreg"
            meta["training_size"] = len(y_labels)
            meta["num_labels"] = len(set(y_labels))
            meta["label_sample"] = list(sorted(set(y_labels)))[:10]

            artifacts = {
                "method": outcome.method,
                "model": {"file": os.path.basename(model_path)},
                "artifacts": {},
                "meta": meta,
            }

            with open(os.path.join(args.out_dir, "disease_artifacts.json"), "w", encoding="utf-8") as f:
                json.dump(artifacts, f, indent=2)

            print(f"[OK] Trained disease model using {outcome.method}. Saved: {model_path}")
            return
        except Exception as e:
            # Fall back below.
            outcome.info["ml_training_error"] = repr(e)

    # Fallback: most frequent disease label.
    label_col = _extract_label_column(symptoms_df) or _extract_label_column(diseases_df)
    if not label_col:
        # No labels found at all.
        most_frequent = None
        label_dist = {}
    else:
        vc = symptoms_df[label_col].astype(str).value_counts() if label_col in symptoms_df.columns else None
        if vc is None and label_col in diseases_df.columns:
            vc = diseases_df[label_col].astype(str).value_counts()
        if vc is None:
            most_frequent = None
            label_dist = {}
        else:
            most_frequent = str(vc.index[0]) if len(vc) > 0 else None
            label_dist = {str(k): int(v) for k, v in vc.head(20).to_dict().items()}

    artifacts = {
        "method": "most_frequent_baseline",
        "model": {"file": None},
        "meta": {**meta, "label_dist_top20": label_dist, "most_frequent": most_frequent},
        "artifacts": {"most_frequent": most_frequent},
    }
    with open(os.path.join(args.out_dir, "disease_artifacts.json"), "w", encoding="utf-8") as f:
        json.dump(artifacts, f, indent=2)

    print("[WARN] Could not train ML model from available schema; wrote baseline artifacts.")


if __name__ == "__main__":
    main()

