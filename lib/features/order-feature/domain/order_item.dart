import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  final String orderItemName;
  final String orderItemDescription;
  final int orderItemCount;
  final String orderItemPrice;

  const OrderItem({
    required this.orderItemName,
    required this.orderItemDescription,
    required this.orderItemCount,
    required this.orderItemPrice,
  });

  factory OrderItem.fromMap(Map<Object?, Object?> map) {
    return OrderItem(
      orderItemName: map['orderItemName'] as String? ?? '',
      orderItemDescription: map['orderItemDescription'] as String? ?? '',
      orderItemCount: (map['orderItemCount'] as num?)?.toInt() ?? 0,
      orderItemPrice: map['orderItemPrice']?.toString() ?? '0.0',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderItemName': orderItemName,
      'orderItemDescription': orderItemDescription,
      'orderItemCount': orderItemCount,
      'orderItemPrice': orderItemPrice,
    };
  }

  @override
  List<Object?> get props => [
        orderItemName,
        orderItemDescription,
        orderItemCount,
        orderItemPrice,
      ];
}
