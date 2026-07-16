
## AI Models — Project Model Hub & Pipelines

This module contains the model training code, experiment artifacts, embedding pipelines, and utilities for deploying models for inference. It is the canonical place to find training scripts, saved artifacts, and evaluation code.

Structure & notable directories

- `ai_models/symptom_checker/` — training scripts, preprocessing, saved model artifacts
- `ai_models/embeddings/` — code to create text embeddings for retrieval and similarity
- `ai_models/llm/` — prompt templates, wrappers for LLM providers and local adapters
- `ai_models/vector_database/` — vector store helpers and retrieval utilities
- `ai_models/emergency_detection/` — detectors and model artifacts

---

1) Model lifecycle (concrete)

Typical pipeline used in the project:

1. Data collection & curation: datasets stored in `datasets/` and curated into training-ready CSV/JSON.
2. Preprocessing & feature engineering: scripts under each model folder transform raw data into feature matrices.
3. Training & hyperparameter tuning: `train.py` uses scikit-learn / LightGBM / PyTorch depending on model type.
4. Evaluation: compute metrics, calibration, and save evaluation reports.
5. Artifact packaging: save model, vector indices, experiment metadata (training hash, dataset version, metrics) into `saved_models/`.
6. Deploy: copy artifacts to `backend` or deploy as a separate inference service.

---

2) Embeddings & vector store

- Embeddings are used by the chatbot retrieval pipeline and for semantic similarity tasks. The repo provides utilities to:
	- compute embeddings for documents and queries
	- chunk and index documents with metadata
	- run nearest-neighbor retrieval using cosine similarity

Indexing best practices

- Use overlapping chunks to preserve context across boundaries.
- Store metadata (source path, offset, title) to enable citation in chatbot responses.

---

3) Experiment tracking & reproducibility

- Each experiment run writes a metadata JSON including:
	- `model_version`
	- `training_data_hash`
	- `hyperparameters`
	- `metrics`

- For reproducibility, save random seeds and environment details.

---

4) Model formats & deployment

- Tabular models: `pickle` or `joblib` for scikit-learn/LightGBM models (in `saved_models/`).
- Embedding indices: vector index files (FAISS flat or IVF indices) and metadata store (parquet/csv).
- LLM prompts: prompt templates and system instruction files stored under `ai_models/llm/prompts`.

Deployment patterns

- In-process: load `pickle` model and run `predict_proba` in the backend process (suitable for symptom-checker).
- Microservice: host heavy models externally (GPU-backed) and call over gRPC/HTTP with batching.

---

5) Evaluation & monitoring in production

- Continuously compute model metrics via a monitoring job: top-k recall, calibration error, emergency false negative rate. Store logs for drift detection.
- Maintain a model registry (artifact + metadata) and only promote models passing acceptance tests.

---

6) Prompts & LLM engineering

- Keep prompt templates under version control and include test prompts to detect regressions when providers or prompt wording changes.
- Use a prompt scoring harness to compare provider outputs on a fixed evaluation set.

---

7) Reproducible training example (commands)

```powershell
cd ai_models/symptom_checker
python training/train.py --config configs/train_local.yaml
```

The `train.py` script writes artifacts to `ai_models/symptom_checker/saved_models/{version}/`.

---

8) Glossary & terms

- Artifact: saved model file plus metadata used for inference.
- Embedding: numeric vector representing text semantics.
- Vector index: data structure for nearest neighbor search (FAISS/Annoy-based).

---

9) Links to artifacts

- Symptom-checker models: [ai_models/symptom_checker/saved_models](ai_models/symptom_checker/saved_models#L1)
- Embeddings: [ai_models/embeddings](ai_models/embeddings#L1)
