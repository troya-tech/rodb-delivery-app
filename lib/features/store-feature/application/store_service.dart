import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rodb_delivery_app/features/store-feature/domain/store.dart';
import 'package:rodb_delivery_app/features/store-feature/domain/store_repository.dart';
import 'package:rodb_delivery_app/features/store-feature/infrastructure/firebase_store_repository.implementation.dart';

/// Provider for the [StoreRepository].
///
/// By default, wires to [FirebaseStoreRepository].
/// Override this in tests to inject [FakeStoreRepository].
final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  return FirebaseStoreRepository.instance;
});

/// StreamProvider that watches a single store by its ID.
final storeStreamProvider = StreamProvider.family<Store?, String>((ref, storeId) {
  return ref.watch(storeRepositoryProvider).watchStoreById(storeId);
});

/// FutureProvider that fetches a single store by its ID.
final storeFutureProvider = FutureProvider.family<Store?, String>((ref, storeId) {
  return ref.watch(storeRepositoryProvider).getStoreById(storeId);
});

/// FutureProvider that fetches all stores for a given owner ID.
final storesByOwnerProvider = FutureProvider.family<List<Store>, String>((ref, ownerId) {
  return ref.watch(storeRepositoryProvider).getStoresByOwnerId(ownerId);
});
