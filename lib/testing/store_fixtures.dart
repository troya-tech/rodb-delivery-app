/// Test fixtures for store data, based on the Firebase RTDB export.
class StoreFixtures {
  // --- Individual field constants for easy access in tests ---
  static const String storeId = '318920';
  static const String storeName = 'NFC Burger';
  static const String storeAddress =
      'Cevat Paşa, Kayserili Ahmet Paşa Cd., 17100 Çanakkale Merkez/Çanakkale';
  static const int addressId = 500;
  static const String city = 'Canakkale';
  static const String currencyCode = 'TRY';
  static const String currencySymbol = '₺';
  static const int defaultCookingTime = 20;
  static const bool isActive = true;
  static const double locationLat = 40.147140757277356;
  static const double locationLng = 26.412926195189147;
  static const String organizationalType = 'BRICK_AND_MORTAR';
  static const String ownerId = 'AIDPRmbJU3hlJUH3KdkizXmiA2Y2';
  static const int updatedAt = 1678900000000;

  // --- Currency as a map ---
  static const Map<String, String> currency = {
    'code': currencyCode,
    'symbol': currencySymbol,
  };

  // --- Full store entry as a map (matches Firebase JSON structure) ---
  static const Map<String, dynamic> testStoreMap = {
    'address': storeAddress,
    'addressId': addressId,
    'city': city,
    'currency': currency,
    'defaultCookingTime': defaultCookingTime,
    'id': storeId,
    'isActive': isActive,
    'locationLat': locationLat,
    'locationLng': locationLng,
    'name': storeName,
    'organizationalType': organizationalType,
    'ownerId': ownerId,
    'updatedAt': updatedAt,
  };

  // --- Full "stores" node as it appears in the RTDB export ---
  static const Map<String, dynamic> storesNode = {
    storeId: testStoreMap,
  };
}
