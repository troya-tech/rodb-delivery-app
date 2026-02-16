class Address {
  final String address;
  final String? addressDescription;
  final double latitude;
  final double longitude;

  const Address({
    required this.address,
    this.addressDescription,
    required this.latitude,
    required this.longitude,
  });
}
