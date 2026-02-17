import 'package:flutter_test/flutter_test.dart';
import 'package:rodb_delivery_app/features/store-feature/domain/currency.dart';
import 'package:rodb_delivery_app/features/store-feature/domain/store.dart';
import 'package:rodb_delivery_app/testing/store_fixtures.dart';

void main() {
  group('Currency', () {
    group('fromMap', () {
      test('parses valid map correctly', () {
        final currency = Currency.fromMap({'code': 'TRY', 'symbol': '₺'});

        expect(currency.code, 'TRY');
        expect(currency.symbol, '₺');
      });

      test('falls back to TRY defaults when fields are missing', () {
        final currency = Currency.fromMap({});

        expect(currency.code, 'TRY');
        expect(currency.symbol, '₺');
      });

      test('handles null values gracefully', () {
        final currency = Currency.fromMap({'code': null, 'symbol': null});

        expect(currency.code, 'TRY');
        expect(currency.symbol, '₺');
      });
    });

    group('toMap', () {
      test('serializes correctly', () {
        const currency = Currency(code: 'USD', symbol: '\$');
        final map = currency.toMap();

        expect(map, {'code': 'USD', 'symbol': '\$'});
      });
    });

    group('equality', () {
      test('two currencies with same values are equal', () {
        const a = Currency(code: 'TRY', symbol: '₺');
        const b = Currency(code: 'TRY', symbol: '₺');

        expect(a, equals(b));
      });

      test('two currencies with different values are not equal', () {
        const a = Currency(code: 'TRY', symbol: '₺');
        const b = Currency(code: 'USD', symbol: '\$');

        expect(a, isNot(equals(b)));
      });
    });

    test('defaultCurrency is TRY', () {
      expect(Currency.defaultCurrency.code, 'TRY');
      expect(Currency.defaultCurrency.symbol, '₺');
    });
  });

  group('Store', () {
    group('fromMap', () {
      test('parses fixture map correctly', () {
        final store = Store.fromMap(
          StoreFixtures.storeId,
          StoreFixtures.testStoreMap,
        );

        expect(store.id, StoreFixtures.storeId);
        expect(store.name, StoreFixtures.storeName);
        expect(store.address, StoreFixtures.storeAddress);
        expect(store.addressId, StoreFixtures.addressId);
        expect(store.city, StoreFixtures.city);
        expect(store.currency.code, StoreFixtures.currencyCode);
        expect(store.currency.symbol, StoreFixtures.currencySymbol);
        expect(store.defaultCookingTime, StoreFixtures.defaultCookingTime);
        expect(store.isActive, StoreFixtures.isActive);
        expect(store.locationLat, StoreFixtures.locationLat);
        expect(store.locationLng, StoreFixtures.locationLng);
        expect(store.organizationalType, StoreFixtures.organizationalType);
        expect(store.ownerId, StoreFixtures.ownerId);
        expect(store.updatedAt, StoreFixtures.updatedAt);
      });

      test('uses defaults for completely empty map', () {
        final store = Store.fromMap('empty-id', {});

        expect(store.id, 'empty-id');
        expect(store.name, '');
        expect(store.address, '');
        expect(store.addressId, 0);
        expect(store.city, '');
        expect(store.currency, Currency.defaultCurrency);
        expect(store.defaultCookingTime, 20);
        expect(store.isActive, false);
        expect(store.locationLat, 0.0);
        expect(store.locationLng, 0.0);
        expect(store.organizationalType, '');
        expect(store.ownerId, '');
        expect(store.updatedAt, 0);
      });

      test('handles integer coordinates from Firebase (num → double)', () {
        final store = Store.fromMap('id', {
          'locationLat': 40, // int, not double
          'locationLng': 26, // int, not double
        });

        expect(store.locationLat, 40.0);
        expect(store.locationLng, 26.0);
      });

      test('handles missing currency gracefully', () {
        final store = Store.fromMap('id', {
          'currency': 'not-a-map', // invalid type
        });

        expect(store.currency, Currency.defaultCurrency);
      });
    });

    group('toMap', () {
      test('produces map that round-trips through fromMap', () {
        final original = Store.fromMap(
          StoreFixtures.storeId,
          StoreFixtures.testStoreMap,
        );

        final map = original.toMap();
        final restored = Store.fromMap(original.id, map);

        expect(restored, equals(original));
      });

      test('serialized map contains all fields', () {
        final store = Store.fromMap(
          StoreFixtures.storeId,
          StoreFixtures.testStoreMap,
        );
        final map = store.toMap();

        expect(map.containsKey('id'), isTrue);
        expect(map.containsKey('name'), isTrue);
        expect(map.containsKey('address'), isTrue);
        expect(map.containsKey('addressId'), isTrue);
        expect(map.containsKey('city'), isTrue);
        expect(map.containsKey('currency'), isTrue);
        expect(map.containsKey('defaultCookingTime'), isTrue);
        expect(map.containsKey('isActive'), isTrue);
        expect(map.containsKey('locationLat'), isTrue);
        expect(map.containsKey('locationLng'), isTrue);
        expect(map.containsKey('organizationalType'), isTrue);
        expect(map.containsKey('ownerId'), isTrue);
        expect(map.containsKey('updatedAt'), isTrue);
      });
    });

    group('copyWith', () {
      test('returns identical store when no overrides given', () {
        final store = Store.fromMap(
          StoreFixtures.storeId,
          StoreFixtures.testStoreMap,
        );

        expect(store.copyWith(), equals(store));
      });

      test('overrides only specified fields', () {
        final store = Store.fromMap(
          StoreFixtures.storeId,
          StoreFixtures.testStoreMap,
        );

        final updated = store.copyWith(
          name: 'Updated Name',
          isActive: false,
        );

        expect(updated.name, 'Updated Name');
        expect(updated.isActive, false);
        // Everything else unchanged
        expect(updated.id, store.id);
        expect(updated.address, store.address);
        expect(updated.city, store.city);
        expect(updated.currency, store.currency);
        expect(updated.ownerId, store.ownerId);
      });
    });

    group('equality', () {
      test('two stores from the same map are equal', () {
        final a = Store.fromMap(
          StoreFixtures.storeId,
          StoreFixtures.testStoreMap,
        );
        final b = Store.fromMap(
          StoreFixtures.storeId,
          StoreFixtures.testStoreMap,
        );

        expect(a, equals(b));
      });

      test('stores with different IDs are not equal', () {
        final a = Store.fromMap('id-a', StoreFixtures.testStoreMap);
        final b = Store.fromMap('id-b', StoreFixtures.testStoreMap);

        expect(a, isNot(equals(b)));
      });
    });
  });
}
