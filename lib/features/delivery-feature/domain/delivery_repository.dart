import 'delivery.dart';

/// Repository for managing [Delivery] entities.
abstract class DeliveryRepository {
  /// Fetches a [Delivery] by its ID.
  Future<Delivery?> getDeliveryById(String id);

  /// Fetches a [Delivery] by its associated Order ID.
  Future<Delivery?> getDeliveryByOrderId(String orderId);

  /// Saves or updates a [Delivery].
  Future<void> saveDelivery(Delivery delivery);

  /// Watches a [Delivery] by its ID for real-time updates.
  Stream<Delivery?> watchDelivery(String id);
}
