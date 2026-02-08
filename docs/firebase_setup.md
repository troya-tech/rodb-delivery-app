# Firebase Setup & Configuration

This document contains the reusable `flutterfire configure` commands for generating the environment-specific Firebase configuration files.

## Prerequisites
- Ensure you have the Firebase CLI installed and logged in: `firebase login`.
- Ensure you have `flutterfire` CLI installed: `dart pub global activate flutterfire_cli`.

## Configuration Commands

### 1. UAT Environment (`lib/firebase_options_uat.dart`)
Run this command to generate/update the configuration for the **UAT** environment.

```bash
flutterfire configure \
  --project=rodb-delivery-app \
  --out=lib/firebase_options_uat.dart \
  --ios-bundle-id=com.rodb.delivery.rodbDeliveryApp \
  --android-package-name=com.rodb.delivery.rodb_delivery_app \
  --platforms=android
```


> **Note:** Replace `rodb-delivery-app` with your actual Firebase Project ID for UAT.
note2: package name should be changed to `com.rodb.delivery.rodb_delivery_app.uat`


# this is real selected uat env
```bash
flutterfire configure --project=js-test-e5720 --out=lib/firebase_options_uat.dart --android-package-name=com.rodb.delivery.rodb_delivery_app.uat
```

#### Post-Configuration for UAT
Move the generated `google-services.json` to the flavor-specific Android source set:
```bash
mkdir -p android/app/src/uat
mv android/app/google-services.json android/app/src/uat/
```


---

### 2. PROD Environment (`lib/firebase_options_prod.dart`)
Run this command to generate/update the configuration for the **BETA/PROD** environment.

```bash
flutterfire configure \
  --project=rodb-delivery-app-prod \
  --out=lib/firebase_options_prod.dart \
  --ios-bundle-id=com.rodb.delivery.rodbDeliveryApp \
  --android-package-name=com.rodb.delivery.rodb_delivery_app \
  --platforms=android,ios,web
```

> **Note:**
> *   Replace `rodb-delivery-app-prod` with your actual Firebase Project ID for PROD.
> *   If you use different Bundle IDs for PROD (e.g. for side-by-side installation), update the `--ios-bundle-id` and `--android-package-name` flags accordingly.

#### Post-Configuration for PROD
Move the generated `google-services.json` to the flavor-specific Android source set:
```bash
mkdir -p android/app/src/prod
mv android/app/google-services.json android/app/src/prod/
```
