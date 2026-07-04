"""AI models command entrypoint."""

from __future__ import annotations

from ai_models.inference.prediction_pipeline import PredictionPipeline


def main() -> None:
    """Run a placeholder inference call."""

    result = PredictionPipeline().run({"symptoms": []})
    print(result)


if __name__ == "__main__":
    main()
