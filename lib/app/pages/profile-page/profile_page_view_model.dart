import 'package:equatable/equatable.dart';
import 'package:rodb_delivery_app/features/auth-feature/domain/auth_user.dart';
import 'package:rodb_delivery_app/features/restaurant-user-feature/domain/restaurant_user.dart';
import 'package:rodb_delivery_app/features/store-feature/domain/store.dart';

/// A key–name pair representing a restaurant the user is associated with.
class RestaurantInfo extends Equatable {
  final String key;
  final String name;

  const RestaurantInfo({required this.key, required this.name});

  @override
  List<Object?> get props => [key, name];
}

/// View model entity for the Profile Page.
///
/// A flat, display-ready data object produced by [ProfilePageFacade].
/// The widget consumes this directly — no nested `AsyncValue` unwrapping.
class ProfilePageViewModel extends Equatable {
  final String displayName;
  final String email;
  final String? photoUrl;
  final String? roleLabel;
  final List<RestaurantInfo> restaurants;
  final bool hasRestaurantProfile;

  const ProfilePageViewModel({
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.roleLabel,
    this.restaurants = const [],
    this.hasRestaurantProfile = false,
  });

  /// Factory that maps domain models into display-ready fields.
  ///
  /// [stores] is a map of restaurant key → [Store?], resolved by the facade.
  factory ProfilePageViewModel.fromDomain({
    required AuthUser authUser,
    RestaurantUser? restaurantUser,
    Map<String, Store?> stores = const {},
  }) {
    final restaurants = (restaurantUser?.restaurantKeys ?? []).map((key) {
      final store = stores[key];
      return RestaurantInfo(
        key: key,
        name: store?.name ?? key, // fallback to key if store not loaded
      );
    }).toList();

    return ProfilePageViewModel(
      displayName: authUser.displayName ?? 'No Name',
      email: authUser.email ?? '',
      photoUrl: authUser.photoUrl,
      roleLabel: restaurantUser?.role.name.toUpperCase(),
      restaurants: restaurants,
      hasRestaurantProfile: restaurantUser != null,
    );
  }

  @override
  List<Object?> get props => [
        displayName,
        email,
        photoUrl,
        roleLabel,
        restaurants,
        hasRestaurantProfile,
      ];
}
