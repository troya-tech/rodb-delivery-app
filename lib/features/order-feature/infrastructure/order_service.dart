import '../domain/order.dart';
import '../domain/order_repository.dart';
import '../../../../utils/app_logger.dart';

class OrderService implements OrderRepository {
  // Singleton pattern
  const OrderService._();
  static const OrderService instance = OrderService._();
  factory OrderService() => instance;

  static final _logger = AppLogger('OrderService');

  @override
  Future<List<Order>> getOrders() async {
    _logger.info('Getting all orders');
    // TODO: Implement Firebase Realtime Database fetching
    return [];
  }

  @override
  Future<Order?> getOrderById(String id) async {
    _logger.info('Getting order by id: $id');
    // TODO: Implement fetching
    return null;
  }

  @override
  Future<void> saveOrder(Order order) async {
    _logger.info('Saving order: ${order.shortOrderId}');
    // TODO: Implement saving
  }

  @override
  Stream<List<Order>> watchOrders() {
    _logger.info('Watching orders');
    // TODO: Implement Firebase Stream
    return const Stream.empty();
  }
}
