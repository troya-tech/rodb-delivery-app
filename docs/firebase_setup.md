# Firebase Setup & Configuration (Android Only)

This document contains the reusable `flutterfire configure` commands for the Android-only RODB project.

## Prerequisites
- Firebase CLI: `firebase login`
- FlutterFire CLI: `dart pub global activate flutterfire_cli`

## Dependencies
Ensure your `pubspec.yaml` has these (UAT/PROD compatible):
```yaml
dependencies:
  firebase_core: ^4.4.0
  firebase_database: ^12.1.2
  firebase_auth: ^6.1.4
  google_sign_in: ^7.2.0
  flutter_riverpod: ^2.6.1
  equatable: ^2.0.8

dev_dependencies:
  mocktail: ^1.0.4
```

## Configuration Commands

### 1. UAT Environment (`lib/firebase_options_uat.dart`)
Project: `js-test-e5720`
Package: `com.rodb.delivery.rodb_delivery_app.uat`

```bash
flutterfire configure --project=js-test-e5720 --out=lib/firebase_options_uat.dart --android-package-name=com.rodb.delivery.rodb_delivery_app.uat
```

#### Post-Configuration for UAT
```bash
mkdir -p android/app/src/uat
mv android/app/google-services.json android/app/src/uat/
```

---

### 2. PROD Environment (`lib/firebase_options_prod.dart`)
Project: `rodb-delivery-app-prod` (Update if different)
Package: `com.rodb.delivery.rodb_delivery_app`

```bash
flutterfire configure \
  --project=rodb-delivery-app-prod \
  --out=lib/firebase_options_prod.dart \
  --android-package-name=com.rodb.delivery.rodb_delivery_app \
  --platforms=android
```

#### Post-Configuration for PROD
```bash
mkdir -p android/app/src/prod
mv android/app/google-services.json android/app/src/prod/
```
