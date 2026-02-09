import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/order.dart';
import '../domain/order_repository.dart';
import '../infrastructure/order_service.dart';

/// Provider for the OrderRepository
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderService.instance;
});

/// StreamProvider for all orders
final ordersStreamProvider = StreamProvider<List<Order>>((ref) {
  return ref.watch(orderRepositoryProvider).watchOrders();
});

/// FutureProvider for fetching orders (if needed)
final ordersFutureProvider = FutureProvider<List<Order>>((ref) {
  return ref.watch(orderRepositoryProvider).getOrders();
});
