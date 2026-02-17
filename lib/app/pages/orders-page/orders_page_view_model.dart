import 'package:equatable/equatable.dart';
import 'package:rodb_delivery_app/features/order-feature/domain/order.dart';

/// A single display-ready row for the orders list.
class OrderSummary extends Equatable {
  final String id;
  final String orderCardNumber;
  final String customerFullName;
  final String totalPrice;
  final String platform;
  final Order domainOrder;

  const OrderSummary({
    required this.id,
    required this.orderCardNumber,
    required this.customerFullName,
    required this.totalPrice,
    required this.platform,
    required this.domainOrder,
  });

  @override
  List<Object?> get props => [
        id,
        orderCardNumber,
        customerFullName,
        totalPrice,
        platform,
        domainOrder,
      ];
}

/// View model entity for the Orders Page.
///
/// A flat, display-ready data object produced by a facade (or directly by the
/// widget for now). The widget consumes this directly — no nested domain
/// model unwrapping required.
class OrdersPageViewModel extends Equatable {
  final List<OrderSummary> orders;
  final bool isEmpty;

  const OrdersPageViewModel({
    required this.orders,
    required this.isEmpty,
  });

  /// Factory that maps a list of domain [Order] objects into the view model.
  factory OrdersPageViewModel.fromDomain({
    required List<Order> orders,
  }) {
    final summaries = orders.map((order) {
      final customerName =
          '${order.customer.firstName} ${order.customer.lastName}'.trim();

      return OrderSummary(
        id: order.id,
        orderCardNumber: order.orderCardNumber,
        customerFullName:
            customerName.isNotEmpty ? customerName : 'Unknown Customer',
        totalPrice:
            '${order.totalOrderPrice.toStringAsFixed(2)} ${order.currency.symbol}',
        platform: order.meta.platform,
        domainOrder: order,
      );
    }).toList();

    return OrdersPageViewModel(
      orders: summaries,
      isEmpty: summaries.isEmpty,
    );
  }

  @override
  List<Object?> get props => [orders, isEmpty];
}
