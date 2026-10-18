
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..db import get_db
from ..models import User
from ..services.auth_service import (
    InvalidOTPError,
    OtpCooldownError,
    request_email_otp,
    verify_email_otp,
)
from ..services.email_service import EmailDeliveryError
from ..services.session_service import (
    InvalidSessionError,
    create_session,
    refresh_session,
    revoke_session,
)
from .auth_dependencies import get_current_user
from .auth_schemas import (
    MessageResponse,
    RefreshTokenRequest,
    SendOTPRequest,
    TokenResponse,
    UserResponse,
    VerifyOTPRequest,
)


router = APIRouter(
    prefix="/api/v1/auth",
    tags=["Authentication"],
)


@router.post(
    "/send-otp",
    response_model=MessageResponse,
)
def send_otp(
    payload: SendOTPRequest,
    db: Annotated[Session, Depends(get_db)],
):
    try:
        request_email_otp(db, str(payload.email))

    except OtpCooldownError:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Please wait before requesting another code.",
        )

    except EmailDeliveryError:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Email delivery is temporarily unavailable.",
        )

    return MessageResponse(
        message="If eligible, a verification email will be sent."
    )


@router.post(
    "/verify-otp",
    response_model=TokenResponse,
)
def verify_otp(
    payload: VerifyOTPRequest,
    db: Annotated[Session, Depends(get_db)],
):
    try:
        user = verify_email_otp(
            db=db,
            email=str(payload.email),
            otp=payload.otp,
        )

    except InvalidOTPError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired verification code.",
        )

    tokens = create_session(db, user)

    return TokenResponse(
        access_token=tokens.access_token,
        refresh_token=tokens.refresh_token,
        token_type=tokens.token_type,
    )


@router.post(
    "/refresh",
    response_model=TokenResponse,
)
def refresh(
    payload: RefreshTokenRequest,
    db: Annotated[Session, Depends(get_db)],
):
    try:
        tokens = refresh_session(
            db,
            payload.refresh_token,
        )

    except InvalidSessionError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired session.",
        )

    return TokenResponse(
        access_token=tokens.access_token,
        refresh_token=tokens.refresh_token,
        token_type=tokens.token_type,
    )


@router.post(
    "/logout",
    response_model=MessageResponse,
)
def logout(
    payload: RefreshTokenRequest,
    db: Annotated[Session, Depends(get_db)],
):
    revoke_session(db, payload.refresh_token)

    return MessageResponse(
        message="Session logout processed."
    )


@router.get(
    "/me",
    response_model=UserResponse,
)
def get_profile(
    current_user: Annotated[
        User, Depends(get_current_user)
    ],
):
    return UserResponse(
        id=current_user.id,
        email=current_user.email,
        is_active=current_user.is_active,
    )
