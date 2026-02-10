import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../features/order-feature/domain/order.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OrderDetailsPage extends StatelessWidget {
  final Order order;

  const OrderDetailsPage({super.key, required this.order});

  Future<void> _openMaps() async {
    final address = order.delivery.address;
    final encodedAddress = Uri.encodeComponent(address);
    
    // Google Maps Search URL using address
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');
    
    // Apple Maps Search URL using address
    final appleMapsUrl = Uri.parse('https://maps.apple.com/?q=$encodedAddress');

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to coordinates if address search fails (unlikely)
        final lat = order.delivery.latitude;
        final lng = order.delivery.longitude;
        final geoUrl = Uri.parse('geo:$lat,$lng?q=$encodedAddress');
        
        if (await canLaunchUrl(geoUrl)) {
          await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
        } else {
          throw 'No maps application found';
        }
      }
    } catch (e) {
      debugPrint('Error launching maps: $e');
      // If all else fails, try to launch the browser version
      await launchUrl(googleMapsUrl, mode: LaunchMode.platformDefault);
    }
  }



  @override
  Widget build(BuildContext context) {
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
                onPressed: _openMaps,
                tooltip: AppLocalizations.of(context)!.openInMaps,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openMaps,
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

