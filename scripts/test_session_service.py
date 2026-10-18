
from backend.app.db import SessionLocal
from backend.app.models import User
from backend.app.core.jwt_security import decode_access_token
from backend.app.services.session_service import (
    InvalidSessionError,
    create_session,
    refresh_session,
    revoke_session,
)


def main() -> None:
    user_id = int(input("Existing user ID: ").strip())

    with SessionLocal() as db:
        user = db.get(User, user_id)

        if user is None or not user.is_active:
            print("Active user not found.")
            return

        # 1. Create a session.
        tokens = create_session(db, user)

        payload = decode_access_token(
            tokens.access_token
        )

        assert payload["sub"] == str(user_id)

        print("Session creation: PASSED")
        print("JWT validation: PASSED")

        # 2. Rotate the refresh token.
        rotated = refresh_session(
            db, tokens.refresh_token
        )

        assert rotated.refresh_token != tokens.refresh_token

        print("Refresh rotation: PASSED")

        # 3. Old refresh token must fail.
        try:
            refresh_session(db, tokens.refresh_token)
        except InvalidSessionError:
            print("Old token rejection: PASSED")
        else:
            raise AssertionError(
                "Old refresh token was accepted."
            )

        # 4. Logout by revoking the new token.
        revoked = revoke_session(
            db, rotated.refresh_token
        )

        assert revoked is True

        print("Logout revocation: PASSED")

        # 5. Revoked token must fail.
        try:
            refresh_session(db, rotated.refresh_token)
        except InvalidSessionError:
            print("Revoked token rejection: PASSED")
        else:
            raise AssertionError(
                "Revoked refresh token was accepted."
            )


if __name__ == "__main__":
    main()
