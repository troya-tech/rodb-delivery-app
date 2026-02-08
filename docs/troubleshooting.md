# Troubleshooting

## Google Sign-In: `serverClientId must be provided on Android`

### Error
```
GoogleSignInException(code GoogleSignInExceptionCode.clientConfigurationError, serverClientId must be provided on Android, null)
```

### Cause
In `google_sign_in: ^7.2.0`, `GoogleSignIn.instance` requires explicit initialization with the **Web Client ID** (`client_type: 3` from `google-services.json`). The plugin does **not** auto-detect it.

### Solution

1. The Web Client ID is stored per-environment in `firebase_options_uat.dart` / `firebase_options_prod.dart` as `DefaultFirebaseOptions.webClientId`.
2. `main.dart` initializes Google Sign-In using the correct environment's Web Client ID:

```dart
// main.dart
final webClientId = environment == 'prod'
    ? firebase_prod.DefaultFirebaseOptions.webClientId
    : firebase_uat.DefaultFirebaseOptions.webClientId;

await GoogleSignIn.instance.initialize(serverClientId: webClientId);
```

### Where to Find the Web Client ID
In `google-services.json`, find the `oauth_client` entry with `client_type: 3`:
```json
{
  "client_id": "XXXXX.apps.googleusercontent.com",
  "client_type": 3
}
```

> [!IMPORTANT]
> If you add a new flavor or Firebase project, add the corresponding `webClientId` to its `firebase_options_*.dart` file.
