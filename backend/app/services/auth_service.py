
from __future__ import annotations

from datetime import datetime, timedelta, timezone

from sqlalchemy import func, select, text
from sqlalchemy.orm import Session

from ..core.config import settings
from ..core.otp_security import generate_otp, hash_otp
from ..models import EmailOTP
from .email_service import send_otp_email

from ..models import User
from ..core.otp_security import verify_otp_hash


class OtpCooldownError(Exception):
    """An OTP was requested too recently."""


def utc_now() -> datetime:
    return datetime.now(timezone.utc).replace(tzinfo=None)


def normalize_email(email: str) -> str:
    return email.strip().lower()


def request_email_otp(
    db: Session,
    email: str,
) -> None:
    """
    Generate, store, and send an email OTP.

    This is the first development-stage implementation.
    Public exposure requires additional abuse protection.
    """
    email = normalize_email(email)
    now = utc_now()
    hour_ago = now - timedelta(hours=1)

    email_requests = db.scalar(
        select(func.count(EmailOTP.id)).where(
            EmailOTP.email == email,
            EmailOTP.created_at >= hour_ago,
        )
    ) or 0
    if email_requests >= 3:
        raise OtpCooldownError(
            "Too many verification requests. Please try again later."
        )
    total_requests = db.scalar(
        select(func.count(EmailOTP.id)).where(
            EmailOTP.created_at >= hour_ago
        )
    ) or 0
    if total_requests >= 30:
        raise OtpCooldownError(
            "Verification service is busy. Please try again later."
        )

    latest_otp = db.scalar(
        select(EmailOTP)
        .where(EmailOTP.email == email)
        .order_by(
            EmailOTP.created_at.desc(),
            EmailOTP.id.desc(),
        )
        .limit(1)
    )

    if latest_otp is not None:
        cooldown_until = latest_otp.created_at + timedelta(
            seconds=settings.otp_resend_cooldown_seconds
        )

        if now < cooldown_until:
            raise OtpCooldownError(
                "Please wait before requesting another code."
            )

    otp = generate_otp()

    challenge = EmailOTP(
        email=email,
        code_hash=hash_otp(email, otp),
        expires_at=now + timedelta(
            minutes=settings.otp_expiry_minutes
        ),
        created_at=now,
        attempts=0,
    )

    try:
        # Store the new challenge before sending.
        db.add(challenge)
        db.commit()

        send_otp_email(email, otp)

    except Exception:
        db.rollback()

        # If sending failed, invalidate this challenge.
        if challenge.id is not None:
            failed_challenge = db.get(
                EmailOTP, challenge.id
            )

            if failed_challenge is not None:
                failed_challenge.consumed_at = utc_now()
                db.commit()

        raise

class InvalidOTPError(Exception):
    """Raised when an OTP cannot be verified."""


def verify_email_otp(
    db: Session,
    email: str,
    otp: str,
) -> User:
    """
    Verify the latest OTP and create/find its user.

    SQL Server row locks ensure that concurrent
    verification requests cannot consume the same OTP.
    """
    email = normalize_email(email)
    now = utc_now()

    try:
        # Lock the newest OTP challenge until the transaction ends.
        if db.get_bind().dialect.name == "mssql":
            # keep the existing Sql server locking behavior.
            latest_id = db.execute(
                text("""
                    SELECT TOP (1) id
                    FROM dbo.email_otps WITH (UPDLOCK, HOLDLOCK)
                    WHERE email = :email
                    ORDER BY created_at DESC, id DESC
                """),
                {"email": email},
            ).scalar_one_or_none()
            challenge = (
                db.get(EmailOTP,latest_id)
                if latest_id is not None
                else None
            )
        elif db.get_bind().dialect.name == 'postgresql':
            # PostgreSQL row-level lock.
            challenge = db.scalar(
                select(EmailOTP)
                .where(EmailOTP.email == email)
                .order_by(
                    EmailOTP.created_at.desc(),
                    EmailOTP.id.desc(),
                )
                .limit(1)
                .with_for_update()
            )
        else:
            raise RuntimeError("Unsupported database dialect.")    
        if challenge is None:
            raise InvalidOTPError(
                "Invalid or expired verification code."
            )

        # Reject consumed or expired challenges.
        if (
            challenge.consumed_at is not None
            or now >= challenge.expires_at
            or challenge.attempts >= settings.otp_max_attempts
        ):
            raise InvalidOTPError(
                "Invalid or expired verification code."
            )

        is_valid = verify_otp_hash(
            email,
            otp,
            challenge.code_hash,
        )

        if not is_valid:
            challenge.attempts += 1
            db.commit()

            raise InvalidOTPError(
                "Invalid or expired verification code."
            )

        # Mark the OTP as consumed in the same transaction
        # as user creation.
        challenge.consumed_at = now

        user = db.scalar(
            select(User).where(User.email == email)
        )

        if user is None:
            user = User(
                email=email,
                is_active=True,
            )
            db.add(user)
            db.flush()

        if not user.is_active:
            raise InvalidOTPError(
                "Authentication is unavailable."
            )

        db.commit()
        return user

    except InvalidOTPError:
        db.rollback()
        raise

    except Exception:
        db.rollback()
        raise
