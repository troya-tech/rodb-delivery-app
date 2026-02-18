import 'order.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders();
  Future<Order?> getOrderById(String id);
  Future<void> saveOrder(Order order);
  Future<void> markAsDelivered(String orderId);
  Stream<List<Order>> watchOrders();
  Stream<List<Order>> watchOrdersForStores(List<String> storeIds);
  Stream<List<Order>> watchOrdersForStoresInRange(
    List<String> storeIds,
    String startDate,
    String endDate,
  );
}
