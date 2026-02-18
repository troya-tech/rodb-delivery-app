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
