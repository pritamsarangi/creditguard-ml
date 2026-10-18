
from getpass import getpass

from backend.app.db import SessionLocal
from backend.app.services.auth_service import (
    InvalidOTPError,
    verify_email_otp,
)


def main():
    email = input("Email: ").strip()
    otp = getpass("Enter received OTP: ").strip()

    with SessionLocal() as db:
        try:
            user = verify_email_otp(
                db=db,
                email=email,
                otp=otp,
            )

            print("OTP verified successfully!")
            print("User ID:", user.id)
            print("Email:", user.email)

        except InvalidOTPError:
            print("Invalid or expired OTP.")


if __name__ == "__main__":
    main()
