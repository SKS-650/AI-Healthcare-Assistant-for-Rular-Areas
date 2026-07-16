## Symptom Checker (SympCheck)

**Overview**

The Symptom Checker is a hybrid triage and diagnosis-assist module that converts user-reported signs and symptoms into a ranked list of probable conditions and triage recommendations. It is designed to be lightweight, interpretable, and safe for integration into low-resource mobile deployments. Key outputs are:

- Ranked conditions with confidence scores
- A triage level (emergency / urgent / non-urgent)
- Suggested next steps and red-flag alerts

This module is implemented as a reusable backend service (`backend/app/symptom_checker`) backed by a trained model artifact in `ai_models/symptom_checker/saved_models` and is invoked by the mobile UI and other services (e.g., admin review, chatbot fallback).

---

1. Background & theory

Symptom checking is fundamentally a supervised classification and decision problem. Given a set of observed symptoms S and patient metadata M (age, sex, comorbidities), the objective is to estimate the probability distribution over a fixed set of clinical conditions C and produce actionable triage guidance.

- Bayesian view: compute posterior P(c | S, M) for each condition c ∈ C. In practice we approximate this via a discriminative classifier trained on labeled patient-cases.
- Hybrid rule + model: deterministic rules (red flags) are applied before or after the model output to ensure safety-critical conditions are never suppressed by model uncertainty.

Mathematical formulation

Let x ∈ ℝ^d be the engineered feature vector produced from symptoms S and metadata M. A classifier fθ produces logits z = fθ(x). Probabilities are obtained by softmax:

$$
P(c\mid x)=\frac{e^{z_c}}{\sum_{j} e^{z_j}}.
$$

The training objective (multi-class) is cross-entropy:

$$
L(θ) = -\frac{1}{N}\sum_{i=1}^N \sum_{c=1}^C y_{i,c} \log P(c\mid x_i; θ)
$$

Where y_{i,c} is the one-hot label for sample i.

For probabilistic calibration, a post-hoc calibration transform (e.g., Platt scaling) may be applied to raw classifier scores to produce better-calibrated probabilities.

---

2. Data & features

- Source datasets: curated clinical symptom-condition mappings in `datasets/symptoms_datasets`, supplemented by synthetic augmentation used in `ai_models/symptom_checker/datasets`.
- Feature types:
  - Binary symptom presence (one-hot) b_i
  - Symptom severity (ordinal or numeric)
  - Symptom duration (hours/days)
  - Demographics: age (numeric), sex (one-hot), comorbidity flags
  - Context flags: recent travel, pregnancy, immunosuppression

Feature vector example

$$
x = [b_1, ..., b_m, s_1, ..., s_m, duration_1, ..., age, sex_{male}, sex_{female}, comorb_1, ...].
$$

Preprocessing steps

- Normalize numeric fields (age, duration)
- One-hot encode categorical fields
- Impute missing values using domain-aware defaults (e.g., unknown severity → 0)

---

3. Model development & training pipeline

- Training script: `ai_models/symptom_checker/training/train.py`
- Typical pipeline:
  1. Load and clean dataset
  2. Split into train / validation / test
  3. Feature engineering and vectorization
  4. Train classifier (RandomForest, XGBoost, or LightGBM for tabular robustness)
  5. Evaluate metrics: accuracy, precision/recall per condition, top-k recall, calibration error
  6. Export model artifact to `saved_models` with metadata (version, training data hash, metrics)

Model considerations

- Class imbalance: many conditions are rare — use class weighting, oversampling, or focal loss.
- Interpretability: prefer tree-based models for easy feature importance and rule extraction; provide explanations for predictions (e.g., SHAP values) where possible.

---

4. Inference & runtime architecture (how it works in this project)

- Entry point: `backend/app/symptom_checker/service.py` exposes an API adapter that accepts symptom payloads.
- The service loads a model object (cached across requests) and runs feature transformation followed by model predict_proba.
- Post-processing: apply triage rules (red-flag overrides), compute textual recommendations, and format the response.

API contract (example)

Request (POST /api/v1/symptom-checker/predict)

```json
{
  "user_id": "uuid-or-null",
  "symptoms": [{"code":"C001","severity":2,"duration_hours":20}, ...],
  "metadata": {"age":35, "sex":"female", "pregnant":false}
}
```

