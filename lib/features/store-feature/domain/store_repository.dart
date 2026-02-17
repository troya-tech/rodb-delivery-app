import 'store.dart';

/// Abstract repository contract for the Store feature.
///
/// Implementations:
/// - [StoreService] — Firebase Realtime Database
/// - [FakeStoreRepository] — In-memory fake for testing
abstract class StoreRepository {
  /// Fetches a single store by its [storeId].
  Future<Store?> getStoreById(String storeId);

  /// Watches a single store by its [storeId] via a real-time stream.
  Stream<Store?> watchStoreById(String storeId);

  /// Fetches all stores owned by [ownerId].
  Future<List<Store>> getStoresByOwnerId(String ownerId);

  /// Saves or updates a [store] entry.
  Future<void> saveStore(Store store);
}
