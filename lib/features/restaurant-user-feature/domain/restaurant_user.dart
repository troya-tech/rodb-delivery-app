import 'package:equatable/equatable.dart';

enum UserRole {
  owner,
  admin,
  staff,
  unknown;

  static UserRole fromString(String role) {
    switch (role.toUpperCase()) {
      case 'OWNER':
        return UserRole.owner;
      case 'ADMIN':
        return UserRole.admin;
      case 'STAFF':
        return UserRole.staff;
      default:
        return UserRole.unknown;
    }
  }

  String toJson() => name.toUpperCase();
}

class RestaurantUser extends Equatable {
  final String uid;
  final String email;
  final List<String> restaurantKeys;
  final UserRole role;

  const RestaurantUser({
    required this.uid,
    required this.email,
    required this.restaurantKeys,
    required this.role,
  });

  @override
  List<Object?> get props => [uid, email, restaurantKeys, role];

  RestaurantUser copyWith({
    String? uid,
    String? email,
    List<String>? restaurantKeys,
    UserRole? role,
  }) {
    return RestaurantUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      restaurantKeys: restaurantKeys ?? this.restaurantKeys,
      role: role ?? this.role,
    );
  }
}
