import 'package:equatable/equatable.dart';

/// Represents a delivery assignment and status for an order.
///
/// This entity tracks the fulfillment lifecycle of an order, including
/// driver assignment, status updates, and tracking information.
class Delivery extends Equatable {
  /// Unique ID for this delivery record.
  final String id;

  /// The ID of the order being delivered.
  final String orderId;

  /// Current status of the delivery (e.g., 'PENDING', 'ASSIGNED', 'PICKED_UP', 'DELIVERED').
  final String status;

  /// ID of the assigned driver/courier, if any.
  final String? driverId;

  /// Name of the assigned driver/courier, if any.
  final String? driverName;

  /// External tracking URL, if available.
  final String? trackingUrl;

  /// Timestamp when this delivery record was created.
  final DateTime createdAt;

  const Delivery({
    required this.id,
    required this.orderId,
    required this.status,
    required this.createdAt,
    this.driverId,
    this.driverName,
    this.trackingUrl,
  });

  /// standard empty delivery
  static final empty = Delivery(
    id: '',
    orderId: '',
    status: 'PENDING',
    createdAt: DateTime.now(),
  );

  /// Creates a [Delivery] from a Map (e.g., from Firebase).
  factory Delivery.fromMap(String id, Map<Object?, Object?> map) {
    return Delivery(
      id: id,
      orderId: map['orderId'] as String? ?? '',
      status: map['status'] as String? ?? 'PENDING',
      driverId: map['driverId'] as String?,
      driverName: map['driverName'] as String?,
      trackingUrl: map['trackingUrl'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Converts this [Delivery] to a Map for storage.
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      if (driverId != null) 'driverId': driverId,
      if (driverName != null) 'driverName': driverName,
      if (trackingUrl != null) 'trackingUrl': trackingUrl,
    };
  }
  
  Delivery copyWith({
    String? id,
    String? orderId,
    String? status,
    String? driverId,
    String? driverName,
    String? trackingUrl,
    DateTime? createdAt,
  }) {
    return Delivery(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      status: status ?? this.status,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      trackingUrl: trackingUrl ?? this.trackingUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        status,
        driverId,
        driverName,
        trackingUrl,
        createdAt,
      ];
}
