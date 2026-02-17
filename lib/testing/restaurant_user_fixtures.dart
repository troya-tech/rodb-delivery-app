import 'package:rodb_delivery_app/features/restaurant-user-feature/domain/restaurant_user.dart';

/// Test fixtures for restaurant user data, based on the Firebase RTDB export.
class RestaurantUserFixtures {
  // --- Common constants shared across users ---
  static const int restaurantKey = 318920;
  static const String restaurantsRelatedKey = 'key_nfc';

  // --- User 1: nfcompany ---
  static const String user1Uid = '23efasdf';
  static const String user1Email = 'nfcompany17@gmail.com';

  // --- User 2: wikiwings ---
  static const String user2Uid = 'asdfsadfijl';
  static const String user2Email = 'wikiwings17@gmail.com';

  // --- User 3: troyatech ---
  static const String user3Uid = 'sdfasdf';
  static const String user3Email = 'troyatech17@gmail.com';

  // --- User 4: Furkan (from AuthFixtures) ---
  static const String user4Uid = '7UMNf9av9YZSU4fUx17D5IGHG6I2';
  static const String user4Email = 'foorcun@gmail.com';

  // --- Domain model instances ---
  static const RestaurantUser testUser1 = RestaurantUser(
    uid: user1Uid,
    email: user1Email,
    restaurantKeys: ['$restaurantKey'],
    role: UserRole.owner,
  );

  static const RestaurantUser testUser2 = RestaurantUser(
    uid: user2Uid,
    email: user2Email,
    restaurantKeys: ['$restaurantKey'],
    role: UserRole.owner,
  );

  static const RestaurantUser testUser3 = RestaurantUser(
    uid: user3Uid,
    email: user3Email,
    restaurantKeys: ['$restaurantKey'],
    role: UserRole.owner,
  );

  static const RestaurantUser testUser4 = RestaurantUser(
    uid: user4Uid,
    email: user4Email,
    restaurantKeys: ['$restaurantKey'],
    role: UserRole.owner,
  );

  // --- Individual user maps (matches Firebase JSON structure) ---
  static const Map<String, dynamic> testUser1Map = {
    'email': user1Email,
    'restaurantKeys': {
      'restaurantKey': restaurantKey,
    },
    'restaurantsRelated': {
      'key': restaurantsRelatedKey,
    },
    'role': 'OWNER',
  };

  static const Map<String, dynamic> testUser2Map = {
    'email': user2Email,
    'restaurantKeys': {
      'restaurantKey': restaurantKey,
    },
    'restaurantsRelated': {
      'key': restaurantsRelatedKey,
    },
    'role': 'OWNER',
  };

  static const Map<String, dynamic> testUser3Map = {
    'email': user3Email,
    'restaurantKeys': {
      'restaurantKey': restaurantKey,
    },
    'restaurantsRelated': {
      'key': restaurantsRelatedKey,
    },
    'role': 'OWNER',
  };

  static const Map<String, dynamic> testUser4Map = {
    'email': user4Email,
    'restaurantKeys': {
      'restaurantKey': restaurantKey,
    },
    'restaurantsRelated': {
      'key': restaurantsRelatedKey,
    },
    'role': 'OWNER',
  };

  // --- Full "restaurantUsers" node as it appears in the RTDB export ---
  static const Map<String, dynamic> restaurantUsersNode = {
    user1Uid: testUser1Map,
    user2Uid: testUser2Map,
    user3Uid: testUser3Map,
    user4Uid: testUser4Map,
  };
}
