import 'package:flutter_test/flutter_test.dart';
import 'package:rodb_delivery_app/features/delivery-feature/domain/delivery.dart';
import 'package:rodb_delivery_app/features/delivery-feature/infrastructure/fake_delivery_repository.implementation.dart';
import 'package:rodb_delivery_app/testing/delivery_fixtures.dart';

void main() {
  group('Delivery Entity', () {
    test('supports value equality', () {
      final instance1 = DeliveryFixtures.delivery1;
      final instance2 = DeliveryFixtures.delivery1;
      expect(instance1, equals(instance2));
    });

    test('props are correct', () {
      final instance = DeliveryFixtures.delivery1;
      expect(
        instance.props,
        equals([
          instance.id,
          instance.orderId,
          instance.status,
          instance.driverId,
          instance.driverName,
          instance.trackingUrl,
          instance.createdAt,
        ]),
      );
    });

    test('toMap and fromMap work correctly', () {
      final instance = DeliveryFixtures.delivery2;
      final map = instance.toMap();
      final fromMap = Delivery.fromMap(instance.id, map);
      expect(fromMap, equals(instance));
    });

    test('copyWith works correctly', () {
      final instance = DeliveryFixtures.delivery1;
      final updated = instance.copyWith(status: 'DELIVERED');
      expect(updated.status, equals('DELIVERED'));
      expect(updated.id, equals(instance.id));
    });
  });

  group('FakeDeliveryRepository', () {
    late FakeDeliveryRepository repository;

    setUp(() {
      repository = FakeDeliveryRepository(initialDeliveries: DeliveryFixtures.allDeliveries);
    });

    test('getDeliveryById returns correct delivery', () async {
      final delivery = await repository.getDeliveryById(DeliveryFixtures.delivery1Id);
      expect(delivery, equals(DeliveryFixtures.delivery1));
    });

    test('getDeliveryById returns null for unknown id', () async {
      final delivery = await repository.getDeliveryById('unknown');
      expect(delivery, isNull);
    });

    test('getDeliveryByOrderId returns correct delivery', () async {
      final delivery = await repository.getDeliveryByOrderId(DeliveryFixtures.delivery1.orderId);
      expect(delivery, equals(DeliveryFixtures.delivery1));
    });

    test('saveDelivery updates repository', () async {
      final newDelivery = DeliveryFixtures.delivery1.copyWith(status: 'PICKED_UP');
      await repository.saveDelivery(newDelivery);
      final fetched = await repository.getDeliveryById(newDelivery.id);
      expect(fetched, equals(newDelivery));
    });
  });
}
