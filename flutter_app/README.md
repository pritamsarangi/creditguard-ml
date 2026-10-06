# CreditGuard Flutter Client

This directory contains the Flutter application source. Generate the platform folders on your machine with `flutter create .`, then run `flutter pub get`.

## Run

Android emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Physical Android device:

```bash
flutter run --dart-define=API_BASE_URL=http://YOUR-LAN-IP:8000
```

The app uses GetX for state management and the Dart `http` package for REST calls.
