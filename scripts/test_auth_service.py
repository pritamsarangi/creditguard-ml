
from backend.app.db import SessionLocal
from backend.app.services.auth_service import (
    OtpCooldownError,
    request_email_otp,
)


def main():
    email = input("Recipient email: ").strip()

    with SessionLocal() as db:
        try:
            request_email_otp(db, email)
            print("OTP request processed successfully.")

        except OtpCooldownError:
            print("OTP resend cooldown is active.")

        except Exception as exc:
            print(
                "OTP request failed:",
                type(exc).__name__,
            )


if __name__ == "__main__":
    main()
