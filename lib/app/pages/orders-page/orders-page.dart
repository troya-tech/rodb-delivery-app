import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rodb_delivery_app/app/pages/orders-page/orders_page_view_model.dart';
import 'package:rodb_delivery_app/features/order-feature/application/order_providers.dart';
import 'package:rodb_delivery_app/app/routing/app_routes.dart';

import 'package:rodb_delivery_app/l10n/generated/app_localizations.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(activeOrdersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.profile);
            },
          ),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) {
          final viewModel = OrdersPageViewModel.fromDomain(orders: orders);
          if (viewModel.isEmpty) {
            return Center(
                child: Text(AppLocalizations.of(context)!.noOrdersFound));
          }
          return ListView.builder(
            itemCount: viewModel.orders.length,
            itemBuilder: (context, index) {
              final summary = viewModel.orders[index];
              return ListTile(
                title: Text(AppLocalizations.of(context)!
                    .orderNumber(summary.orderCardNumber)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(summary.customerFullName),
                    const SizedBox(height: 4),
                    _PaymentBadge(paymentType: summary.paymentType),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.orderDetails,
                    arguments: summary.domainOrder,
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  final String paymentType;

  const _PaymentBadge({required this.paymentType});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    // Normalize for comparison
    final typeLower = paymentType.toLowerCase();

    if (typeLower.contains('cash') || typeLower.contains('nakit')) {
      backgroundColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
      icon = Icons.payments_outlined;
    } else if (typeLower.contains('card') ||
        typeLower.contains('kart') ||
        typeLower.contains('kredi')) {
      backgroundColor = Colors.blue.shade100;
      textColor = Colors.blue.shade800;
      icon = Icons.credit_card;
    } else if (typeLower.contains('online')) {
      backgroundColor = Colors.orange.shade100;
      textColor = Colors.orange.shade800;
      icon = Icons.wifi;
    } else {
      backgroundColor = Colors.grey.shade200;
      textColor = Colors.grey.shade800;
      icon = Icons.payment;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            paymentType,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
