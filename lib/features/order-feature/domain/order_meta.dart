import 'package:equatable/equatable.dart';

class OrderMeta extends Equatable {
  final String integrationOrderId;
  final String integrationType;
  final String platform;
  final String creationDate;
  final String clickingTime;
  final String warmthType;
  final int cookingTime;
  final dynamic status;
  final String orderCardNumber;
  final bool isDelivered;

  const OrderMeta({
    required this.integrationOrderId,
    required this.integrationType,
    required this.platform,
    required this.creationDate,
    required this.clickingTime,
    required this.warmthType,
    required this.cookingTime,
    required this.status,
    required this.orderCardNumber,
    this.isDelivered = false,
  });

  factory OrderMeta.fromMap(Map<Object?, Object?> map) {
    return OrderMeta(
      integrationOrderId: map['integrationOrderId'] as String? ?? '',
      integrationType: map['integrationType'] as String? ?? '',
      platform: map['platform'] as String? ?? '',
      creationDate: map['creationDate'] as String? ?? '',
      clickingTime: map['clickingTime'] as String? ?? '',
      warmthType: map['warmthType'] as String? ?? '',
      cookingTime: (map['cookingTime'] as num?)?.toInt() ?? 0,
      status: map['status'],
      orderCardNumber: map['orderCardNumber'] as String? ?? '',
      isDelivered: map['isDelivered'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'integrationOrderId': integrationOrderId,
      'integrationType': integrationType,
      'platform': platform,
      'creationDate': creationDate,
      'clickingTime': clickingTime,
      'warmthType': warmthType,
      'cookingTime': cookingTime,
      'status': status,
      'orderCardNumber': orderCardNumber,
      'isDelivered': isDelivered,
    };
  }

  OrderMeta copyWith({
    String? integrationOrderId,
    String? integrationType,
    String? platform,
    String? creationDate,
    String? clickingTime,
    String? warmthType,
    int? cookingTime,
    dynamic status,
    String? orderCardNumber,
    bool? isDelivered,
  }) {
    return OrderMeta(
      integrationOrderId: integrationOrderId ?? this.integrationOrderId,
      integrationType: integrationType ?? this.integrationType,
      platform: platform ?? this.platform,
      creationDate: creationDate ?? this.creationDate,
      clickingTime: clickingTime ?? this.clickingTime,
      warmthType: warmthType ?? this.warmthType,
      cookingTime: cookingTime ?? this.cookingTime,
      status: status ?? this.status,
      orderCardNumber: orderCardNumber ?? this.orderCardNumber,
      isDelivered: isDelivered ?? this.isDelivered,
    );
  }

  @override
  List<Object?> get props => [
        integrationOrderId,
        integrationType,
        platform,
        creationDate,
        clickingTime,
        warmthType,
        cookingTime,
        status,
        orderCardNumber,
        isDelivered,
      ];
}
