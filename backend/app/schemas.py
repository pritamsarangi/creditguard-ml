from __future__ import annotations

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


class CreditInput(BaseModel):
    model_config = ConfigDict(
        extra="forbid",
        json_schema_extra={
            "example": {
                "credit_limit": 120000,
                "age": 32,
                "recent_payment_status": 0,
                "previous_payment_status": 0,
                "current_bill_amount": 90000,
                "previous_bill_amount": 85000,
                "latest_payment_amount": 5000,
                "previous_payment_amount": 5000,
            }
        },
    )

    credit_limit: float = Field(
        ...,
        gt=0,
        description="Total available credit limit",
    )

    age: int = Field(
        ...,
        ge=18,
        le=100,
        description="Customer age",
    )

    recent_payment_status: int = Field(
        ...,
        ge=-2,
        le=9,
        description="Most recent repayment status code",
    )

    previous_payment_status: int = Field(
        ...,
        ge=-2,
        le=9,
        description="Previous repayment status code",
    )

    current_bill_amount: float = Field(
        ...,
        ge=0,
        description="Current statement bill amount",
    )

    previous_bill_amount: float = Field(
        ...,
        ge=0,
        description="Previous statement bill amount",
    )

    latest_payment_amount: float = Field(
        ...,
        ge=0,
        description="Most recent payment amount",
    )

    previous_payment_amount: float = Field(
        ...,
        ge=0,
        description="Previous payment amount",
    )


class RiskInfo(BaseModel):
    level: Literal["low", "medium", "high"]
    label: str
    estimated_probability: float
    percentage: int


class PredictionSummary(BaseModel):
    title: str
    message: str


class Factor(BaseModel):
    title: str
    status: Literal["positive", "neutral", "warning"]
    message: str


class PredictionResponse(BaseModel):
    id: int
    created_at: datetime

    risk: RiskInfo
    summary: PredictionSummary
    factors: list[Factor]

    explanation_note: str
    disclaimer: str


class PredictionHistoryItem(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime
    model_name: str
    model_version: str
    default_probability: float
    predicted_default: int
    risk_band: str


class ModelInfo(BaseModel):
    model_name: str
    model_version: str
    algorithm: str | None = None
    target: str
    features: list[str]
    input_count: int | None = None
    classification_threshold: float | None = None
    risk_thresholds: dict[str, float]
    selected_metrics: dict
