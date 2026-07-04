from ai_models.inference.inference_engine import InferenceEngine


def test_inference_engine_returns_prediction_key():
    result = InferenceEngine().predict({"symptom_count": 2})
    assert "prediction" in result
