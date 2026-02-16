import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rodb_delivery_app/features/auth-feature/application/auth_providers.dart';
import 'package:rodb_delivery_app/features/auth-feature/infrastructure/fake_auth_repository.implementation.dart';
import 'firebase_options_uat.dart' as firebase_uat;
import 'main.dart';

/// Entry point for running the app with a Fake authentication repository.
///
/// Usage: flutter run --flavor uat -t lib/main_fake.dart
///
/// This connects to the UAT Firebase for real data reads, but uses
/// FakeAuthRepository for instant sign-in (no Google Sign-In prompt).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with UAT options so we can read real data
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: firebase_uat.DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        // Inject the Fake implementation at the root
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      ],
      child: const MyApp(),
    ),
  );
}
