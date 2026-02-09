import 'order.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders();
  Future<Order?> getOrderById(String id);
  Future<void> saveOrder(Order order);
  Stream<List<Order>> watchOrders();
}
