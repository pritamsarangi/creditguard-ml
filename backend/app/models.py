
from __future__ import annotations

from datetime import datetime, timezone

from sqlalchemy import (
    Boolean,
    DateTime,
    Float,
    ForeignKey,
    Index,
    Integer,
    JSON,
    String,
    Text,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .db import Base


def utc_now() -> datetime:
    """Return a naive UTC datetime for SQL Server DATETIME2."""
    return datetime.now(timezone.utc).replace(tzinfo=None)


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(
        Integer, primary_key=True, autoincrement=True
    )

    email: Mapped[str] = mapped_column(
        String(254), nullable=False, unique=True
    )

    is_active: Mapped[bool] = mapped_column(
        Boolean, nullable=False, default=True
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=False),
        nullable=False,
        default=utc_now,
    )

    predictions: Mapped[list["Prediction"]] = relationship(
        back_populates="user"
    )


class EmailOTP(Base):
    __tablename__ = "email_otps"

    id: Mapped[int] = mapped_column(
        Integer, primary_key=True, autoincrement=True
    )

    email: Mapped[str] = mapped_column(
        String(254), nullable=False
    )

    code_hash: Mapped[str] = mapped_column(
        String(64), nullable=False
    )

    expires_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=False), nullable=False
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=False),
        nullable=False,
        default=utc_now,
    )

    attempts: Mapped[int] = mapped_column(
        Integer, nullable=False, default=0
    )

    consumed_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=False), nullable=True
    )

    __table_args__ = (
        Index(
            "ix_email_otps_email_created_at",
            "email",
            "created_at",
        ),
    )


class Prediction(Base):
    __tablename__ = "predictions"

    id: Mapped[int] = mapped_column(
        Integer, primary_key=True, autoincrement=True
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False,
    )

    # Nullable temporarily for pre-authentication records.
    user_id: Mapped[int | None] = mapped_column(
        Integer,
        ForeignKey("users.id"),
        nullable=True,
        index=True,
    )

    user: Mapped[User | None] = relationship(
        back_populates="predictions"
    )

    model_name: Mapped[str] = mapped_column(
        String(64), nullable=False
    )

    model_version: Mapped[str] = mapped_column(
        String(32), nullable=False
    )

    default_probability: Mapped[float] = mapped_column(
        Float, nullable=False
    )

    predicted_default: Mapped[int] = mapped_column(
        Integer, nullable=False
    )

    risk_band: Mapped[str] = mapped_column(
        String(16), nullable=False
    )

    input_payload: Mapped[dict] = mapped_column(
        JSON, nullable=False
    )

    factors_json: Mapped[list] = mapped_column(
        JSON, nullable=False
    )

    disclaimer: Mapped[str] = mapped_column(
        Text, nullable=False
    )

class AuthSession(Base):
    __tablename__ = "auth_sessions"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        autoincrement=True,
    )

    user_id: Mapped[int] = mapped_column(
        Integer,
        ForeignKey("users.id"),
        nullable=False,
        index=True,
    )

    token_hash: Mapped[str] = mapped_column(
        String(64),
        nullable=False,
        unique=True,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=False),
        nullable=False,
        default=utc_now,
    )

    expires_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=False),
        nullable=False,
    )

    revoked_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=False),
        nullable=True,
    )
