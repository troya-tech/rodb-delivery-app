import 'package:equatable/equatable.dart';
import 'customer.dart';
import 'order_payment.dart';
import 'order_item.dart';
import 'order_delivery.dart';
import 'order_meta.dart';

class Order extends Equatable {
  final String id;
  final String storeName;
  final Customer customer;
  final OrderPayment orderPayment;
  final List<OrderItem> orderItems;
  final OrderDelivery delivery;
  final OrderMeta meta;
  final double totalOrderPrice;
  final OrderCurrency currency;
  final String integrationOrderId;
  final String orderCardNumber;

  const Order({
    required this.id,
    required this.storeName,
    required this.customer,
    required this.orderPayment,
    required this.orderItems,
    required this.delivery,
    required this.meta,
    required this.totalOrderPrice,
    required this.currency,
    required this.integrationOrderId,
    required this.orderCardNumber,
  });

  factory Order.fromMap(String id, Map<Object?, Object?> map) {
    final customerMap = map['customer'] as Map<Object?, Object?>?;
    final paymentMap = map['orderPayment'] as Map<Object?, Object?>?;
    final deliveryMap = map['delivery'] as Map<Object?, Object?>?;
    final metaMap = map['meta'] as Map<Object?, Object?>?;
    final currencyMap = map['currency'] as Map<Object?, Object?>?;
    final itemsList = map['orderItems'] as List<Object?>? ?? [];

    return Order(
      id: id,
      storeName: map['storeName'] as String? ?? '',
      customer: customerMap != null 
          ? Customer.fromMap(customerMap)
          : throw ArgumentError('Customer is required'),
      orderPayment: paymentMap != null
          ? OrderPayment.fromMap(paymentMap)
          : throw ArgumentError('OrderPayment is required'),
      orderItems: itemsList
          .map((item) => OrderItem.fromMap(item as Map<Object?, Object?>))
          .toList(),
      delivery: deliveryMap != null
          ? OrderDelivery.fromMap(deliveryMap)
          : throw ArgumentError('Delivery is required'),
      meta: metaMap != null
          ? OrderMeta.fromMap(metaMap)
          : throw ArgumentError('OrderMeta is required'),
      totalOrderPrice: (map['totalOrderPrice'] as num?)?.toDouble() ?? 0.0,
      currency: currencyMap != null
          ? OrderCurrency.fromMap(currencyMap)
          : const OrderCurrency(symbol: '₺', code: 'TRY'),
      integrationOrderId: map['integrationOrderId'] as String? ?? '',
      orderCardNumber: map['orderCardNumber'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [
        id,
        storeName,
        customer,
        orderPayment,
        orderItems,
        delivery,
        meta,
        totalOrderPrice,
        currency,
        integrationOrderId,
        orderCardNumber,
      ];
}

class OrderCurrency extends Equatable {
  final String symbol;
  final String code;

  const OrderCurrency({
    required this.symbol,
    required this.code,
  });

  factory OrderCurrency.fromMap(Map<Object?, Object?> map) {
    return OrderCurrency(
      symbol: map['symbol'] as String? ?? '₺',
      code: map['code'] as String? ?? 'TRY',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'code': code,
    };
  }

  @override
  List<Object?> get props => [symbol, code];
}

