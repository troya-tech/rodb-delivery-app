import 'package:rxdart/rxdart.dart';
import 'package:rodb_delivery_app/features/store-feature/domain/store.dart';
import 'package:rodb_delivery_app/features/store-feature/domain/store_repository.dart';
import 'package:rodb_delivery_app/testing/store_fixtures.dart';
import 'package:rodb_delivery_app/features/store-feature/domain/currency.dart';

/// A fake implementation of [StoreRepository] for testing purposes.
///
/// Following Vladimir Khorikov's definition of a **Fake**:
/// It provides a functional, stateful, but simplified implementation of the
/// repository without external dependencies (Firebase).
///
/// It maintains an in-memory store map and exposes streams for real-time
/// updates during tests.
class FakeStoreRepository implements StoreRepository {
  /// In-memory store indexed by store ID.
  final Map<String, Store> _stores = {};

  /// Stream controller per store ID, using BehaviorSubject so new listeners
  /// immediately receive the latest value.
  final Map<String, BehaviorSubject<Store?>> _controllers = {};

  /// Creates a [FakeStoreRepository].
  ///
  /// If [seedWithFixture] is true (default), it pre-populates the store
  /// from [StoreFixtures] so tests start with realistic data.
  FakeStoreRepository({bool seedWithFixture = true}) {
    if (seedWithFixture) {
      _seedFromFixture();
    }
  }

  void _seedFromFixture() {
    final store = Store(
      id: StoreFixtures.storeId,
      name: StoreFixtures.storeName,
      address: StoreFixtures.storeAddress,
      addressId: StoreFixtures.addressId,
      city: StoreFixtures.city,
      currency: const Currency(
        code: StoreFixtures.currencyCode,
        symbol: StoreFixtures.currencySymbol,
      ),
      defaultCookingTime: StoreFixtures.defaultCookingTime,
      isActive: StoreFixtures.isActive,
      locationLat: StoreFixtures.locationLat,
      locationLng: StoreFixtures.locationLng,
      organizationalType: StoreFixtures.organizationalType,
      ownerId: StoreFixtures.ownerId,
      updatedAt: StoreFixtures.updatedAt,
    );
    _stores[store.id] = store;
  }

  BehaviorSubject<Store?> _controllerFor(String storeId) {
    return _controllers.putIfAbsent(
      storeId,
      () => BehaviorSubject<Store?>.seeded(_stores[storeId]),
    );
  }

  @override
  Future<Store?> getStoreById(String storeId) async {
    return _stores[storeId];
  }

  @override
  Stream<Store?> watchStoreById(String storeId) {
    return _controllerFor(storeId).stream;
  }

  @override
  Future<List<Store>> getStoresByOwnerId(String ownerId) async {
    return _stores.values
        .where((store) => store.ownerId == ownerId)
        .toList();
  }

  @override
  Future<void> saveStore(Store store) async {
    _stores[store.id] = store;
    _controllerFor(store.id).add(store);
  }

  // ── Test helpers ──────────────────────────────────────────────────────

  /// Manually inject a store into the fake repository.
  void emitStore(Store store) {
    _stores[store.id] = store;
    _controllerFor(store.id).add(store);
  }

  /// Remove a store, emitting null to any watchers.
  void removeStore(String storeId) {
    _stores.remove(storeId);
    _controllerFor(storeId).add(null);
  }

  /// Clean up all stream controllers.
  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
}