Response (200)

```json
{
  "predictions": [
    {"condition_code":"GASTRO","condition_name":"Gastroenteritis","confidence":0.72},
    {"condition_code":"FOOD_POISON","condition_name":"Food poisoning","confidence":0.15}
  ],
  "triage_level":"non-urgent",
  "recommendation":"Rest and hydrate; see primary care in 48 hours if no improvement",
  "red_flags":[{"rule":"chest_pain_and_shortness","triggered":false}]
}
```

---

5. Safety & rule overlay

Because ML may produce false negatives on critical conditions, the Symptom Checker applies a deterministic red-flag rule set before returning results. Examples:

- If chest pain + shortness of breath → set triage=emergency and recommend immediate care
- If severe bleeding or altered consciousness reported → emergency

Rules are coded as boolean predicates applied to parsed symptom entries. Their evaluation precedes or post-overrides model outputs depending on severity and policy.

---

6. Full workflow diagram

```mermaid
flowchart TD
  U[Mobile user] -->|enters symptoms| M[Mobile UI]
  M -->|POST /predict| B[Backend API]
  B --> V[Validator & Auth]
  V --> S[SymptomCheckerController]
  S --> T[Feature Engineering]
  T -->|x| ML[Model Predict (cached model)]
  ML --> P[Probability vector P(c|x)]
  P --> R[Apply triage rules & post-process]
  R --> DB[Log request & analytics]
  R -->|response| M
  DB --> Admin[Admin Dashboard for review]
```

---

7. Communication with other modules

- Mobile App: primary caller — sends payload, shows results, and optionally requests follow-up actions (e.g., call emergency number).
- Chatbot: the chatbot can call Symptom Checker as a helper to confirm user-described symptoms and provide structured outputs to help generate safer responses.
- Emergency Detection: Symptom Checker shares flags and risk scores which Emergency Detection can re-evaluate with text-based detectors.
- Database: logs of predictions, red-flag triggers, and anonymized telemetry stored for retraining and auditing.

Integration tips

- Keep the service interface stable; use versioned endpoints (`/api/v1/...`) and annotate responses with `model_version` so mobile clients can display compatibility warnings.
- Ensure consistent symptom codes across frontend and backend (`symptom_code` dictionary in `ai_models` and `mobile_app/lib/constants`).

---

8. Evaluation metrics & monitoring

- Core metrics to track in production:
  - Top-1 accuracy and Top-3 recall per condition
  - Calibration error (ECE)
  - False negative rate on emergency cases (must be extremely low)
  - Drift detection: feature distribution shift and concept drift monitoring

Monitoring setup

- Log anonymized features and predicted labels to `analytics/` and run periodic evaluation jobs to compare predictions vs. confirmed diagnoses (when available).

---

9. Explainability & user-facing messaging

- Provide brief rationale: e.g., "Based on fever, vomiting, and 48h diarrhea, gastroenteritis is most likely (72%)."
- Offer confidence bands and disclaimers: not a diagnosis; seek professional care for severe or worsening symptoms.

---

10. Testing & QA

- Unit tests for feature engineering and rule predicates in `backend/tests/test_symptom_checker.py`.
- Integration tests to verify API contract and red-flag overrides.

---

11. Troubleshooting & common failures

- Model load errors: ensure `ai_models` is on PYTHONPATH and artifact exists.
- Incorrect mapping between frontend symptom labels and backend codes: sync `mobile_app/lib/constants` and `ai_models/symptom_checker/metadata`.

---

12. Future improvements

- Add contextual follow-up question flow to reduce ambiguity (active symptom elicitation)
- Multi-modal inputs (photo of rashes) using lightweight image classifiers
- Continuous learning pipeline: collect labeled outcomes and retrain periodically with versioned artifacts

---

13. Glossary (new terms)

- Symptom vectorization: mapping free-text or UI-selected symptoms to structured feature vectors.
- Red-flag: deterministic condition that immediately triggers emergency triage.
- Calibration: post-processing to align predicted probabilities with observed frequencies.

---

14. References & artifacts

- Data: `datasets/symptoms_datasets/`
- Training code: `ai_models/symptom_checker/training/train.py`
- Service: `backend/app/symptom_checker/service.py`

