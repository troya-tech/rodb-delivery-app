

# pre-req

create or check Makefile.

example Makefile
```sh
.PHONY: run-fake help run-uat run-prod run-prod-release build-appbundle-prod test-ui test-ui-native

# Display help information
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  run-uat               Run app in UAT environment"
	@echo "  run-fake              Run app with Fake Auth (using UAT Firebase)"
	@echo "  run-prod              Run app in Production environment (debug mode)"
	@echo "  run-prod-release      Run app in Production environment (release mode)"
	@echo "  build-appbundle-prod  Build Android App Bundle for Production"
	@echo "  test-ui               Run UI flow tests headlessly (no device needed)"
	@echo "  test-ui-native        Run UI smoke test on device (Espresso)"
	@echo "  help                  Display this help information"


# Run app with Fake Auth (using UAT Firebase)
run-fake:
	flutter run --flavor uat -t lib/main_fake.dart

# Run app in UAT environment
run-uat:
	flutter run --flavor uat --dart-define=ENV=uat

# Run app in Production environment (debug mode)
run-prod:
	flutter run --flavor prod --dart-define=ENV=prod

# Run app in Production environment (release mode)
run-prod-release:
	flutter run --flavor prod --release --dart-define=ENV=prod

# Build Android App Bundle for Production
build-appbundle-prod:
	flutter build appbundle --flavor prod --release --dart-define=ENV=prod

# Run UI flow tests (headless — no device needed)
test-ui:
	flutter test test/flows/

# Run UI smoke test on device (Native/Espresso — requires connected device)
test-ui-native:
	cd android && gradlew app:connectedDebugAndroidTest -Ptarget=integration_test/ui_integration_test.dart
```


# chech fixture exist

example fixture in lib/testing
```dart
import 'package:menumia_flutter_partner_app/features/auth-feature/domain/auth_user.dart';

class AuthFixtures {
  static const AuthUser testUser = AuthUser(
    uid: '7UMNf9av9YZSU4fUx17D5IGHG6I2',
    email: 'foorcun@gmail.com',
    displayName: 'Furkan KAMACI',
    photoUrl: 'https://lh3.googleusercontent.com/a/ACg8ocKwCCBD3_LkG17Ofs1RQKpWMs2AKecBrOracyvHEpJxU5bZvQ=s96-c',
  );
}

```

# check or creat Fake repo implementation

example lib/features/auth-feature/infrastructure/fake_auth_repository.implementation.dart

```dart
import 'package:menumia_flutter_partner_app/features/auth-feature/domain/auth_repository.dart';
import 'package:menumia_flutter_partner_app/features/auth-feature/domain/auth_user.dart';
import 'package:rxdart/rxdart.dart';
import 'package:menumia_flutter_partner_app/testing/auth_fixtures.dart';
import 'package:menumia_flutter_partner_app/utils/app_logger.dart';

/// A fake implementation of [AuthRepository] for testing purposes.
/// 
/// Following Vladimir Khorikov's definition of a **Fake**:
/// It provides a functional, stateful, but simplified implementation of the 
/// repository without external dependencies (Firebase/Google).
/// 
/// It maintains internal state and updates the [authStateChanges] stream accordingly.
class FakeAuthRepository implements AuthRepository {
  static final _logger = AppLogger('FakeAuthRepository');
  AuthUser? _currentUser;
  
  // Using BehaviorSubject to ensure new listeners get the latest state immediately
  final _authStateController = BehaviorSubject<AuthUser?>();

  /// Creates a [FakeAuthRepository] with an optional [initialUser].
  FakeAuthRepository({AuthUser? initialUser}) : _currentUser = initialUser {
    _logger.info('Initializing FakeAuthRepository (Initial User: ${_currentUser?.email ?? "Guest"})');
    // Seed initial state
    _authStateController.add(_currentUser);
  }

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> authStateChanges() => _authStateController.stream;

  @override
  Future<AuthUser> signInWithGoogle() async {
    final context = _logger.createContext();
    _logger.info('Starting Fake Google Sign-In flow', context);
    
    // Simplified functional logic: transition state to logged in
    // using the standard test fixture user.
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate minimal latency
    
    _currentUser = AuthFixtures.testUser;
    _authStateController.add(_currentUser);
    
    _logger.success('Fake Sign-In successful for unit testing: ${_currentUser?.email}', context);
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    final context = _logger.createContext();
    _logger.info('Starting Fake Sign-Out process', context);
    
    // Simplified functional logic: transition state to logged out.
    await Future.delayed(const Duration(milliseconds: 50));
    
    _currentUser = null;
    _authStateController.add(_currentUser);
    
    _logger.success('Fake Sign-Out successful', context);
  }

  /// Clean up the stream controller when the repository is no longer needed.
  void dispose() {
    _logger.debug('Disposing FakeAuthRepository and closing streams');
    _authStateController.close();
  }
  
  /// Helper method for tests to manually inject a specific user state
  /// or reset the repository.
  void emitUser(AuthUser? user) {
    _logger.info('Manually emitting user state: ${user?.email ?? "Guest"}');
    _currentUser = user;
    _authStateController.add(_currentUser);
  }
}

```


