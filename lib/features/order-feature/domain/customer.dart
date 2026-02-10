import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String firstName;
  final String lastName;
  final String? phone;

  const Customer({
    required this.firstName,
    required this.lastName,
    this.phone,
  });

  factory Customer.fromMap(Map<Object?, Object?> map) {
    return Customer(
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      phone: map['phone'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      if (phone != null) 'phone': phone,
    };
  }

  @override
  List<Object?> get props => [firstName, lastName, phone];
}
