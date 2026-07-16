## Emergency Detection — Detailed Implementation

The Emergency Detection module is a critical safety layer that identifies possible life-threatening conditions from free-text (chat) and structured symptom inputs. It is intentionally conservative: prioritize recall for emergencies while controlling false-positive rates through multi-stage checks.

Goals

- Rapid detection of red-flag presentations (e.g., chest pain, stroke, severe breathing difficulty)
- Low-latency decisions suitable for real-time chat flows
- Explainable triggers with audit trail for any escalation

---

1) Sources of input

- Symptom Checker predictions and raw symptom payloads
- Chatbot messages and extracted entities from NLP pipelines
- Historical logs (batch re-scanning for missed events)

---

2) Detection strategy (multi-stage)

Stage 1 — Deterministic rule matching

- Fast boolean predicates evaluate presence of explicit red-flag symptoms: chest pain, sudden unilateral weakness, severe bleeding, loss of consciousness.
- Advantages: deterministic and explainable; zero ML failure modes for explicit keywords.

Stage 2 — Text classifier

- A lightweight classifier (logistic regression / small neural net) runs on embeddings or bag-of-words features to detect implicit emergency language.
- Operates with a permissive threshold to favor recall.

Stage 3 — Risk aggregation & context

- Combine signals from model output, deterministic rules, and meta information (age, comorbidities) to compute an aggregated risk score r ∈ [0,1].
- Apply thresholds with hysteresis to prevent flip-flopping on marginal cases.

Combined scoring formula (example)

$$
r = 1 - \prod_{i}(1 - w_i s_i)
$$

Where s_i are individual signal strengths (0..1) and w_i are weights. The product form models the probability that at least one strong signal is present.

---

3) Actions on detection

- Tiered response:
	- Immediate UI emergency message + call-to-action (triage=emergency)
	- Notify admin dashboard for human review (optional)
	- Add high-priority analytics event for operator alerts

- When an emergency is detected within chatbot flow, generation is suppressed and a deterministic emergency reply is returned directing the user to seek immediate care.

---

4) Implementation details in this repo

- Detector code lives under `ai_models/emergency_detection` (training and model artifacts) and runtime helpers under `backend/app/emergency` or `backend/app/emergency_detection`.
- The Emergency Detection service exposes a simple function `assess_risk(text, symptoms, metadata)` returning `{risk_score, triggered_rules, recommended_action}`.

---

5) Explainability & audit trail

- Record which rules fired and top contributing features for the classifier (e.g., token weights). This is essential for post-incident review.

---

6) Testing and evaluation

- Metrics to track:
	- Recall on labeled emergency dataset (target > 0.98)
	- False positive rate (should be controlled to avoid alarm fatigue)
	- Detection latency (ms)

- Use cross-validation on curated emergency and non-emergency examples; perform adversarial testing with paraphrases.

---

7) Integration with other modules

- Chatbot: integrated inline — before returning a generated reply, the chatbot calls `assess_risk` and, if risk is above emergency threshold, returns a safe emergency response.
- Symptom Checker: high triage outputs are passed to Emergency Detection for confirmation and to generate direct emergency instructions.
- Admin Dashboard: provides a review queue for detected events and manual override controls.

---

8) Operational notes & safeguards

- Rate-limit automatic notifications to operators to avoid alert storms.
- Include manual override for flagged events in the admin UI along with justification input to improve the detection dataset.

---

9) Example pseudocode

```python
def assess_risk(text, symptoms, metadata):
		rules = evaluate_rules(symptoms, text)
		clf_score = classifier.predict_proba(features_from(text, symptoms))[:,1]
		risk = 1 - np.prod([1 - w*s for w,s in zip(weights, [rules_score, clf_score, meta_score])])
		return {"risk": risk, "rules": rules, "clf_score": float(clf_score)}
```

---

10) Glossary

- Red-flag: deterministic condition that mandates emergency triage
- Risk aggregation: combining multiple signals into a single actionable score