# check or create main_fake.dart


example
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menumia_flutter_partner_app/app/providers/providers.dart';
import 'package:menumia_flutter_partner_app/features/shared-config-feature/infrastructure/repositories/fake_shared_config_repository.dart';
import 'package:menumia_flutter_partner_app/features/restaurant/infrastructure/repositories/fake_restaurant_repository.dart';
import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/infrastructure/repositories/fake_restaurant_user_repository.dart';
import 'package:menumia_flutter_partner_app/features/menu/infrastructure/repositories/fake_menu_repository.dart';
import 'package:menumia_flutter_partner_app/features/auth-feature/infrastructure/fake_auth_repository.implementation.dart';
import 'firebase_options_uat.dart' as firebase_uat;
import 'main.dart';

/// Entry point for running the app with a Fake authentication repository.
/// 
/// Usage: flutter run -t lib/main_fake.dart
Future<void> main() async {
  // Ensure Flutter is initialized
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
        // external logic dependencies
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),

        // internal logic dependencies
        menuRepositoryProvider.overrideWithValue(FakeMenuRepository()),
        restaurantRepositoryProvider.overrideWithValue(FakeRestaurantRepository()),
        restaurantUserRepositoryProvider.overrideWithValue(FakeRestaurantUserRepository()),
        sharedConfigRepositoryProvider.overrideWithValue(FakeSharedConfigRepository()),
      ],
      child: const MyApp(),
    ),
  );
}
```

# create me a login flow 

example
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:menumia_flutter_partner_app/app/pages/login-page/login_page.dart';
import 'package:menumia_flutter_partner_app/app/pages/home_page/home_page.dart';

import '../helpers/test_app.dart';
import '../helpers/pump_helpers.dart';

/// Login Flow Tests
///
/// Verifies login button behavior, error handling, and navigation:
/// - Tap login → triggers signInWithGoogle
/// - Network error → shows error UI
/// - Auth error → shows error UI
/// - Success → navigates to HomePage
void main() {
  late TestHarness harness;

  setUp(() {
    harness = TestHarness.create();
  });

  group('Login - Success', () {
    testWidgets('Tapping Login button calls signInWithGoogle', (tester) async {
      await tester.pumpWidget(harness.buildApp());
      await pumpAndFlush(tester);

      // Tap the "Login with Google" button
      await tester.tap(find.text('Login with Google'));
      await pumpAndFlush(tester);

      // Verify: FakeAuthRepository signs in → user is now authenticated
      expect(harness.fakeAuth.currentUser, isNotNull);
    });

    testWidgets('Successful login navigates to HomePage', (tester) async {
      // Configure custom sign-in to emit our specific fake user
      harness.fakeAuth.onSignIn = () async {
        harness.fakeAuth.emitUser(fakeAuthUser);
        return fakeAuthUser;
      };

      await tester.pumpWidget(harness.buildApp());
      await pumpAndFlush(tester);

      // Verify: starts on LoginPage
      expect(find.byType(LoginPage), findsOneWidget);

      // Tap login
      await tester.tap(find.text('Login with Google'));
      await pumpAndFlush(tester);

      // Verify: navigated to HomePage
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Kategori'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });
  });

  group('Login - Error Handling', () {
    testWidgets('No internet shows network error', (tester) async {
      const networkErrorMessage = 'Exception: Network error: No internet connection';
      harness.fakeAuth.signInError = Exception('Network error: No internet connection');

      await tester.pumpWidget(harness.buildApp());
      await pumpAndFlush(tester);

      // Tap the "Login with Google" button
      await tester.tap(find.text('Login with Google'));
      await pumpAndFlush(tester);

      // Verify: Error message is displayed in the UI
      expect(find.text(networkErrorMessage), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('Failed login shows authentication error', (tester) async {
      harness.fakeAuth.signInError =
          Exception('Authentication failed: Invalid credentials');

      await tester.pumpWidget(harness.buildApp());
      await pumpAndFlush(tester);

      // Tap login
      await tester.tap(find.text('Login with Google'));
      await pumpAndFlush(tester);

      // Verify: error is shown, still on LoginPage
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Exception: Authentication failed: Invalid credentials'),
          findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('DNS resolution failure shows network error', (tester) async {
      harness.fakeAuth.signInError =
          Exception('Network error: Unable to resolve host');

      await tester.pumpWidget(harness.buildApp());
      await pumpAndFlush(tester);

      // Tap login
      await tester.tap(find.text('Login with Google'));
      await pumpAndFlush(tester);

      // Verify: network error is shown
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Exception: Network error: Unable to resolve host'),
          findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
```