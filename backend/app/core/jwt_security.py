
from __future__ import annotations

import hashlib
import secrets
import uuid
from datetime import datetime, timedelta, timezone

import jwt
from jwt import InvalidTokenError

from .config import settings


JWT_ALGORITHM = "HS256"
JWT_ISSUER = "creditguard-api"
JWT_AUDIENCE = "creditguard-mobile"


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def get_jwt_secret() -> str:
    secret = settings.jwt_secret_key

    if len(secret) < 32:
        raise RuntimeError(
            "JWT_SECRET_KEY must be at least "
            "32 characters long."
        )

    return secret


def create_access_token(user_id: int) -> str:
    """
    Create a short-lived JWT access token.
    """
    now = utc_now()

    payload = {
        "sub": str(user_id),
        "type": "access",
        "jti": str(uuid.uuid4()),
        "iss": JWT_ISSUER,
        "aud": JWT_AUDIENCE,
        "iat": now,
        "nbf": now,
        "exp": now + timedelta(
            minutes=settings.jwt_access_token_minutes
        ),
    }

    return jwt.encode(
        payload,
        get_jwt_secret(),
        algorithm=JWT_ALGORITHM,
    )


def decode_access_token(token: str) -> dict:
    """
    Verify signature, expiration, issuer,
    audience and token type.
    """
    try:
        payload = jwt.decode(
            token,
            get_jwt_secret(),
            algorithms=[JWT_ALGORITHM],
            issuer=JWT_ISSUER,
            audience=JWT_AUDIENCE,
            options={
                "require": [
                    "sub",
                    "type",
                    "jti",
                    "iss",
                    "aud",
                    "iat",
                    "nbf",
                    "exp",
                ],
            },
        )

        if payload.get("type") != "access":
            raise InvalidTokenError(
                "Incorrect token type."
            )

        user_id = payload.get("sub")

        if (
            not isinstance(user_id, str)
            or not user_id.isdecimal()
            or int(user_id) <= 0
        ):
            raise InvalidTokenError(
                "Invalid token subject."
            )

        return payload

    except InvalidTokenError:
        raise


def generate_refresh_token() -> str:
    """
    Generate a cryptographically random
    opaque refresh token.
    """
    return secrets.token_urlsafe(48)


def hash_refresh_token(token: str) -> str:
    """
    Hash a high-entropy refresh token for
    database storage.
    """
    return hashlib.sha256(
        token.encode("utf-8")
    ).hexdigest()
