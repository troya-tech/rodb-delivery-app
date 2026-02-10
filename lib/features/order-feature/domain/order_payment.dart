import 'package:equatable/equatable.dart';

class OrderPayment extends Equatable {
  final String paymentType;
  final String? ticketType;
  final double price;
  final DateTime? date;

  const OrderPayment({
    required this.paymentType,
    this.ticketType,
    required this.price,
    this.date,
  });

  factory OrderPayment.fromMap(Map<Object?, Object?> map) {
    return OrderPayment(
      paymentType: map['paymentType'] as String? ?? '',
      ticketType: map['ticketType'] as String?,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] != null ? DateTime.parse(map['date'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentType': paymentType,
      if (ticketType != null) 'ticketType': ticketType,
      'price': price,
      if (date != null) 'date': date!.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [paymentType, ticketType, price, date];
}
