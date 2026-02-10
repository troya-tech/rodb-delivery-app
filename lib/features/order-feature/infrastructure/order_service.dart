import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../domain/order.dart';
import '../domain/order_repository.dart';
import '../../../../utils/app_logger.dart';

class OrderService implements OrderRepository {
  // Singleton pattern
  const OrderService._();
  static const OrderService instance = OrderService._();
  factory OrderService() => instance;

  static final _logger = AppLogger('OrderService');
  static final _db = FirebaseDatabase.instance;

  @override
  Future<List<Order>> getOrders() async {
    _logger.info('Getting all orders');
    // For now, redirecting to a specific store for testing if needed
    // or just returning empty if no store context.
    return [];
  }

  @override
  Future<Order?> getOrderById(String id) async {
    _logger.info('Getting order by id: $id');
    return null;
  }

  @override
  Future<void> saveOrder(Order order) async {
    _logger.info('Saving order: ${order.orderCardNumber}');
  }

  @override
  Stream<List<Order>> watchOrders() {
    _logger.info('Watching orders (generic)');
    return const Stream.empty();
  }

  /// Watch orders for specific store IDs
  Stream<List<Order>> watchOrdersForStores(List<String> storeIds) {
    if (storeIds.isEmpty) {
      _logger.warning('No store IDs provided to watchOrdersForStores');
      return Stream.value([]);
    }

    _logger.info('Watching orders for stores: $storeIds');

    // Create a controller to merge multiple store streams
    final controller = StreamController<List<Order>>();
    final Map<String, List<Order>> storeOrdersMap = {};
    final List<StreamSubscription> subscriptions = [];

    for (final storeId in storeIds) {
      final ref = _db.ref('orders/$storeId');
      
      final subscription = ref.onValue.listen((event) {
        final data = event.snapshot.value as Map<Object?, Object?>?;
        
        if (data == null) {
          storeOrdersMap[storeId] = [];
        } else {
          final List<Order> orders = [];
          data.forEach((key, value) {
            if (value is Map<Object?, Object?>) {
              try {
                orders.add(Order.fromMap(key.toString(), value));
              } catch (e) {
                _logger.error('Error parsing order $key for store $storeId', e);
              }
            }
          });
          
          // Sort orders by date descending
          orders.sort((a, b) => b.meta.creationDate.compareTo(a.meta.creationDate));
          storeOrdersMap[storeId] = orders;
        }

        // Emit merged list
        final mergedOrders = storeOrdersMap.values.expand((x) => x).toList();
        mergedOrders.sort((a, b) => b.meta.creationDate.compareTo(a.meta.creationDate));
        controller.add(mergedOrders);
      }, onError: (error) {
        _logger.error('Error watching store $storeId', error);
      });
      
      subscriptions.add(subscription);
    }

    controller.onCancel = () {
      for (final sub in subscriptions) {
        sub.cancel();
      }
    };

    return controller.stream;
  }
}
