import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rodb_delivery_app/features/map-feature/application/map_providers.dart';
import 'package:rodb_delivery_app/features/map-feature/domain/address.dart';
import 'package:rodb_delivery_app/features/order-feature/domain/order.dart';

import 'order_details_page_view_model.dart';

/// The facade state for the Order Details Page.
sealed class OrderDetailsPageState {
  const OrderDetailsPageState();
}

class OrderDetailsPageLoaded extends OrderDetailsPageState {
  final OrderDetailsPageViewModel viewModel;
  const OrderDetailsPageLoaded(this.viewModel);
}

/// Facade for the Order Details Page.
///
/// Converts a domain [Order] into a display-ready [OrderDetailsPageViewModel].
/// In the future, this could be expanded to watch for real-time updates to
/// the specific order by ID.
final orderDetailsPageFacadeProvider =
    Provider.family<OrderDetailsPageState, Order>((ref, order) {
  // Map domain to view model
  final viewModel = OrderDetailsPageViewModel.fromDomain(order);
  return OrderDetailsPageLoaded(viewModel);
});

// ──────────────────────────────────────────────────────────────────────────────
// Actions
// ──────────────────────────────────────────────────────────────────────────────

/// Opens the customer's location in the device's map application.
Future<void> orderDetailsPageOpenMaps(
  WidgetRef ref,
  OrderDetailsPageViewModel viewModel,
) async {
  final mapService = ref.read(mapServiceProvider);

  final orderAddress = Address(
    address: viewModel.deliveryAddress,
    addressDescription: viewModel.deliveryNote,
    latitude: viewModel.latitude,
    longitude: viewModel.longitude,
  );

  await mapService.launchMapForAddress(orderAddress);
}
