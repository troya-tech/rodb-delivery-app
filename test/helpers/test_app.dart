import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:rodb_delivery_app/features/auth-feature/application/auth_providers.dart';
import 'package:rodb_delivery_app/features/auth-feature/domain/auth_user.dart';
import 'package:rodb_delivery_app/features/auth-feature/infrastructure/fake_auth_repository.implementation.dart';
import 'package:rodb_delivery_app/testing/auth_fixtures.dart';
import 'package:rodb_delivery_app/app/pages/auth-gate-page/auth_gate_page.dart';
import 'package:rodb_delivery_app/features/restaurant-user-feature/application/restaurant_user_providers.dart';
import 'package:rodb_delivery_app/features/restaurant-user-feature/infrastructure/fake_restaurant_user_repository.implementation.dart';
import 'package:rodb_delivery_app/features/store-feature/application/store_service.dart';
import 'package:rodb_delivery_app/features/store-feature/infrastructure/fake_store_repository.implementation.dart';
import 'package:rodb_delivery_app/features/restaurant-user-feature/presentation/user_profile_screen.dart';

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
  final FakeRestaurantUserRepository fakeRestaurantUser;
  final FakeStoreRepository fakeStore;

  TestHarness._({
    required this.fakeAuth,
    required this.fakeRestaurantUser,
    required this.fakeStore,
  });

  /// Creates a fresh [TestHarness] with new repositories.
  factory TestHarness.create() {
    return TestHarness._(
      fakeAuth: TestableAuthRepository(),
      fakeRestaurantUser: FakeRestaurantUserRepository(),
      fakeStore: FakeStoreRepository(),
    );
  }

  /// Builds a fully-wired test app with Riverpod overrides and localization.
  ///
  /// The app starts at [AuthGatePage] (the '/' route), which routes to
  /// [LoginPage] or [OrdersPage] based on auth state.
  Widget buildApp() {
    return _wrapWithProviders(const AuthGatePage());
  }

  /// Builds a test app that starts directly on [UserProfileScreen]
  /// with the user already authenticated.
  ///
  /// Uses a user WITHOUT [photoUrl] to avoid [NetworkImage] HTTP 400 errors
  /// in the test environment. Testing the avatar image is a Flutter framework
  /// concern, not our business logic.
  Widget buildProfileApp() {
    const testUserNoPhoto = AuthUser(
      uid: '7UMNf9av9YZSU4fUx17D5IGHG6I2',
      email: 'foorcun@gmail.com',
      displayName: 'Furkan Fake',
    );
    fakeAuth.emitUser(testUserNoPhoto);
    return _wrapWithProviders(const UserProfileScreen());
  }

  Widget _wrapWithProviders(Widget home) {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeAuth),
        restaurantUserRepositoryProvider.overrideWithValue(fakeRestaurantUser),
        storeRepositoryProvider.overrideWithValue(fakeStore),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('tr'),
        home: home,
      ),
    );
  }
}
