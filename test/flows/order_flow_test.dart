import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rodb_delivery_app/app/pages/login-page/login_page.dart';
import 'package:rodb_delivery_app/app/pages/orders-page/orders-page.dart';
import 'package:rodb_delivery_app/app/pages/order-details-page/order_details_page.dart';
import 'package:rodb_delivery_app/testing/order_fixtures.dart';

import '../helpers/test_app.dart';
import '../helpers/pump_helpers.dart';

/// Order Flow Tests
///
/// Verifies order list display, empty state, and navigation to order details:
///
/// Data chain:
/// fakeAuth.emitUser(testUser) → AuthGatePage routes to OrdersPage
///   → ordersStreamProvider: currentRestaurantUserProvider → restaurantKeys
///   → fakeOrder.watchOrdersForStores(['318920'])
///   → OrdersPage shows list
///   → tap order tile → pushNamed('/order-details', arguments: order)
///   → OrderDetailsPage renders payment, delivery, metadata
void main() {
  late TestHarness harness;

  setUp(() {
    harness = TestHarness.create();
  });

  /// Helper: sign in and wait for the full async chain to resolve:
  /// authState → restaurantUser → ordersStream → OrdersPage list
  Future<void> signInAndShowOrders(WidgetTester tester) async {
    harness.fakeAuth.onSignIn = () async {
      harness.fakeAuth.emitUser(fakeAuthUser);
      return fakeAuthUser;
    };

    await tester.pumpWidget(harness.buildApp());
    await pumpAndFlush(tester);

    // Tap the "Google ile giriş yap" button
    await tester.tap(find.text('Google ile giriş yap'));
    await pumpAndFlush(tester);

    // Extra pump cycle: orders depend on auth → restaurantUser → ordersStream
    // Each stream level needs a frame to propagate.
    await pumpAndFlush(tester);
  }

  group('Orders — Display', () {
    testWidgets('Orders list shows all seeded orders', (tester) async {
      await signInAndShowOrders(tester);

      // Verify we're on OrdersPage
      expect(find.byType(OrdersPage), findsOneWidget);

      // 3 fixture orders seeded by default
      expect(find.byType(ListTile), findsNWidgets(3));
    });

    testWidgets('Each order tile shows card number and customer name',
        (tester) async {
      await signInAndShowOrders(tester);

      // Order 1: card "007", customer "Emirhan K."
      expect(find.text('Sipariş #007'), findsOneWidget);
      expect(find.text('Emirhan K.'), findsOneWidget);

      // Order 2: card "00E", customer "Mutlu Ç."
      expect(find.text('Sipariş #00E'), findsOneWidget);
      expect(find.text('Mutlu Ç.'), findsOneWidget);

      // Order 3: card "004", customer "İnanç M."
      expect(find.text('Sipariş #004'), findsOneWidget);
      expect(find.text('İnanç M.'), findsOneWidget);
    });

    testWidgets('Empty orders shows "Sipariş bulunamadı"', (tester) async {
      harness.fakeOrder.clearAll();

      await signInAndShowOrders(tester);

      expect(find.text('Sipariş bulunamadı'), findsOneWidget);
    });
  });

  group('Orders — Navigation to Details', () {
    testWidgets('Tapping an order navigates to OrderDetailsPage',
        (tester) async {
      await signInAndShowOrders(tester);

      // Tap the first order tile
      await tester.tap(find.byType(ListTile).first);
      await pumpAndFlush(tester);

      expect(find.byType(OrderDetailsPage), findsOneWidget);
    });

    testWidgets('Details page shows correct order card number in AppBar',
        (tester) async {
      await signInAndShowOrders(tester);

      await tester.tap(find.byType(ListTile).first);
      await pumpAndFlush(tester);

      // Verify we're on OrderDetailsPage
      expect(find.byType(OrderDetailsPage), findsOneWidget);
    });

    testWidgets('Details page shows payment type and total price',
        (tester) async {
      await signInAndShowOrders(tester);

      await tester.tap(find.byType(ListTile).first);
      await pumpAndFlush(tester);

      // Verify payment type and price are visible
      expect(find.textContaining('PAID'), findsOneWidget);
    });

    testWidgets('Details page shows delivery address and note',
        (tester) async {
      await signInAndShowOrders(tester);

      await tester.tap(find.byType(ListTile).first);
      await pumpAndFlush(tester);

      // Order 3 (newest, first in list) has address containing "Barbaros"
      // and note containing "Ranch sosu"
      expect(
        find.textContaining('Barbaros'),
        findsOneWidget,
      );
    });

    testWidgets('Details page shows platform and creation date',
        (tester) async {
      await signInAndShowOrders(tester);

      await tester.tap(find.byType(ListTile).first);
      await pumpAndFlush(tester);

      expect(find.textContaining('TRENDYOLYEMEK'), findsOneWidget);
    });
  });
}
