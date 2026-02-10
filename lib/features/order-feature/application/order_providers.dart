import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../restaurant-user-feature/application/restaurant_user_providers.dart';
import '../domain/order.dart';
import '../domain/order_repository.dart';
import '../infrastructure/order_service.dart';

/// Provider for the OrderRepository
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderService.instance;
});

/// StreamProvider for all orders linked to the current user's restaurants
final ordersStreamProvider = StreamProvider<List<Order>>((ref) {
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

/// FutureProvider for fetching orders (if needed)
final ordersFutureProvider = FutureProvider<List<Order>>((ref) {
  return ref.watch(orderRepositoryProvider).getOrders();
});
