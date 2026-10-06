from __future__ import annotations

from datetime import datetime, timezone

from sqlalchemy import DateTime, Integer, JSON, String, Text, Float
from sqlalchemy.orm import Mapped, mapped_column

from .db import Base


class Prediction(Base):
    __tablename__ = "predictions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    model_name: Mapped[str] = mapped_column(String(64), nullable=False)
    model_version: Mapped[str] = mapped_column(String(32), nullable=False)
    default_probability: Mapped[float] = mapped_column(Float, nullable=False)
    predicted_default: Mapped[int] = mapped_column(Integer, nullable=False)
    risk_band: Mapped[str] = mapped_column(String(16), nullable=False)
    input_payload: Mapped[dict] = mapped_column(JSON, nullable=False)
    factors_json: Mapped[list] = mapped_column(JSON, nullable=False)
    disclaimer: Mapped[str] = mapped_column(Text, nullable=False)
