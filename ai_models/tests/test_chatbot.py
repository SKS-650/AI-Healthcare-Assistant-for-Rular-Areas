from ai_models.chatbot.response_generator import generate_response


def test_generate_response_for_empty_message():
    assert "describe" in generate_response("").lower()
