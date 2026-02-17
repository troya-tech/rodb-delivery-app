import 'package:rxdart/rxdart.dart';
import 'package:rodb_delivery_app/features/order-feature/domain/order.dart';
import 'package:rodb_delivery_app/features/order-feature/domain/order_repository.dart';
import 'package:rodb_delivery_app/testing/order_fixtures.dart';

/// A fake implementation of [OrderRepository] for testing purposes.
///
/// Following Vladimir Khorikov's definition of a **Fake**:
/// It provides a functional, stateful, but simplified implementation of the
/// repository without external dependencies (Firebase).
///
/// It maintains an in-memory orders map keyed by store ID and exposes streams
/// for real-time updates during tests.
class FakeOrderRepository implements OrderRepository {
  /// In-memory orders indexed by store ID → list of orders.
  final Map<String, List<Order>> _ordersByStore = {};

  /// Stream controller for order updates, using BehaviorSubject so new
  /// listeners immediately receive the latest value.
  final BehaviorSubject<List<Order>> _ordersSubject =
      BehaviorSubject<List<Order>>.seeded([]);

  /// Creates a [FakeOrderRepository].
  ///
  /// If [seedWithFixture] is true (default), it pre-populates orders
  /// from [OrderFixtures] so tests start with realistic data.
  FakeOrderRepository({bool seedWithFixture = true}) {
    if (seedWithFixture) {
      _seedFromFixture();
    }
  }

  void _seedFromFixture() {
    _ordersByStore[OrderFixtures.storeId] = List.of(OrderFixtures.allOrders);
    _emitMerged();
  }

  void _emitMerged() {
    final merged = _ordersByStore.values.expand((x) => x).toList();
    merged.sort(
        (a, b) => b.meta.creationDate.compareTo(a.meta.creationDate));
    _ordersSubject.add(merged);
  }

  @override
  Future<List<Order>> getOrders() async {
    return _ordersSubject.value;
  }

  @override
  Future<Order?> getOrderById(String id) async {
    for (final orders in _ordersByStore.values) {
      for (final order in orders) {
        if (order.id == id) return order;
      }
    }
    return null;
  }

  @override
  Future<void> saveOrder(Order order) async {
    final storeOrders = _ordersByStore.putIfAbsent(
      OrderFixtures.storeId,
      () => [],
    );
    // Replace existing or add new
    final index = storeOrders.indexWhere((o) => o.id == order.id);
    if (index >= 0) {
      storeOrders[index] = order;
    } else {
      storeOrders.add(order);
    }
    _emitMerged();
  }

  @override
  Stream<List<Order>> watchOrders() {
    return _ordersSubject.stream;
  }

  @override
  Stream<List<Order>> watchOrdersForStores(List<String> storeIds) {
    // Filter to only the requested stores, then emit merged
    return _ordersSubject.stream.map((allOrders) {
      // If store IDs are provided, filter; otherwise return all
      if (storeIds.isEmpty) return <Order>[];
      return allOrders
          .where((order) =>
              storeIds.any((id) => _ordersByStore[id]?.contains(order) == true))
          .toList();
    });
  }

  // ── Test helpers ──────────────────────────────────────────────────────

  /// Replace all orders for a given store.
  void emitOrders(String storeId, List<Order> orders) {
    _ordersByStore[storeId] = List.of(orders);
    _emitMerged();
  }

  /// Add a single order to a store.
  void addOrder(String storeId, Order order) {
    _ordersByStore.putIfAbsent(storeId, () => []).add(order);
    _emitMerged();
  }

  /// Remove a single order by ID from all stores.
  void removeOrder(String orderId) {
    for (final orders in _ordersByStore.values) {
      orders.removeWhere((o) => o.id == orderId);
    }
    _emitMerged();
  }

  /// Clear all orders (emits empty list).
  void clearAll() {
    _ordersByStore.clear();
    _emitMerged();
  }

  /// Clean up the stream controller.
  void dispose() {
    _ordersSubject.close();
  }
}
