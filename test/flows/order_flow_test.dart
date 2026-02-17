import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rodb_delivery_app/app/pages/login-page/login_page.dart';
import 'package:rodb_delivery_app/app/pages/orders-page/orders-page.dart';
import 'package:rodb_delivery_app/app/pages/order-details-page/order_details_page.dart';

import 'package:rodb_delivery_app/testing/order_fixtures.dart';
import 'package:rodb_delivery_app/testing/restaurant_user_fixtures.dart';

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

    testWidgets('Each order tile shows card number, customer name, and payment type',
        (tester) async {
      await signInAndShowOrders(tester);

      // Order 1: card "007", customer "Emirhan K.", payment "PAID"
      expect(find.text('Sipariş #007'), findsOneWidget);
      expect(find.text('Emirhan K. · PAID'), findsOneWidget);

      // Order 2: card "00E", customer "Mutlu Ç.", payment "PAID"
      expect(find.text('Sipariş #00E'), findsOneWidget);
      expect(find.text('Mutlu Ç. · PAID'), findsOneWidget);

      // Order 3: card "004", customer "İnanç M.", payment "PAID"
      expect(find.text('Sipariş #004'), findsOneWidget);
      expect(find.text('İnanç M. · PAID'), findsOneWidget);
    });

    testWidgets('Empty orders shows "Sipariş bulunamadı"', (tester) async {
      harness.fakeOrder.clearAll();

      await signInAndShowOrders(tester);

      expect(find.text('Sipariş bulunamadı'), findsOneWidget);
    });
  });

  group('Orders — Real-time Updates & Filtering', () {
    testWidgets('New orders appearing in stream are reflected in list',
        (tester) async {
      await signInAndShowOrders(tester);

      // Initially 3 orders
      expect(find.byType(ListTile), findsNWidgets(3));

      // Add a 4th order to the fake repository
      final newOrder = OrderFixtures.testOrder1.copyWith(
        id: 'new-999',
        orderCardNumber: '999',
      );
      harness.fakeOrder.addOrder(OrderFixtures.storeId, newOrder);
      await pumpAndFlush(tester);

      // Verify list updated to 4 orders
      expect(find.byType(ListTile), findsNWidgets(4));
      expect(find.text('Sipariş #999'), findsOneWidget);
    });

    testWidgets('Only shows orders for the current user\'s stores',
        (tester) async {
      await signInAndShowOrders(tester);

      // Default fixture user has access to store '318920' (has 3 orders)
      expect(find.byType(ListTile), findsNWidgets(3));

      // Change user to a store with NO orders
      final testUser = RestaurantUserFixtures.testUser4;
      harness.fakeRestaurantUser.emitUser(
        testUser.copyWith(restaurantKeys: ['empty-store-123']),
      );
      await pumpAndFlush(tester);

      // Verify list is now empty
      expect(find.text('Sipariş bulunamadı'), findsOneWidget);
    });
  });

  group('Orders — Navigation & Details', () {
    testWidgets('Tapping an order navigates to OrderDetailsPage',
        (tester) async {
      await signInAndShowOrders(tester);

      // Tap the first order tile
      await tester.tap(find.byType(ListTile).first);
      await pumpAndFlush(tester);

      expect(find.byType(OrderDetailsPage), findsOneWidget);
    });

    testWidgets('Details page shows payment, delivery, and metadata accurately',
        (tester) async {
      await signInAndShowOrders(tester);

      // Tap Order 3 (Inanç M.) which is newest/first
      await tester.tap(find.textContaining('İnanç M.'));
      await pumpAndFlush(tester);

      // 1. Payment info
      expect(find.textContaining('PAID'), findsOneWidget);
      expect(find.textContaining('599.8'), findsOneWidget);

      // 2. Delivery info
      expect(find.textContaining('Barbaros'), findsOneWidget); // Address
      expect(find.text('Not: -'), findsOneWidget); // Note (addressDescription)

      // 3. Meta info
      expect(find.textContaining('TRENDYOLYEMEK'), findsOneWidget);
      expect(find.textContaining('10962634803'), findsOneWidget); // ID
    });
  });
}

/// Helper to allow adding new fields/variants easily in tests
/// NOTE: copyWith is now available directly on Order and OrderMeta domain classes.
