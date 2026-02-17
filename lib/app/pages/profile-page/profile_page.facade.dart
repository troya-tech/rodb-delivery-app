import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rodb_delivery_app/features/auth-feature/application/auth_providers.dart';
import 'package:rodb_delivery_app/features/restaurant-user-feature/application/restaurant_user_providers.dart';
import 'package:rodb_delivery_app/features/store-feature/application/store_service.dart';
import 'package:rodb_delivery_app/features/store-feature/domain/store.dart';
import 'package:rodb_delivery_app/utils/app_logger.dart';

import 'profile_page_view_model.dart';

// ──────────────────────────────────────────────────────────────────────────────
// State
// ──────────────────────────────────────────────────────────────────────────────

/// The facade state for the profile page.
///
/// Collapses two `AsyncValue` streams (auth + restaurant-user) into a single
/// tri-state so the widget only handles one `.when(...)`.
sealed class ProfilePageState {
  const ProfilePageState();
}

class ProfilePageLoading extends ProfilePageState {
  const ProfilePageLoading();
}

class ProfilePageError extends ProfilePageState {
  final Object error;
  final StackTrace? stackTrace;
  const ProfilePageError(this.error, [this.stackTrace]);
}

class ProfilePageNotAuthenticated extends ProfilePageState {
  const ProfilePageNotAuthenticated();
}

class ProfilePageLoaded extends ProfilePageState {
  final ProfilePageViewModel viewModel;
  const ProfilePageLoaded(this.viewModel);
}

// ──────────────────────────────────────────────────────────────────────────────
// Facade Provider
// ──────────────────────────────────────────────────────────────────────────────

/// Facade for the Profile Page.
///
/// Watches [authStateProvider] and [currentRestaurantUserProvider], merges
/// them into a single [ProfilePageState], and maps loaded data into a
/// [ProfilePageViewModel] entity.
///
/// Usage in the widget:
/// ```dart
/// final state = ref.watch(profilePageFacadeProvider);
/// switch (state) {
///   case ProfilePageLoading():    ...
///   case ProfilePageError(:final error): ...
///   case ProfilePageNotAuthenticated(): ...
///   case ProfilePageLoaded(:final viewModel): ...
/// }
/// ```
final profilePageFacadeProvider = Provider<ProfilePageState>((ref) {
  const logger = AppLogger('ProfilePageFacade');

  final authAsync = ref.watch(authStateProvider);
  final restaurantAsync = ref.watch(currentRestaurantUserProvider);

  return authAsync.when(
    loading: () => const ProfilePageLoading(),
    error: (err, stack) {
      logger.error('Error loading auth state', err, stack);
      return ProfilePageError(err, stack);
    },
    data: (authUser) {
      if (authUser == null) {
        logger.warning('User is not authenticated');
        return const ProfilePageNotAuthenticated();
      }

      logger.data('Auth user loaded', authUser.uid);

      return restaurantAsync.when(
        loading: () => const ProfilePageLoading(),
        error: (err, stack) {
          logger.error('Error loading restaurant user profile', err, stack);
          return ProfilePageError(err, stack);
        },
        data: (restaurantUser) {
          logger.data('Restaurant user loaded', restaurantUser?.uid);

          // Resolve store data for each restaurant key
          final Map<String, Store?> stores = {};
          for (final key in restaurantUser?.restaurantKeys ?? <String>[]) {
            final storeAsync = ref.watch(storeStreamProvider(key));
            stores[key] = storeAsync.valueOrNull;
          }

          final viewModel = ProfilePageViewModel.fromDomain(
            authUser: authUser,
            restaurantUser: restaurantUser,
            stores: stores,
          );
          return ProfilePageLoaded(viewModel);
        },
      );
    },
  );
});

// ──────────────────────────────────────────────────────────────────────────────
// Actions
// ──────────────────────────────────────────────────────────────────────────────

/// Signs the user out via the auth repository.
///
/// Call this after the UI has confirmed the user's intent (e.g. after a
/// confirmation dialog). Returns `true` on success, `false` on failure.
Future<bool> profilePageSignOut(WidgetRef ref) async {
  const logger = AppLogger('ProfilePageFacade');
  try {
    await ref.read(authRepositoryProvider).signOut();
    return true;
  } catch (e, stack) {
    logger.error('Sign-out failed', e, stack);
    return false;
  }
}
