
from __future__ import annotations

import hashlib
import hmac
import secrets

from .config import settings


def generate_otp() -> str:
    """Generate a secure six-digit OTP."""
    return f"{secrets.randbelow(1_000_000):06d}"


def hash_otp(email: str, otp: str) -> str:
    """Create a keyed HMAC digest for the OTP."""
    if not settings.otp_secret_key:
        raise RuntimeError("OTP_SECRET_KEY is not configured")

    normalized_email = email.strip().lower()
    message = f"{normalized_email}:{otp}".encode("utf-8")

    return hmac.new(
        settings.otp_secret_key.encode("utf-8"),
        message,
        hashlib.sha256,
    ).hexdigest()


def verify_otp_hash(
    email: str,
    provided_otp: str,
    stored_hash: str,
) -> bool:
    """Verify an OTP using constant-time comparison."""
    if (
        len(provided_otp) != 6
        or not provided_otp.isascii()
        or not provided_otp.isdigit()
    ):
        return False

    computed_hash = hash_otp(email, provided_otp)

    return hmac.compare_digest(computed_hash, stored_hash)
