import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../features/order-feature/domain/order.dart';
import '../../../features/map-feature/application/map_providers.dart';
import '../../../features/map-feature/domain/address.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderDetailsPage extends ConsumerWidget {
  final Order order;

  const OrderDetailsPage({super.key, required this.order});

  Future<void> _openMaps(WidgetRef ref) async {
    final mapService = ref.read(mapServiceProvider);
    
    final orderAddress = Address(
      address: order.delivery.address, 
      addressDescription: order.delivery.addressNote,
      latitude: order.delivery.latitude,
      longitude: order.delivery.longitude,
    );
    
    await mapService.launchMapForAddress(orderAddress);
  }



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.orderNumber(order.orderCardNumber)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildSectionTitle(context, 'Store Information'),
            // ListTile(
            //   title: Text(order.storeName),
            //   subtitle: Text('ID: ${order.id}'),
            //   leading: const Icon(Icons.store),
            // ),
            // const Divider(),
            
            // _buildSectionTitle(context, 'Customer Details'),
            // ListTile(
            //   title: Text('${order.customer.firstName} ${order.customer.lastName}'),
            //   subtitle: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text('Phone: ${order.customer.phone}'),
            //       Text('Email: ${order.customer.email}'),
            //       Text('Address: ${order.customer.address}'),
            //       if (order.customer.addressDescription != null)
            //         Text('Note: ${order.customer.addressDescription}'),
            //     ],
            //   ),
            //   leading: const Icon(Icons.person),
            // ),
            // const Divider(),

            // _buildSectionTitle(context, 'Order Items'),
            // ...order.orderItems.map((item) => ListTile(
            //   title: Text(item.orderItemName),
            //   subtitle: Text(item.orderItemDescription),
            //   trailing: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     crossAxisAlignment: CrossAxisAlignment.end,
            //     children: [
            //       Text('x${item.orderItemCount}'),
            //       Text('${item.orderItemPrice}'),
            //     ],
            //   ),
            // )),
            // const Divider(),

            _buildSectionTitle(context, AppLocalizations.of(context)!.paymentAndTotal),
            ListTile(
              title: Text(AppLocalizations.of(context)!.paymentType(order.orderPayment.paymentType)),
              subtitle: order.orderPayment.ticketType != null 
                  ? Text(AppLocalizations.of(context)!.ticketType(order.orderPayment.ticketType!))
                  : null,
              trailing: Text(
                '${order.totalOrderPrice} ${order.currency.symbol}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: const Icon(Icons.payment),
            ),
            const Divider(),

            _buildSectionTitle(context, AppLocalizations.of(context)!.deliveryInfo),
            ListTile(
              title: Text(AppLocalizations.of(context)!.address(order.delivery.address)),
              subtitle: Text(AppLocalizations.of(context)!.note(order.delivery.addressNote)),
              leading: const Icon(Icons.delivery_dining),
              trailing: IconButton(
                icon: const Icon(Icons.map, color: Colors.blue),
                onPressed: () => _openMaps(ref),
                tooltip: AppLocalizations.of(context)!.openInMaps,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openMaps(ref),
                  icon: const Icon(Icons.directions),
                  label: Text(AppLocalizations.of(context)!.getDirections),
                ),
              ),
            ),
            const Divider(),

            _buildSectionTitle(context, AppLocalizations.of(context)!.metaData),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.platform(order.meta.platform)),
                  Text(AppLocalizations.of(context)!.created(order.meta.creationDate)),
                  Text(AppLocalizations.of(context)!.integrationId(order.integrationOrderId)),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

