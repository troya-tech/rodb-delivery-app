import 'package:equatable/equatable.dart';

class OrderDelivery extends Equatable {
  final String address;
  final String addressNote;
  final double latitude;
  final double longitude;
  final double? distance;
  final double? duration;

  const OrderDelivery({
    required this.address,
    required this.addressNote,
    required this.latitude,
    required this.longitude,
    this.distance,
    this.duration,
  });

  factory OrderDelivery.fromMap(Map<Object?, Object?> map) {
    return OrderDelivery(
      address: map['address'] as String? ?? '',
      addressNote: map['addressNote'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      distance: (map['distance'] as num?)?.toDouble(),
      duration: (map['duration'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'addressNote': addressNote,
      'latitude': latitude,
      'longitude': longitude,
      if (distance != null) 'distance': distance,
      if (duration != null) 'duration': duration,
    };
  }

  @override
  List<Object?> get props => [
        address,
        addressNote,
        latitude,
        longitude,
        distance,
        duration,
      ];
}
