import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rodb_delivery_app/app/pages/orders-page/orders-page.dart';
import 'package:rodb_delivery_app/app/pages/orders-page/orders_page_view_model.dart';
import 'package:rodb_delivery_app/app/pages/order-details-page/order_details_page.dart';
import 'package:rodb_delivery_app/features/order-feature/domain/order.dart';
import 'package:rodb_delivery_app/features/order-feature/domain/customer.dart';
import 'package:rodb_delivery_app/features/order-feature/domain/order_delivery.dart';
import 'package:rodb_delivery_app/features/order-feature/domain/order_meta.dart';
import 'package:rodb_delivery_app/features/order-feature/domain/order_payment.dart';
import 'package:rodb_delivery_app/testing/order_fixtures.dart';

import '../helpers/test_app.dart';
import '../helpers/pump_helpers.dart';

/// Orders Page Tests
///
/// Two levels:
///   1. Unit tests for [OrdersPageViewModel.fromDomain] — pure mapping logic.
///   2. Widget tests for [OrdersPage] — rendered via [TestHarness].
///
/// Fixture data: [OrderFixtures] (3 orders, store 318920, all PAID).
///
/// Data chain (widget tests):
///   fakeAuth.emitUser → AuthGatePage routes → OrdersPage
///     → ordersStreamProvider → currentRestaurantUserProvider → restaurantKeys
///     → fakeOrder.watchOrdersForStores(['318920'])
///     → OrdersPage maps via OrdersPageViewModel.fromDomain
///     → ListView renders OrderSummary rows
void main() {
  // ═════════════════════════════════════════════════════════════════════════
  // UNIT TESTS — OrdersPageViewModel
  // ═════════════════════════════════════════════════════════════════════════

  group('OrdersPageViewModel — fromDomain', () {
    test('maps all fixture orders', () {
      final vm = OrdersPageViewModel.fromDomain(
        orders: OrderFixtures.allOrders,
      );

      expect(vm.orders.length, 3);
      expect(vm.isEmpty, false);
    });

    test('empty list produces isEmpty true', () {
      final vm = OrdersPageViewModel.fromDomain(orders: []);

      expect(vm.orders, isEmpty);
      expect(vm.isEmpty, true);
    });

    test('maps customer full name correctly', () {
      final vm = OrdersPageViewModel.fromDomain(
        orders: [OrderFixtures.testOrder1],
      );

      expect(vm.orders.first.customerFullName, 'Emirhan K.');
    });

    test('formats total price with currency symbol', () {
      final vm = OrdersPageViewModel.fromDomain(
        orders: [OrderFixtures.testOrder1],
      );

      // 319.90 ₺
      expect(vm.orders.first.totalPrice, '319.90 ₺');
    });

    test('maps payment type from orderPayment', () {
      final vm = OrdersPageViewModel.fromDomain(
        orders: [OrderFixtures.testOrder1],
      );

      expect(vm.orders.first.paymentType, 'PAID');
    });

    test('maps platform from meta', () {
      final vm = OrdersPageViewModel.fromDomain(
        orders: [OrderFixtures.testOrder1],
      );

      expect(vm.orders.first.platform, 'TRENDYOLYEMEK');
    });

    test('maps order card number', () {
      final vm = OrdersPageViewModel.fromDomain(
        orders: [OrderFixtures.testOrder1],
      );

      expect(vm.orders.first.orderCardNumber, '007');
    });

    test('retains domain order reference for navigation', () {
      final vm = OrdersPageViewModel.fromDomain(
        orders: [OrderFixtures.testOrder1],
      );

      expect(vm.orders.first.domainOrder, OrderFixtures.testOrder1);
    });

    test('falls back to "Unknown Customer" for blank names', () {
      final blankNameOrder = Order(
        id: 'blank-name',
        storeName: 'Test',
        customer: const Customer(
          firstName: '',
          lastName: '',
          phone: '',
          email: '',
          address: '',
        ),
        orderPayment: const OrderPayment(
          paymentType: 'CASH',
          price: 10.0,
        ),
        orderItems: const [],
        delivery: const OrderDelivery(
          address: '',
          addressNote: '',
          latitude: 0,
          longitude: 0,
        ),
        meta: const OrderMeta(
          integrationOrderId: '',
          integrationType: '',
          platform: '',
          creationDate: '',
          clickingTime: '',
          warmthType: '',
          cookingTime: 0,
          status: 'NEW',
          orderCardNumber: '',
        ),
        totalOrderPrice: 10.0,
        currency: const OrderCurrency(symbol: '₺', code: 'TRY'),
        integrationOrderId: '',
        orderCardNumber: 'X01',
      );

      final vm = OrdersPageViewModel.fromDomain(orders: [blankNameOrder]);

      expect(vm.orders.first.customerFullName, 'Unknown Customer');
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  // WIDGET TESTS — OrdersPage
  // ═════════════════════════════════════════════════════════════════════════

  group('OrdersPage — Widget Display', () {
    late TestHarness harness;

    setUp(() {
      harness = TestHarness.create();
    });

    /// Helper: sign in and navigate to OrdersPage via the auth gate.
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
      await pumpAndFlush(tester);
    }

    testWidgets('Renders all 3 fixture orders as ListTiles', (tester) async {
      await signInAndShowOrders(tester);

      expect(find.byType(OrdersPage), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(3));
    });

    testWidgets('Each tile shows order card number in title', (tester) async {
      await signInAndShowOrders(tester);

      expect(find.text('Sipariş #007'), findsOneWidget);
      expect(find.text('Sipariş #00E'), findsOneWidget);
      expect(find.text('Sipariş #004'), findsOneWidget);
    });

    testWidgets('Each tile shows customer name and payment type in subtitle',
        (tester) async {
      await signInAndShowOrders(tester);

      // Verify names are present
      expect(find.text('Emirhan K.'), findsOneWidget);
      expect(find.text('Mutlu Ç.'), findsOneWidget);
      expect(find.text('İnanç M.'), findsOneWidget);

      // Verify payment types are present (in badge)
      // All 3 fixture orders are 'PAID'
      expect(find.text('PAID'), findsNWidgets(3));
    });

    testWidgets('Empty orders shows "Sipariş bulunamadı"', (tester) async {
      harness.fakeOrder.clearAll();
      await signInAndShowOrders(tester);

      expect(find.text('Sipariş bulunamadı'), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('Each tile has a chevron_right trailing icon', (tester) async {
      await signInAndShowOrders(tester);

      expect(find.byIcon(Icons.chevron_right), findsNWidgets(3));
    });

    testWidgets('AppBar shows profile icon button', (tester) async {
      await signInAndShowOrders(tester);

      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });

  group('OrdersPage — Navigation', () {
    late TestHarness harness;

    setUp(() {
      harness = TestHarness.create();
    });

    Future<void> signInAndShowOrders(WidgetTester tester) async {
      harness.fakeAuth.onSignIn = () async {
        harness.fakeAuth.emitUser(fakeAuthUser);
        return fakeAuthUser;
      };

      await tester.pumpWidget(harness.buildApp());
      await pumpAndFlush(tester);

      await tester.tap(find.text('Google ile giriş yap'));
      await pumpAndFlush(tester);
      await pumpAndFlush(tester);
    }

    testWidgets('Tapping an order tile navigates to OrderDetailsPage',
        (tester) async {
      await signInAndShowOrders(tester);

      // Tap the first order tile (sorted newest first = order 3, card "004")
      await tester.tap(find.byType(ListTile).first);
      await pumpAndFlush(tester);

      expect(find.byType(OrderDetailsPage), findsOneWidget);
    });

    testWidgets('Details page shows payment info of tapped order',
        (tester) async {
      await signInAndShowOrders(tester);

      await tester.tap(find.byType(ListTile).first);
      await pumpAndFlush(tester);

      // Verify payment type is visible on the details page
      expect(find.textContaining('PAID'), findsOneWidget);
    });
  });
}
