import 'package:firebase_database/firebase_database.dart';
import 'package:rodb_delivery_app/utils/app_logger.dart';
import 'package:rodb_delivery_app/features/store-feature/domain/store.dart';
import 'package:rodb_delivery_app/features/store-feature/domain/store_repository.dart';

/// Firebase Realtime Database implementation of [StoreRepository].
///
/// Reads from and writes to the `/stores` node in the RTDB,
/// where each child key is the store ID.
class FirebaseStoreRepository implements StoreRepository {
  // Singleton pattern — consistent with AuthService / RestaurantUserService
  const FirebaseStoreRepository._();
  static const FirebaseStoreRepository instance = FirebaseStoreRepository._();
  factory FirebaseStoreRepository() => instance;

  static final _logger = AppLogger('FirebaseStoreRepository');

  DatabaseReference get _dbRef => FirebaseDatabase.instance.ref('stores');

  @override
  Future<Store?> getStoreById(String storeId) async {
    final context = _logger.createContext();
    _logger.info('Getting store by ID: $storeId', context);

    try {
      final snapshot = await _dbRef.child(storeId).get();
      if (!snapshot.exists) return null;

      final data = snapshot.value;
      if (data is Map) {
        return Store.fromMap(storeId, data);
      }
      return null;
    } catch (e) {
      _logger.error('Failed to get store', e, null, context);
      return null;
    }
  }

  @override
  Stream<Store?> watchStoreById(String storeId) {
    _logger.info('Watching store by ID: $storeId');

    return _dbRef.child(storeId).onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return null;

      if (data is Map) {
        return Store.fromMap(storeId, data);
      }
      return null;
    });
  }

  @override
  Future<List<Store>> getStoresByOwnerId(String ownerId) async {
    final context = _logger.createContext();
    _logger.info('Getting stores by owner ID: $ownerId', context);

    try {
      final snapshot =
          await _dbRef.orderByChild('ownerId').equalTo(ownerId).get();
      if (!snapshot.exists) return [];

      final value = snapshot.value;
      if (value is Map) {
        return value.entries.map((entry) {
          final key = entry.key as String;
          final storeData = entry.value as Map<dynamic, dynamic>;
          return Store.fromMap(key, storeData);
        }).toList();
      }
      return [];
    } catch (e) {
      _logger.error('Failed to get stores by owner', e, null, context);
      return [];
    }
  }

  @override
  Future<void> saveStore(Store store) async {
    final context = _logger.createContext();
    _logger.info('Saving store: ${store.id}', context);

    try {
      await _dbRef.child(store.id).set(store.toMap());
      _logger.success('Store saved successfully', context);
    } catch (e) {
      _logger.error('Failed to save store', e, null, context);
      rethrow;
    }
  }
}
