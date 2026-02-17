import 'package:firebase_database/firebase_database.dart';
import '../../../../utils/app_logger.dart';
import '../domain/delivery.dart';
import '../domain/delivery_repository.dart';

/// Firebase Realtime Database implementation of [DeliveryRepository].
///
/// Reads from and writes to the `/deliveries` node.
class FirebaseDeliveryRepository implements DeliveryRepository {
  // Singleton pattern
  const FirebaseDeliveryRepository._();
  static const FirebaseDeliveryRepository instance = FirebaseDeliveryRepository._();
  factory FirebaseDeliveryRepository() => instance;

  static final _logger = AppLogger('FirebaseDeliveryRepository');

  DatabaseReference get _dbRef => FirebaseDatabase.instance.ref('deliveries');

  @override
  Future<Delivery?> getDeliveryById(String id) async {
    final context = _logger.createContext();
    _logger.info('Getting delivery by ID: $id', context);

    try {
      final snapshot = await _dbRef.child(id).get();
      if (!snapshot.exists) return null;

      final data = snapshot.value;
      if (data is Map) {
        return Delivery.fromMap(id, data);
      }
      return null;
    } catch (e) {
      _logger.error('Failed to get delivery', e, null, context);
      return null;
    }
  }

  @override
  Future<Delivery?> getDeliveryByOrderId(String orderId) async {
    final context = _logger.createContext();
    _logger.info('Getting delivery by order ID: $orderId', context);

    try {
      // Query by orderId
      // Note: This requires an index on 'orderId' in Firebase rules for efficiency
      final snapshot = await _dbRef.orderByChild('orderId').equalTo(orderId).get();
      
      if (!snapshot.exists) return null;

      final value = snapshot.value;
      if (value is Map && value.isNotEmpty) {
        // Assuming unique orderId per delivery, return the first match
        final entry = value.entries.first;
        final key = entry.key as String;
        final data = entry.value as Map<Object?, Object?>;
        return Delivery.fromMap(key, data);
      }
      return null;
    } catch (e) {
      _logger.error('Failed to get delivery by order ID', e, null, context);
      return null;
    }
  }

  @override
  Future<void> saveDelivery(Delivery delivery) async {
    final context = _logger.createContext();
    _logger.info('Saving delivery: ${delivery.id}', context);

    try {
      await _dbRef.child(delivery.id).set(delivery.toMap());
      _logger.success('Delivery saved successfully', context);
    } catch (e) {
      _logger.error('Failed to save delivery', e, null, context);
      rethrow;
    }
  }

  @override
  Stream<Delivery?> watchDelivery(String id) {
    _logger.info('Watching delivery: $id');
    return _dbRef.child(id).onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return null;

      if (data is Map) {
        return Delivery.fromMap(id, data);
      }
      return null;
    });
  }
}
