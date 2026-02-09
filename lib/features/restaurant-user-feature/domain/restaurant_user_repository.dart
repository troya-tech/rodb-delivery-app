import 'restaurant_user.dart';

abstract class RestaurantUserRepository {
  Future<RestaurantUser?> getRestaurantUserByEmail(String email);
  Future<void> saveRestaurantUser(RestaurantUser user);
  Stream<RestaurantUser?> watchRestaurantUserByEmail(String email);
  Future<void> addRestaurantKey(String uid, String restaurantKey);
}
