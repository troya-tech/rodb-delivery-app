import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../restaurant-user-feature/application/restaurant_user_providers.dart';
import '../domain/order.dart';
import '../domain/order_repository.dart';
import '../infrastructure/order_service.dart';

/// Provider for the OrderRepository
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderService.instance;
});

/// Internal provider for all orders (raw stream)
final _allOrdersStreamProvider = StreamProvider<List<Order>>((ref) {
  final restaurantUserAsync = ref.watch(currentRestaurantUserProvider);
  
  return restaurantUserAsync.when(
    data: (user) {
      if (user == null || user.restaurantKeys.isEmpty) {
        return Stream.value([]);
      }
      return ref.watch(orderRepositoryProvider)
          .watchOrdersForStores(user.restaurantKeys);
    },
    loading: () => const Stream.empty(),
    error: (err, stack) => Stream.error(err),
  );
});

/// Provider for active (not delivered) orders
final activeOrdersStreamProvider = Provider<AsyncValue<List<Order>>>((ref) {
  final allOrders = ref.watch(_allOrdersStreamProvider);
  return allOrders.whenData((orders) => 
    orders.where((o) => !o.meta.isDelivered).toList()
  );
});

/// Provider for delivered orders
final deliveredOrdersStreamProvider = Provider<AsyncValue<List<Order>>>((ref) {
  final allOrders = ref.watch(_allOrdersStreamProvider);
  return allOrders.whenData((orders) => 
    orders.where((o) => o.meta.isDelivered).toList()
  );
});

/// FutureProvider for fetching orders (if needed)
final ordersFutureProvider = FutureProvider<List<Order>>((ref) {
  return ref.watch(orderRepositoryProvider).getOrders();
});
