import 'package:flutter/material.dart';
import '../../../features/order-feature/domain/order.dart';

class OrderDetailsPage extends StatelessWidget {
  final Order order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.orderCardNumber}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Store Information'),
            ListTile(
              title: Text(order.storeName),
              subtitle: Text('ID: ${order.id}'),
              leading: const Icon(Icons.store),
            ),
            const Divider(),
            
            _buildSectionTitle(context, 'Customer Details'),
            ListTile(
              title: Text('${order.customer.firstName} ${order.customer.lastName}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phone: ${order.customer.phone}'),
                  Text('Email: ${order.customer.email}'),
                  Text('Address: ${order.customer.address}'),
                  if (order.customer.addressDescription != null)
                    Text('Note: ${order.customer.addressDescription}'),
                ],
              ),
              leading: const Icon(Icons.person),
            ),
            const Divider(),

            _buildSectionTitle(context, 'Order Items'),
            ...order.orderItems.map((item) => ListTile(
              title: Text(item.orderItemName),
              subtitle: Text(item.orderItemDescription),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('x${item.orderItemCount}'),
                  Text('${item.orderItemPrice}'),
                ],
              ),
            )),
            const Divider(),

            _buildSectionTitle(context, 'Payment & Total'),
            ListTile(
              title: Text('Payment Type: ${order.orderPayment.paymentType}'),
              subtitle: order.orderPayment.ticketType != null 
                  ? Text('Ticket: ${order.orderPayment.ticketType}')
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

            _buildSectionTitle(context, 'Delivery Info'),
            ListTile(
              title: Text('Address: ${order.delivery.address}'),
              subtitle: Text('Note: ${order.delivery.addressNote}'),
              leading: const Icon(Icons.delivery_dining),
            ),
            const Divider(),

            _buildSectionTitle(context, 'Metadata'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Platform: ${order.meta.platform}'),
                  Text('Created: ${order.meta.creationDate}'),
                  Text('Integration ID: ${order.integrationOrderId}'),
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
