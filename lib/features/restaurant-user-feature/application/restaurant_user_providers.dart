import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth-feature/application/auth_providers.dart';
import '../domain/restaurant_user.dart';
import '../domain/restaurant_user_repository.dart';
import '../infrastructure/restaurant_user_service.dart';

/// Provider for the RestaurantUserRepository
final restaurantUserRepositoryProvider = Provider<RestaurantUserRepository>((ref) {
  return RestaurantUserService.instance;
});

/// StreamProvider for a specific restaurant user
final restaurantUserStreamProvider = StreamProvider.family<RestaurantUser?, String>((ref, uid) {
  return ref.watch(restaurantUserRepositoryProvider).watchRestaurantUser(uid);
});

/// Provider for the currently logged-in restaurant user data
final currentRestaurantUserProvider = StreamProvider<RestaurantUser?>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) {
    return Stream.value(null);
  }
  return ref.watch(restaurantUserRepositoryProvider).watchRestaurantUser(authUser.uid);
});
