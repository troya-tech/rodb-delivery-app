import 'package:equatable/equatable.dart';
import 'package:rodb_delivery_app/features/auth-feature/domain/auth_user.dart';
import 'package:rodb_delivery_app/features/restaurant-user-feature/domain/restaurant_user.dart';

/// View model entity for the Profile Page.
///
/// A flat, display-ready data object produced by [ProfilePageFacade].
/// The widget consumes this directly — no nested `AsyncValue` unwrapping.
class ProfilePageViewModel extends Equatable {
  final String displayName;
  final String email;
  final String? photoUrl;
  final String? roleLabel;
  final List<String> restaurantKeys;
  final bool hasRestaurantProfile;

  const ProfilePageViewModel({
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.roleLabel,
    this.restaurantKeys = const [],
    this.hasRestaurantProfile = false,
  });

  /// Factory that maps domain models into display-ready fields.
  factory ProfilePageViewModel.fromDomain({
    required AuthUser authUser,
    RestaurantUser? restaurantUser,
  }) {
    return ProfilePageViewModel(
      displayName: authUser.displayName ?? 'No Name',
      email: authUser.email ?? '',
      photoUrl: authUser.photoUrl,
      roleLabel: restaurantUser?.role.name.toUpperCase(),
      restaurantKeys: restaurantUser?.restaurantKeys ?? const [],
      hasRestaurantProfile: restaurantUser != null,
    );
  }

  @override
  List<Object?> get props => [
        displayName,
        email,
        photoUrl,
        roleLabel,
        restaurantKeys,
        hasRestaurantProfile,
      ];
}
