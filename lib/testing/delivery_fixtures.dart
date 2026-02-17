import 'package:rodb_delivery_app/features/delivery-feature/domain/delivery.dart';
import 'package:rodb_delivery_app/testing/order_fixtures.dart';

/// Test fixtures for delivery data.
class DeliveryFixtures {
  // ═══════════════════════════════════════════════════════════════════════
  // DELIVERY 1 - Matches OrderFixtures.order1Id
  // ═══════════════════════════════════════════════════════════════════════
  static const String delivery1Id = 'DEL-10950695020';
  static final Delivery delivery1 = Delivery(
    id: delivery1Id,
    orderId: OrderFixtures.order1Id,
    status: 'PENDING',
    createdAt: DateTime.parse(OrderFixtures.order1CreationDate),
  );

  // ═══════════════════════════════════════════════════════════════════════
  // DELIVERY 2 - Matches OrderFixtures.order2Id
  // ═══════════════════════════════════════════════════════════════════════
  static const String delivery2Id = 'DEL-10954466658';
  static final Delivery delivery2 = Delivery(
    id: delivery2Id,
    orderId: OrderFixtures.order2Id,
    status: 'ASSIGNED',
    driverId: 'DRIVER-123',
    driverName: 'Ahmet Y.',
    createdAt: DateTime.parse(OrderFixtures.order2CreationDate),
  );

  // ═══════════════════════════════════════════════════════════════════════
  // DELIVERY 3 - Matches OrderFixtures.order3Id
  // ═══════════════════════════════════════════════════════════════════════
  static const String delivery3Id = 'DEL-10962634803';
  static final Delivery delivery3 = Delivery(
    id: delivery3Id,
    orderId: OrderFixtures.order3Id,
    status: 'DELIVERED',
    driverId: 'DRIVER-456',
    driverName: 'Mehmet K.',
    trackingUrl: 'https://track.example.com/DEL-10962634803',
    createdAt: DateTime.parse(OrderFixtures.order3CreationDate),
  );

  static final List<Delivery> allDeliveries = [
    delivery1,
    delivery2,
    delivery3,
  ];
}
