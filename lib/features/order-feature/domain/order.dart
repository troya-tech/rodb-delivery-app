import 'package:equatable/equatable.dart';
import 'customer.dart';

class Order extends Equatable {
  final String shortOrderId;
  final Customer customer;

  const Order({
    required this.shortOrderId,
    required this.customer,
  });

  @override
  List<Object?> get props => [shortOrderId, customer];
}
