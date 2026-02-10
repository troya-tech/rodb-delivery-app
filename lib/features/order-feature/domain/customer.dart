import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String address;
  final String? addressDescription;
  final double? latitude;
  final double? longitude;

  const Customer({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.address,
    this.addressDescription,
    this.latitude,
    this.longitude,
  });

  factory Customer.fromMap(Map<Object?, Object?> map) {
    return Customer(
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      address: map['address'] as String? ?? '',
      addressDescription: map['addressDescription'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'address': address,
      if (addressDescription != null) 'addressDescription': addressDescription,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        phone,
        email,
        address,
        addressDescription,
        latitude,
        longitude,
      ];
}

