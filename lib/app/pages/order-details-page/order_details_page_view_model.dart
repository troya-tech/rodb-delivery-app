import 'package:equatable/equatable.dart';
import 'package:rodb_delivery_app/features/order-feature/domain/order.dart';

/// A summary of a single item in the order.
class OrderItemSummary extends Equatable {
  final String name;
  final String description;
  final int count;
  final String price;

  const OrderItemSummary({
    required this.name,
    required this.description,
    required this.count,
    required this.price,
  });

  @override
  List<Object?> get props => [name, description, count, price];
}

/// A flat, display-ready data entity for the Order Details Page.
class OrderDetailsPageViewModel extends Equatable {
  // Header / Summary
  final String orderNumberLabel;
  final String totalPrice;
  final String currencySymbol;

  // Store Info
  final String storeName;

  // Customer Info
  final String customerFullName;
  final String customerPhone;
  final String customerEmail;
  final String customerAddress;
  final String? customerAddressNote;

  // Items
  final List<OrderItemSummary> items;

  // Payment Info
  final String paymentType;
  final String? ticketType;

  // Delivery Info
  final String deliveryAddress;
  final String deliveryNote;
  final double latitude;
  final double longitude;

  // Meta Data
  final String platform;
  final String creationDate;
  final String integrationOrderId;

  // Domain access (optional but useful for actions)
  final Order domainOrder;

  // Delivery status
  final bool isDelivered;

  const OrderDetailsPageViewModel({
    required this.orderNumberLabel,
    required this.totalPrice,
    required this.currencySymbol,
    required this.storeName,
    required this.customerFullName,
    required this.customerPhone,
    required this.customerEmail,
    required this.customerAddress,
    this.customerAddressNote,
    required this.items,
    required this.paymentType,
    this.ticketType,
    required this.deliveryAddress,
    required this.deliveryNote,
    required this.latitude,
    required this.longitude,
    required this.platform,
    required this.creationDate,
    required this.integrationOrderId,
    required this.domainOrder,
    required this.isDelivered,
  });

  /// Factory to map domain [Order] to this view model.
  factory OrderDetailsPageViewModel.fromDomain(Order order) {
    final items = order.orderItems.map((item) {
      return OrderItemSummary(
        name: item.orderItemName,
        description: item.orderItemDescription,
        count: item.orderItemCount,
        price: '${item.orderItemPrice} ${order.currency.symbol}',
      );
    }).toList();

    return OrderDetailsPageViewModel(
      orderNumberLabel: order.orderCardNumber,
      totalPrice: order.totalOrderPrice.toStringAsFixed(2),
      currencySymbol: order.currency.symbol,
      storeName: order.storeName,
      customerFullName: '${order.customer.firstName} ${order.customer.lastName}'.trim(),
      customerPhone: order.customer.phone,
      customerEmail: order.customer.email,
      customerAddress: order.customer.address,
      customerAddressNote: order.customer.addressDescription,
      items: items,
      paymentType: order.orderPayment.paymentType,
      ticketType: order.orderPayment.ticketType,
      deliveryAddress: '${order.customer.address} Çanakkale/Merkez',
      deliveryNote: order.customer.addressDescription ?? '',
      latitude: order.customer.latitude ?? order.delivery.latitude,
      longitude: order.customer.longitude ?? order.delivery.longitude,
      platform: order.meta.platform,
      creationDate: order.meta.creationDate,
      integrationOrderId: order.integrationOrderId,
      domainOrder: order,
      isDelivered: order.meta.isDelivered,
    );
  }


  @override
  List<Object?> get props => [
        orderNumberLabel,
        totalPrice,
        currencySymbol,
        storeName,
        customerFullName,
        customerPhone,
        customerEmail,
        customerAddress,
        customerAddressNote,
        items,
        paymentType,
        ticketType,
        deliveryAddress,
        deliveryNote,
        latitude,
        longitude,
        platform,
        creationDate,
        integrationOrderId,
        domainOrder,
        isDelivered,
      ];
}
