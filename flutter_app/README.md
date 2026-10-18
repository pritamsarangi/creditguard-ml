# CreditGuard Flutter Client

The Flutter client for [CreditGuard](../README.md) runs on **Android and Web**. It uses `flutter_bloc` for state management, `go_router` for navigation, and Dio for API requests. The app supports email OTP sign-in, credit-default-risk assessments using eight inputs, result display, and authenticated prediction history.

## Live Web demo

[Open CreditGuard Web](https://creditguard-web.pritamsarangi70.workers.dev)

Backend: [FastAPI documentation](https://creditguard-api-0izj.onrender.com/docs)

> Educational demonstration only; results are not calibrated probabilities or real-world credit decisions.

## Requirements

Install Flutter and Android tooling (for Android), or Chrome (for Web). Then, from this `flutter_app` folder:

```powershell
flutter pub get
flutter analyze
flutter test
```

## Run locally against the hosted API

For Chrome:

```powershell
flutter run -d chrome --dart-define=APP_ENV=prod --dart-define=API_BASE_URL=https://creditguard-api-0izj.onrender.com
```

For a connected Android device, get its device ID from `flutter devices`, then:

```powershell
flutter run -d DEVICE_ID --dart-define=APP_ENV=prod --dart-define=API_BASE_URL=https://creditguard-api-0izj.onrender.com
```

For a local FastAPI development server, change `APP_ENV` to `dev` and use `http://10.0.2.2:8000` for the Android emulator or your computer's LAN IP for a physical device. The server must be reachable from the device. Production (`APP_ENV=prod`) requires HTTPS.

## Build for Web

```powershell
flutter build web --release --dart-define=APP_ENV=prod --dart-define=API_BASE_URL=https://creditguard-api-0izj.onrender.com
```

Upload the contents of `build/web` as static website assets to your configured Cloudflare Worker deployment. After changing the frontend, rebuild and upload again; a manual asset upload isn't automatically updated by a GitHub push.

The FastAPI `CORS_ORIGINS` setting must allow the exact frontend origin, currently:

```dotenv
CORS_ORIGINS=https://creditguard-web.pritamsarangi70.workers.dev
```

## Build signed Android APK

Configure Android release signing in `android/app/build.gradle.kts` and keep the passwords in the private `android/key.properties` file. **Do not commit** `key.properties` or any `.jks` keystore.

```powershell
flutter build apk --release --dart-define=APP_ENV=prod --dart-define=API_BASE_URL=https://creditguard-api-0izj.onrender.com
```

Output: `build/app/outputs/flutter-apk/app-release.apk`. Keep a backup of the signing keystore and credentials so later releases can be installed as updates. The demo currently uses Android application ID `com.example.creditguard_flutter`.

## Operational notes

- A Render free-instance cold start can cause a long delay or initial timeout. Avoid automatic retries of OTP submissions because they can cause duplicate messages.
- Web tokens are kept in application memory; this does not replace browser security controls such as strong XSS protection and an HttpOnly-cookie-based refresh strategy.
- The risk estimate is educational and must not be used for actual credit decisions.

For backend setup, model details, hosting configuration, and additional limitations, see the [root README](../README.md).
