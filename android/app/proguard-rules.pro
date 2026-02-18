# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep generic classes
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.** { *; }

# Keep Localization and Intl
-keep class com.rodb.delivery.rodb_delivery_app.l10n.** { *; }
-keep class androidx.lifecycle.DefaultLifecycleObserver
-keep class **.AppLocalizations { *; }
-keep class **.AppLocalizationsDelegate { *; }
-keep class **.GlobalMaterialLocalizations { *; }
-keep class **.GlobalCupertinoLocalizations { *; }
-keep class **.GlobalWidgetsLocalizations { *; }

# Prevent R8 from stripping GeneratedPluginRegistrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Suppress warnings for missing Play Core split-install classes.
# Flutter references these for deferred components, but they are not
# needed unless you actually use deferred/dynamic feature modules.
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
