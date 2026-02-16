import 'package:flutter_test/flutter_test.dart';

import 'package:rodb_delivery_app/app/pages/login-page/login_page.dart';
import 'package:rodb_delivery_app/app/pages/orders-page/orders-page.dart';

import '../helpers/test_app.dart';
import '../helpers/pump_helpers.dart';

/// Login Flow Tests
///
/// Verifies login button behavior, error handling, and navigation:
/// - Tap login → triggers signInWithGoogle
/// - Network error → shows localized error UI
/// - Auth error → shows localized error UI
/// - Success → navigates to OrdersPage
///
/// Data chain:
/// fakeAuth.emitUser(testUser) → email: foorcun@gmail.com
///   → AuthGatePage routes to OrdersPage when user != null
void main() {
  late TestHarness harness;

  setUp(() {
    harness = TestHarness.create();
  });

  group('Login - Success', () {
    testWidgets('Tapping Login button calls signInWithGoogle', (tester) async {
      await tester.pumpWidget(harness.buildApp());
      await pumpAndFlush(tester);

      // Tap the "Google ile giriş yap" button
      await tester.tap(find.text('Google ile giriş yap'));
      await pumpAndFlush(tester);

      // Verify: FakeAuthRepository signs in → user is now authenticated
      expect(harness.fakeAuth.currentUser, isNotNull);
    });

    testWidgets('Successful login navigates to OrdersPage', (tester) async {
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
      await tester.tap(find.text('Google ile giriş yap'));
      await pumpAndFlush(tester);

      // Verify: navigated to OrdersPage
      expect(find.byType(OrdersPage), findsOneWidget);
    });
  });

  group('Login - Error Handling', () {
    testWidgets('No internet shows network error', (tester) async {
      harness.fakeAuth.signInError =
          Exception('Network error: No internet connection');

      await tester.pumpWidget(harness.buildApp());
      await pumpAndFlush(tester);

      // Tap the login button
      await tester.tap(find.text('Google ile giriş yap'));
      await pumpAndFlush(tester);

      // Verify: Localized error message is displayed
      // LoginPage._parseErrorMessage maps "No internet connection" → noInternetError
      expect(
        find.textContaining('İnternet bağlantısı yok'),
        findsOneWidget,
      );

    });

    testWidgets('Failed login shows authentication error', (tester) async {
      harness.fakeAuth.signInError =
          Exception('Authentication failed: Invalid credentials');

      await tester.pumpWidget(harness.buildApp());
      await pumpAndFlush(tester);

      // Tap login
      await tester.tap(find.text('Google ile giriş yap'));
      await pumpAndFlush(tester);

      // Verify: generic error is shown (doesn't match any specific pattern),
      // and still on LoginPage
      expect(find.byType(LoginPage), findsOneWidget);
      expect(
        find.textContaining('Giriş başarısız'),
        findsOneWidget,
      );
    });

    testWidgets('DNS resolution failure shows network error', (tester) async {
      harness.fakeAuth.signInError =
          Exception('Network error: Unable to resolve host');

      await tester.pumpWidget(harness.buildApp());
      await pumpAndFlush(tester);

      // Tap login
      await tester.tap(find.text('Google ile giriş yap'));
      await pumpAndFlush(tester);

      // Verify: generic error is shown (DNS error doesn't match "No internet" pattern),
      // and still on LoginPage
      expect(find.byType(LoginPage), findsOneWidget);
      expect(
        find.textContaining('Giriş başarısız'),
        findsOneWidget,
      );
    });
  });
}
