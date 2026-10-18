
from __future__ import annotations

import logging

import httpx

from ..core.config import settings


logger = logging.getLogger(__name__)

BREVO_API_URL = "https://api.brevo.com/v3/smtp/email"


class EmailDeliveryError(Exception):
    """Raised when the email provider cannot accept a message."""


def send_otp_email(email: str, otp: str) -> None:
    """
    Send a CreditGuard login OTP via Brevo.

    Never log the OTP, API key, or complete
    provider response.
    """
    if not settings.brevo_api_key:
        raise RuntimeError("BREVO_API_KEY is missing")

    if not settings.brevo_sender_email:
        raise RuntimeError("BREVO_SENDER_EMAIL is missing")

    payload = {
        "sender": {
            "name": "CreditGuard",
            "email": settings.brevo_sender_email,
        },
        "to": [{"email": email}],
        "subject": "Your CreditGuard verification code",
        "htmlContent": (
            "<html><body>"
            "<h2>CreditGuard verification</h2>"
            "<p>Your one-time verification code is:</p>"
            f"<h1>{otp}</h1>"
            "<p>This code expires in 5 minutes.</p>"
            "<p>If you did not request this code, "
            "you can ignore this message.</p>"
            "</body></html>"
        ),
    }

    headers = {
        "api-key": settings.brevo_api_key,
        "accept": "application/json",
        "content-type": "application/json",
    }

    try:
        with httpx.Client(timeout=10.0) as client:
            response = client.post(
                BREVO_API_URL,
                json=payload,
                headers=headers,
            )

            response.raise_for_status()

    except httpx.HTTPError as exc:
        logger.error(
            "CreditGuard OTP email delivery request failed: %s",
            type(exc).__name__,
        )
        raise EmailDeliveryError(
            "Unable to deliver verification email."
        ) from exc
