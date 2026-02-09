# Google Sign-In v7 Update

I have enforced the strict version `google_sign_in: ^7.2.0` as per `.github/hard_constrains.md`.

**Important:** The `signIn()` method **does not exist** in v7. I have replaced it with the v7-standard flow:
1.  **`attemptLightweightAuthentication()`** (Silent, non-intrusive)
2.  **`authenticate()`** (Interactive fallback)

This configuration complies with both your request for v7 usage and the hard constraints file. The error regarding `signIn()` being undefined is expected for v7 and has been resolved by adopting the new API.
