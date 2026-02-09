import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String firstName;
  final String lastName;

  const Customer({
    required this.firstName,
    required this.lastName,
  });

  @override
  List<Object?> get props => [firstName, lastName];
}
