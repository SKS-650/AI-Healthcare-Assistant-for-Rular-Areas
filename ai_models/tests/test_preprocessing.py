from ai_models.preprocessing.data_cleaning import normalize_text


def test_normalize_text():
    assert normalize_text("  Fever   Cough ") == "fever cough"
