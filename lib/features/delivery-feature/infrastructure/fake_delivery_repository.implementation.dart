import 'package:rodb_delivery_app/utils/app_logger.dart';
import '../domain/delivery.dart';
import '../domain/delivery_repository.dart';

/// In-memory implementation of [DeliveryRepository] for testing.
class FakeDeliveryRepository implements DeliveryRepository {
  final Map<String, Delivery> _deliveries = {};
  static final _logger = AppLogger('FakeDeliveryRepository');

  FakeDeliveryRepository({List<Delivery>? initialDeliveries}) {
    if (initialDeliveries != null) {
      for (final delivery in initialDeliveries) {
        _deliveries[delivery.id] = delivery;
      }
    }
  }

  @override
  Future<Delivery?> getDeliveryById(String id) async {
    _logger.info('Fake getting delivery by ID: $id');
    return _deliveries[id];
  }

  @override
  Future<Delivery?> getDeliveryByOrderId(String orderId) async {
    _logger.info('Fake getting delivery by order ID: $orderId');
    try {
      return _deliveries.values.firstWhere((d) => d.orderId == orderId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveDelivery(Delivery delivery) async {
    _logger.info('Fake saving delivery: ${delivery.id}');
    _deliveries[delivery.id] = delivery;
  }

  @override
  Stream<Delivery?> watchDelivery(String id) {
    _logger.info('Fake watching delivery: $id');
    // For simplicity, just return the current value as a single-event stream
    // In a real app, this would use a StreamController to emit updates
    return Stream.value(_deliveries[id]);
  }
}
