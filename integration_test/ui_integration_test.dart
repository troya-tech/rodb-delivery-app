import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:rodb_delivery_app/features/auth-feature/application/auth_providers.dart';
import 'package:rodb_delivery_app/features/auth-feature/domain/auth_user.dart';
import 'package:rodb_delivery_app/features/auth-feature/infrastructure/fake_auth_repository.implementation.dart';
import 'package:rodb_delivery_app/features/restaurant-user-feature/application/restaurant_user_providers.dart';
import 'package:rodb_delivery_app/features/restaurant-user-feature/infrastructure/fake_restaurant_user_repository.implementation.dart';
import 'package:rodb_delivery_app/features/store-feature/application/store_service.dart';
import 'package:rodb_delivery_app/features/store-feature/infrastructure/fake_store_repository.implementation.dart';
import 'package:rodb_delivery_app/features/order-feature/application/order_providers.dart';
import 'package:rodb_delivery_app/features/order-feature/infrastructure/fake_order_repository.implementation.dart';
import 'package:rodb_delivery_app/testing/auth_fixtures.dart';
import 'package:rodb_delivery_app/app/routing/app_router.dart';
import 'package:rodb_delivery_app/app/routing/app_routes.dart';
import 'package:rodb_delivery_app/app/pages/orders-page/orders-page.dart';
import 'package:rodb_delivery_app/app/pages/order-details-page/order_details_page.dart';

/// On-device UI smoke test (Level 3 — "Golden Path").
///
/// Run with:
///   make test-ui-native          (requires a connected device/emulator)
///
/// This test boots the full app with fake repositories (no real Firebase auth),
/// signs in, and verifies the core navigation: Login → Orders → Order Details.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthRepository fakeAuth;
  late FakeRestaurantUserRepository fakeRestaurantUser;
  late FakeStoreRepository fakeStore;
  late FakeOrderRepository fakeOrder;

  setUp(() {
    fakeAuth = FakeAuthRepository();
    fakeRestaurantUser = FakeRestaurantUserRepository();
    fakeStore = FakeStoreRepository();
    fakeOrder = FakeOrderRepository();
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeAuth),
        restaurantUserRepositoryProvider.overrideWithValue(fakeRestaurantUser),
        storeRepositoryProvider.overrideWithValue(fakeStore),
        orderRepositoryProvider.overrideWithValue(fakeOrder),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('tr'),
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppRoutes.authGate,
      ),
    );
  }

  testWidgets('Golden path: Login → Orders → Order Details', (tester) async {
    // Build the app with all fakes
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // --- Step 1: Login ---
    // Tap the sign-in button
    final signInButton = find.text('Google ile giriş yap');
    expect(signInButton, findsOneWidget, reason: 'Login button should appear');
    
    // Configure fake auth to emit a user on sign-in
    fakeAuth.emitUser(AuthFixtures.testUser);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    // --- Step 2: Orders list ---
    // Wait for the async chain: auth → restaurantUser → ordersStream
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(OrdersPage), findsOneWidget,
        reason: 'Should navigate to OrdersPage after login');

    // Verify at least one order is visible (seeded by FakeOrderRepository)
    expect(find.byType(ListTile), findsWidgets,
        reason: 'Orders list should contain order tiles');

    // --- Step 3: Order Details ---
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    expect(find.byType(OrderDetailsPage), findsOneWidget,
        reason: 'Should navigate to OrderDetailsPage');
  });
}
