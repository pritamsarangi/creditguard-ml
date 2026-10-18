from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select
from sqlalchemy.orm import Session

from ..core.config import settings
from ..db import get_db
from ..models import Prediction, User
from ..schemas import (
    CreditInput,
    ModelInfo,
    PredictionHistoryItem,
    PredictionResponse,
)
from ..ml.service import model_runtime
from .auth_dependencies import get_current_user


router = APIRouter(
    prefix="/api/v1",
    tags=["credit-risk"],
)


@router.get("/health")
def health() -> dict:
    return {
        "status": (
            "ok"
            if model_runtime.is_ready
            else "degraded"
        ),
        "model_ready": model_runtime.is_ready,
        "service": "creditguard-api",
    }


@router.get(
    "/model/info",
    response_model=ModelInfo,
)
def model_info() -> ModelInfo:

    if not model_runtime.is_ready:
        raise HTTPException(
            status_code=503,
            detail="ML model is not available",
        )

    metadata = model_runtime.metadata

    features = metadata.get(
        "input_features",
        metadata.get("raw_features", []),
    )

    return ModelInfo(
        model_name=metadata.get(
            "model_name",
            settings.model_name,
        ),
        model_version=metadata.get(
            "model_version",
            settings.model_version,
        ),
        algorithm=metadata.get("algorithm"),
        target=metadata.get(
            "target",
            "DEFAULT_NEXT_MONTH",
        ),
        features=features,
        input_count=metadata.get(
            "input_count",
            len(features),
        ),
        classification_threshold=metadata.get(
            "classification_threshold",
            settings.classification_threshold,
        ),
        risk_thresholds=metadata.get(
            "risk_thresholds",
            {
                "low_max": settings.low_risk_max,
                "high_min": settings.high_risk_min,
            },
        ),
        selected_metrics=metadata.get(
            "selected_metrics",
            {},
        ),
    )


@router.post(
    "/predictions",
    response_model=PredictionResponse,
    status_code=201,
)
def create_prediction(
    payload: CreditInput,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PredictionResponse:

    if not model_runtime.is_ready:
        raise HTTPException(
            status_code=503,
            detail=(
                "ML model is not available. "
                "Check the configured model artifact."
            ),
        )

    result = model_runtime.predict(
        payload.model_dump()
    )

    row = Prediction(
        user_id=current_user.id, 
        model_name=result["model_name"],
        model_version=result["model_version"],
        default_probability=result[
            "default_probability"
        ],
        predicted_default=result[
            "predicted_default"
        ],
        risk_band=result["risk"]["level"],
        input_payload=payload.model_dump(),
        factors_json=result["factors"],
        disclaimer=result["disclaimer"],
    )

    db.add(row)
    db.commit()
    db.refresh(row)

    return PredictionResponse(
        id=row.id,
        created_at=row.created_at,
        risk=result["risk"],
        summary=result["summary"],
        factors=result["factors"],
        explanation_note=result[
            "explanation_note"
        ],
        disclaimer=result["disclaimer"],
    )


@router.get(
    "/predictions",
    response_model=list[PredictionHistoryItem],
)
def list_predictions(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    limit: int = Query(
        20,
        ge=1,
        le=100,
    ),
) -> list[PredictionHistoryItem]:

    rows = db.scalars(
        select(Prediction)
        .where(Prediction.user_id == current_user.id)
        .order_by(
            Prediction.created_at.desc(),
            Prediction.id.desc(),
        )
        .limit(limit)
    ).all()

    return list(rows)
