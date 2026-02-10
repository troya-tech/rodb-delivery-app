import 'package:equatable/equatable.dart';
import 'customer.dart';

class Order extends Equatable {
  final String id;
  final String shortOrderId;
  final String storeId;
  final String storeName;
  final double totalOrderPrice;
  final String integrationOrderId;
  final DateTime receivedAt;
  final Customer customer;

  const Order({
    required this.id,
    required this.shortOrderId,
    required this.storeId,
    required this.storeName,
    required this.totalOrderPrice,
    required this.integrationOrderId,
    required this.receivedAt,
    required this.customer,
  });

  factory Order.fromMap(String id, Map<Object?, Object?> map) {
    final customerMap = map['customer'] as Map<Object?, Object?>?;
    
    return Order(
      id: id,
      shortOrderId: map['shortOrderId'] as String? ?? '000',
      storeId: map['storeId']?.toString() ?? '',
      storeName: map['storeName'] as String? ?? '',
      totalOrderPrice: (map['totalOrderPrice'] as num?)?.toDouble() ?? 0.0,
      integrationOrderId: map['integrationOrderId'] as String? ?? '',
      receivedAt: map['receivedAt'] != null 
          ? DateTime.parse(map['receivedAt'] as String)
          : DateTime.now(),
      customer: customerMap != null 
          ? Customer.fromMap(customerMap)
          : const Customer(firstName: 'Unknown', lastName: 'Customer'),
    );
  }

  @override
  List<Object?> get props => [
        id,
        shortOrderId,
        storeId,
        storeName,
        totalOrderPrice,
        integrationOrderId,
        receivedAt,
        customer,
      ];
}
