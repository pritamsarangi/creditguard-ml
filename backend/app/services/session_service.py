
from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timedelta, timezone

from sqlalchemy import select, update
from sqlalchemy.orm import Session

from ..core.config import settings
from ..core.jwt_security import (
    create_access_token,
    generate_refresh_token,
    hash_refresh_token,
)
from ..models import AuthSession, User


def utc_now() -> datetime:
    return datetime.now(timezone.utc).replace(tzinfo=None)


class InvalidSessionError(Exception):
    """Raised for invalid, expired, or revoked sessions."""


@dataclass(frozen=True)
class TokenPair:
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


def create_session(
    db: Session,
    user: User,
) -> TokenPair:
    """Create a new authenticated user session."""

    if not user.is_active:
        raise InvalidSessionError("User is inactive.")

    now = utc_now()

    refresh_token = generate_refresh_token()

    session = AuthSession(
        user_id=user.id,
        token_hash=hash_refresh_token(refresh_token),
        created_at=now,
        expires_at=now + timedelta(
            days=settings.jwt_refresh_token_days
        ),
        revoked_at=None,
    )

    try:
        db.add(session)
        db.flush()

        access_token = create_access_token(user.id)

        db.commit()

        return TokenPair(
            access_token=access_token,
            refresh_token=refresh_token,
        )

    except Exception:
        db.rollback()
        raise


def refresh_session(
    db: Session,
    refresh_token: str,
) -> TokenPair:
    """
    Rotate a refresh token.

    The conditional UPDATE ensures only one concurrent
    request can successfully rotate the same token.
    """

    if not refresh_token:
        raise InvalidSessionError("Invalid session.")

    old_hash = hash_refresh_token(refresh_token)
    now = utc_now()

    try:
        existing = db.scalar(
            select(AuthSession).where(
                AuthSession.token_hash == old_hash
            )
        )

        if existing is None:
            raise InvalidSessionError("Invalid session.")

        user = db.get(User, existing.user_id)

        if user is None or not user.is_active:
            raise InvalidSessionError("Invalid session.")

        new_refresh_token = generate_refresh_token()
        new_hash = hash_refresh_token(new_refresh_token)

        result = db.execute(
            update(AuthSession)
            .where(
                AuthSession.id == existing.id,
                AuthSession.token_hash == old_hash,
                AuthSession.revoked_at.is_(None),
                AuthSession.expires_at > now,
            )
            .values(
                token_hash=new_hash,
            )
        )

        if result.rowcount != 1:
            raise InvalidSessionError(
                "Session has expired or was already used."
            )

        access_token = create_access_token(user.id)

        db.commit()

        return TokenPair(
            access_token=access_token,
            refresh_token=new_refresh_token,
        )

    except Exception:
        db.rollback()
        raise


def revoke_session(
    db: Session,
    refresh_token: str,
) -> bool:
    """Revoke an active refresh session."""

    if not refresh_token:
        return False

    now = utc_now()
    token_hash = hash_refresh_token(refresh_token)

    try:
        result = db.execute(
            update(AuthSession)
            .where(
                AuthSession.token_hash == token_hash,
                AuthSession.revoked_at.is_(None),
                AuthSession.expires_at > now,
            )
            .values(revoked_at=now)
        )

        db.commit()

        return result.rowcount == 1

    except Exception:
        db.rollback()
        raise
