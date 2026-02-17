import 'package:flutter_test/flutter_test.dart';
import 'package:rodb_delivery_app/features/store-feature/domain/currency.dart';
import 'package:rodb_delivery_app/features/store-feature/domain/store.dart';
import 'package:rodb_delivery_app/features/store-feature/infrastructure/fake_store_repository.implementation.dart';
import 'package:rodb_delivery_app/testing/store_fixtures.dart';

void main() {
  late FakeStoreRepository repo;

  group('FakeStoreRepository — seeded', () {
    setUp(() {
      repo = FakeStoreRepository(); // seedWithFixture: true by default
    });

    tearDown(() {
      repo.dispose();
    });

    test('seeds fixture store on creation', () async {
      final store = await repo.getStoreById(StoreFixtures.storeId);

      expect(store, isNotNull);
      expect(store!.id, StoreFixtures.storeId);
      expect(store.name, StoreFixtures.storeName);
      expect(store.ownerId, StoreFixtures.ownerId);
    });

    test('getStoreById returns null for unknown ID', () async {
      final store = await repo.getStoreById('unknown-id');

      expect(store, isNull);
    });

    test('getStoresByOwnerId returns seeded store', () async {
      final stores = await repo.getStoresByOwnerId(StoreFixtures.ownerId);

      expect(stores, hasLength(1));
      expect(stores.first.id, StoreFixtures.storeId);
    });

    test('getStoresByOwnerId returns empty for unknown owner', () async {
      final stores = await repo.getStoresByOwnerId('unknown-owner');

      expect(stores, isEmpty);
    });

    test('watchStoreById emits seeded store immediately', () async {
      final store = await repo.watchStoreById(StoreFixtures.storeId).first;

      expect(store, isNotNull);
      expect(store!.id, StoreFixtures.storeId);
    });
  });

  group('FakeStoreRepository — unseeded', () {
    setUp(() {
      repo = FakeStoreRepository(seedWithFixture: false);
    });

    tearDown(() {
      repo.dispose();
    });

    test('starts empty when seedWithFixture is false', () async {
      final store = await repo.getStoreById(StoreFixtures.storeId);

      expect(store, isNull);
    });

    test('watchStoreById emits null for unknown store', () async {
      final store = await repo.watchStoreById('nonexistent').first;

      expect(store, isNull);
    });
  });

  group('FakeStoreRepository — saveStore', () {
    setUp(() {
      repo = FakeStoreRepository(seedWithFixture: false);
    });

    tearDown(() {
      repo.dispose();
    });

    test('saveStore persists and is retrievable via getStoreById', () async {
      const newStore = Store(
        id: 'new-store',
        name: 'Test Store',
        address: '123 Test St',
        addressId: 100,
        city: 'TestCity',
        currency: Currency(code: 'USD', symbol: '\$'),
        defaultCookingTime: 15,
        isActive: true,
        locationLat: 41.0,
        locationLng: 29.0,
        organizationalType: 'CLOUD_KITCHEN',
        ownerId: 'owner-123',
        updatedAt: 1700000000000,
      );

      await repo.saveStore(newStore);
      final retrieved = await repo.getStoreById('new-store');

      expect(retrieved, equals(newStore));
    });

    test('saveStore emits update to watchStoreById listeners', () async {
      const store = Store(
        id: 'stream-test',
        name: 'Stream Store',
        address: '',
        addressId: 0,
        city: '',
        currency: Currency.defaultCurrency,
        defaultCookingTime: 10,
        isActive: true,
        locationLat: 0,
        locationLng: 0,
        organizationalType: '',
        ownerId: '',
        updatedAt: 0,
      );

      // Start watching before saving
      final emissions = <Store?>[];
      final sub = repo.watchStoreById('stream-test').listen(emissions.add);

      // Allow BehaviorSubject seed (null) to emit
      await Future.microtask(() {});

      // Save → should emit the store
      await repo.saveStore(store);
      await Future.microtask(() {});

      expect(emissions, [null, store]);

      await sub.cancel();
    });
  });

  group('FakeStoreRepository — test helpers', () {
    setUp(() {
      repo = FakeStoreRepository(seedWithFixture: false);
    });

    tearDown(() {
      repo.dispose();
    });

    test('emitStore injects a store and emits to stream', () async {
      const store = Store(
        id: 'emit-test',
        name: 'Emitted Store',
        address: '',
        addressId: 0,
        city: '',
        currency: Currency.defaultCurrency,
        defaultCookingTime: 20,
        isActive: true,
        locationLat: 0,
        locationLng: 0,
        organizationalType: '',
        ownerId: 'owner-x',
        updatedAt: 0,
      );

      repo.emitStore(store);

      final retrieved = await repo.getStoreById('emit-test');
      expect(retrieved, equals(store));

      final streamed = await repo.watchStoreById('emit-test').first;
      expect(streamed, equals(store));
    });

    test('removeStore deletes and emits null to stream', () async {
      const store = Store(
        id: 'remove-test',
        name: 'To Remove',
        address: '',
        addressId: 0,
        city: '',
        currency: Currency.defaultCurrency,
        defaultCookingTime: 20,
        isActive: true,
        locationLat: 0,
        locationLng: 0,
        organizationalType: '',
        ownerId: '',
        updatedAt: 0,
      );

      repo.emitStore(store);
      expect(await repo.getStoreById('remove-test'), isNotNull);

      // Track stream emissions
      final emissions = <Store?>[];
      final sub = repo.watchStoreById('remove-test').listen(emissions.add);
      await Future.microtask(() {});

      repo.removeStore('remove-test');
      await Future.microtask(() {});

      expect(await repo.getStoreById('remove-test'), isNull);
      // Stream should have emitted: store (from BehaviorSubject seed after emitStore), then null
      expect(emissions.last, isNull);

      await sub.cancel();
    });
  });
}
