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
/// StreamProvider for a specific restaurant user by email
final restaurantUserStreamProvider = StreamProvider.family<RestaurantUser?, String>((ref, email) {
  return ref.watch(restaurantUserRepositoryProvider).watchRestaurantUserByEmail(email);
});

/// Provider for the currently logged-in restaurant user data
final currentRestaurantUserProvider = StreamProvider<RestaurantUser?>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null || authUser.email == null) {
    return Stream.value(null);
  }
  return ref.watch(restaurantUserRepositoryProvider).watchRestaurantUserByEmail(authUser.email!);
});
