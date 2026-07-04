from fastapi import APIRouter, Depends

from .service import PredictionService
from .controller import PredictionController

router = APIRouter(prefix="/prediction", tags=["prediction"])


def get_prediction_controller() -> PredictionController:
    service = PredictionService()
    return PredictionController(service=service)


@router.post("/predict")
def predict(payload: dict, controller: PredictionController = Depends(get_prediction_controller)):
    """Placeholder predict endpoint.

    payload: free-form dict for now.
    """
    return controller.predict(payload=payload)

