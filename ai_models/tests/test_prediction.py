from ai_models.prediction.risk_prediction import predict_risk


def test_predict_risk_high_for_emergency_severity():
    assert predict_risk(9) == "high"
