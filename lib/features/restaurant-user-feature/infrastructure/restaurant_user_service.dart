import 'package:firebase_database/firebase_database.dart';
import '../domain/restaurant_user.dart';
import '../domain/restaurant_user_repository.dart';
import '../../../../utils/app_logger.dart';

class RestaurantUserService implements RestaurantUserRepository {
  // Singleton pattern
  const RestaurantUserService._();
  static const RestaurantUserService instance = RestaurantUserService._();
  factory RestaurantUserService() => instance;

  static final _logger = AppLogger('RestaurantUserService');

  DatabaseReference get _dbRef => FirebaseDatabase.instance.ref('restaurantUsers');

  @override
  Future<RestaurantUser?> getRestaurantUserByEmail(String email) async {
    final context = _logger.createContext();
    _logger.info('Getting restaurant user by email: $email', context);
    
    try {
      final snapshot = await _dbRef.orderByChild('email').equalTo(email).get();
      if (!snapshot.exists) return null;
      
      final value = snapshot.value;
      if (value is Map) {
        final entries = value.entries;
        if (entries.isEmpty) return null;

        final firstEntry = entries.first;
        final key = firstEntry.key as String;
        final userData = firstEntry.value as Map<dynamic, dynamic>;

        return _mapSnapshotToUser(key, userData);
      }
      return null;
    } catch (e) {
      _logger.error('Failed to get restaurant user', e, null, context);
      return null;
    }
  }

  @override
  Stream<RestaurantUser?> watchRestaurantUserByEmail(String email) {
    // Queries in Firebase return a Map where keys are the pushIDs/UIDs
    // Since we are querying by email, we expect 0 or 1 result ideally.
    final query = _dbRef.orderByChild('email').equalTo(email);
    
    _logger.info('Watching restaurant user by email: $email');
    return query.onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) return null;

      if (value is Map) { 
        // value is { "somePushId": { "email": "...", ... } }
        final entries = value.entries;
        if (entries.isEmpty) return null;

        // Take the first match
        final firstEntry = entries.first;
        final key = firstEntry.key as String;
        final userData = firstEntry.value as Map<dynamic, dynamic>;

        return _mapSnapshotToUser(key, userData);
      }
      return null;
    });
  }

  @override
  Future<void> saveRestaurantUser(RestaurantUser user) async {
    final context = _logger.createContext();
    _logger.info('Saving restaurant user: ${user.uid}', context);
    
    try {
      await _dbRef.child(user.uid).set({
        'email': user.email,
        'role': user.role.toJson(),
        // restaurantKeys might be handled separately or updated as a list
      });
      _logger.success('User saved successfully', context);
    } catch (e) {
      _logger.error('Failed to save user', e, null, context);
      rethrow;
    }
  }

  @override
  Future<void> addRestaurantKey(String uid, String restaurantKey) async {
    final context = _logger.createContext();
    _logger.info('Adding restaurant key $restaurantKey to user $uid', context);
    
    try {
      // Based on image structure: restaurantKeys -> { restaurantKey: value }
      // This looks like it might be an append-only or specific path
      await _dbRef.child(uid).child('restaurantKeys').update({
        'restaurantKey': restaurantKey, // Note: image shows 'restaurantKey' as a key itself
      });
      _logger.success('Restaurant key added', context);
    } catch (e) {
      _logger.error('Failed to add restaurant key', e, null, context);
      rethrow;
    }
  }

  RestaurantUser _mapSnapshotToUser(String uid, Map<dynamic, dynamic> data) {
    final restaurantKeysData = data['restaurantKeys'] as Map<dynamic, dynamic>?;
    final List<String> keys = [];
    
    if (restaurantKeysData != null) {
      // Handle the case where restaurantKey is a single value or multiple
      if (restaurantKeysData.containsKey('restaurantKey')) {
        keys.add(restaurantKeysData['restaurantKey'].toString());
      }
      // If there are more keys, they would be iterated here
    }

    return RestaurantUser(
      uid: uid,
      email: data['email'] ?? '',
      role: UserRole.fromString(data['role'] ?? ''),
      restaurantKeys: keys,
    );
  }
}
