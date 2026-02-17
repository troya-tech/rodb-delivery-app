import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodb_delivery_app/app/pages/performance-page/performance_page.dart';

import 'package:rodb_delivery_app/testing/order_fixtures.dart';

import '../../../helpers/test_app.dart';
import '../../../helpers/pump_helpers.dart';

void main() {
  late TestHarness harness;

  setUp(() {
    harness = TestHarness.create();
    
    // Auth setup
    harness.fakeAuth.onSignIn = () async {
      harness.fakeAuth.emitUser(fakeAuthUser);
      return fakeAuthUser;
    };
  });



  testWidgets('PerformancePage shows empty stats when no delivered orders', (tester) async {
    // Orders are NOT delivered by default in fixtures
    harness.fakeOrder.addOrder(OrderFixtures.storeId, OrderFixtures.testOrder1);

    await tester.pumpWidget(harness.buildApp());
    await pumpAndFlush(tester);
    await tester.tap(find.text('Google ile giriş yap'));
    await pumpAndFlush(tester);

    // Navigate to Performance Page
    // Assuming we can't easily reach it without shell, let's just push it
    // Wait, the "App Shell" conversation was listed, but did it finish?
    // If I can't rely on Shell, I'll use Navigator to push.
    
    final context = tester.element(find.byType(Scaffold).last); // Finds login or orders page scaffold
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PerformancePage()),
    );
    await pumpAndFlush(tester);

    // Verify Title
    expect(find.text('Performans'), findsOneWidget); // Or whatever localization says
    // Verify Stats are 0
    expect(find.text('Total Deliveries'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Total Earnings'), findsOneWidget);
    expect(find.text('0.00 ₺'), findsOneWidget); // Total Earnings is 0.00
  });

  testWidgets('PerformancePage shows correct stats for delivered orders', (tester) async {
    // Add a delivered order
    final deliveredOrder = OrderFixtures.testOrder1.copyWith(
      id: 'delivered-1',
      meta: OrderFixtures.testOrder1.meta.copyWith(isDelivered: true),
      totalOrderPrice: 100.0,
    );
    
    harness.fakeOrder.addOrder(OrderFixtures.storeId, deliveredOrder);
    
    // Add a non-delivered order (should be ignored)
    harness.fakeOrder.addOrder(OrderFixtures.storeId, OrderFixtures.testOrder2);

    await tester.pumpWidget(harness.buildApp());
    await pumpAndFlush(tester);
    await tester.tap(find.text('Google ile giriş yap'));
    await pumpAndFlush(tester);

    // Navigate
    final context = tester.element(find.byType(Scaffold).last);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PerformancePage()),
    );
    await pumpAndFlush(tester);

    // Verify Stats
    // 1 delivered order, 100.0 price
    expect(find.text('1'), findsOneWidget); // Total Deliveries
    
    // Total Earnings should be 50.00 ₺ (1 * 50)
    expect(find.text('50.00 ₺'), findsOneWidget); 
  });
}
