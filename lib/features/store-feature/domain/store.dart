import 'package:equatable/equatable.dart';

import 'currency.dart';

/// Domain entity representing a store (restaurant/merchant location).
class Store extends Equatable {
  final String id;
  final String name;
  final String address;
  final int addressId;
  final String city;
  final Currency currency;
  final int defaultCookingTime;
  final bool isActive;
  final double locationLat;
  final double locationLng;
  final String organizationalType;
  final String ownerId;
  final int updatedAt;

  const Store({
    required this.id,
    required this.name,
    required this.address,
    required this.addressId,
    required this.city,
    required this.currency,
    required this.defaultCookingTime,
    required this.isActive,
    required this.locationLat,
    required this.locationLng,
    required this.organizationalType,
    required this.ownerId,
    required this.updatedAt,
  });

  factory Store.fromMap(String id, Map<dynamic, dynamic> map) {
    return Store(
      id: id,
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      addressId: (map['addressId'] as num?)?.toInt() ?? 0,
      city: map['city'] as String? ?? '',
      currency: map['currency'] is Map
          ? Currency.fromMap(map['currency'] as Map<dynamic, dynamic>)
          : Currency.defaultCurrency,
      defaultCookingTime: (map['defaultCookingTime'] as num?)?.toInt() ?? 20,
      isActive: map['isActive'] as bool? ?? false,
      locationLat: (map['locationLat'] as num?)?.toDouble() ?? 0.0,
      locationLng: (map['locationLng'] as num?)?.toDouble() ?? 0.0,
      organizationalType: map['organizationalType'] as String? ?? '',
      ownerId: map['ownerId'] as String? ?? '',
      updatedAt: (map['updatedAt'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'addressId': addressId,
      'city': city,
      'currency': currency.toMap(),
      'defaultCookingTime': defaultCookingTime,
      'isActive': isActive,
      'locationLat': locationLat,
      'locationLng': locationLng,
      'organizationalType': organizationalType,
      'ownerId': ownerId,
      'updatedAt': updatedAt,
    };
  }

  Store copyWith({
    String? id,
    String? name,
    String? address,
    int? addressId,
    String? city,
    Currency? currency,
    int? defaultCookingTime,
    bool? isActive,
    double? locationLat,
    double? locationLng,
    String? organizationalType,
    String? ownerId,
    int? updatedAt,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      addressId: addressId ?? this.addressId,
      city: city ?? this.city,
      currency: currency ?? this.currency,
      defaultCookingTime: defaultCookingTime ?? this.defaultCookingTime,
      isActive: isActive ?? this.isActive,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      organizationalType: organizationalType ?? this.organizationalType,
      ownerId: ownerId ?? this.ownerId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        addressId,
        city,
        currency,
        defaultCookingTime,
        isActive,
        locationLat,
        locationLng,
        organizationalType,
        ownerId,
        updatedAt,
      ];
}
