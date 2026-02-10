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
    };
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
      ];
}
