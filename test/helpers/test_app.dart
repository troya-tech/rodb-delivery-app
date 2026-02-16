import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:rodb_delivery_app/features/auth-feature/application/auth_providers.dart';
import 'package:rodb_delivery_app/features/auth-feature/domain/auth_user.dart';
import 'package:rodb_delivery_app/features/auth-feature/infrastructure/fake_auth_repository.implementation.dart';
import 'package:rodb_delivery_app/testing/auth_fixtures.dart';
import 'package:rodb_delivery_app/app/pages/auth-gate-page/auth_gate_page.dart';

/// Convenience constant for the standard test user.
const AuthUser fakeAuthUser = AuthFixtures.testUser;

/// Extends [FakeAuthRepository] with test-configurable behavior.
///
/// - Set [signInError] to make [signInWithGoogle] throw.
/// - Set [onSignIn] for custom sign-in logic (e.g., emitting a specific user).
/// - No `Future.delayed` — all operations are instant for [FakeAsync] safety.
class TestableAuthRepository extends FakeAuthRepository {
  /// If set, [signInWithGoogle] will throw this exception.
  Exception? signInError;

  /// If set, [signInWithGoogle] will call this instead of the default logic.
  Future<AuthUser> Function()? onSignIn;

  @override
  Future<AuthUser> signInWithGoogle() async {
    if (signInError != null) throw signInError!;
    if (onSignIn != null) return onSignIn!();
    emitUser(AuthFixtures.testUser);
    return AuthFixtures.testUser;
  }
}

/// Test harness that wires the full dependency chain using fakes.
///
/// Usage in every flow test:
/// ```dart
/// late TestHarness harness;
///
/// setUp(() {
///   harness = TestHarness.create();
/// });
///
/// testWidgets('...', (tester) async {
///   await tester.pumpWidget(harness.buildApp());
///   await pumpAndFlush(tester);
///   // ... test body
/// });
/// ```
class TestHarness {
  final TestableAuthRepository fakeAuth;

  TestHarness._({required this.fakeAuth});

  /// Creates a fresh [TestHarness] with a new [TestableAuthRepository].
  factory TestHarness.create() {
    return TestHarness._(fakeAuth: TestableAuthRepository());
  }

  /// Builds a fully-wired test app with Riverpod overrides and localization.
  ///
  /// The app starts at [AuthGatePage] (the '/' route), which routes to
  /// [LoginPage] or [OrdersPage] based on auth state.
  Widget buildApp() {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeAuth),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('tr'),
        home: const AuthGatePage(),
      ),
    );
  }
}
