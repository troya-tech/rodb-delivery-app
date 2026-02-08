# Android Flavor Configuration

This document outlines how to configure product flavors for UAT (User Acceptance Testing) and PROD (Production) environments in `android/app/build.gradle.kts`.

## Configuration

Add the following block inside the `android { ... }` section of your `android/app/build.gradle.kts` file:

```kotlin
    // START: ADDED FOR UAT/PROD FLAVORS
    flavorDimensions += "environment"
    
    productFlavors {
        create("uat") {
            dimension = "environment"
            applicationIdSuffix = ".uat"
            versionNameSuffix = "-uat"
            // Note: If 'app_name' is defined in strings.xml, using resValue here might cause a conflict.
            // Ensure you manage your string resources accordingly (e.g., using flavor-specific source sets).
            resValue("string", "app_name", "RODB Delivery Panel UAT")
        }
        
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "RODB Delivery Panel")
        }
    }
    // END: ADDED FOR UAT/PROD FLAVORS
```

## Important Notes
- **Application ID**: The UAT flavor will append `.uat` to your base `applicationId`, resulting in `com.rodb.delivery.rodb_delivery_app.uat`.
- **App Name**: Using `resValue` injects a string resource. If you already have `app_name` in `src/main/res/values/strings.xml`, this may cause a duplicate resource error. 
    - **Recommended Approach**: Remove `app_name` from the main `strings.xml` and define it only in flavor-specific source sets or rely on this `resValue` injection (though `resValue` overwrites might be tricky with XML). 
    - **Alternative**: Create `src/uat/res/values/strings.xml` and `src/prod/res/values/strings.xml` instead of using `resValue` for the app name.
