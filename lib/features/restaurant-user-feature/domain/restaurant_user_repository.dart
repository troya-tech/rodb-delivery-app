import 'restaurant_user.dart';

abstract class RestaurantUserRepository {
  Future<RestaurantUser?> getRestaurantUser(String uid);
  Future<void> saveRestaurantUser(RestaurantUser user);
  Stream<RestaurantUser?> watchRestaurantUser(String uid);
  Future<void> addRestaurantKey(String uid, String restaurantKey);
}
