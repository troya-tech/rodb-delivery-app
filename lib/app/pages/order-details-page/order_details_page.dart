import 'package:flutter/material.dart';
import '../../../features/order-feature/domain/order.dart';

import 'package:rodb_delivery_app/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'order_details_page.facade.dart';
import 'order_details_page_view_model.dart';

class OrderDetailsPage extends ConsumerWidget {
  final Order order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderDetailsPageFacadeProvider(order));

    return Scaffold(
      appBar: AppBar(
        title: state is OrderDetailsPageLoaded
            ? Text(AppLocalizations.of(context)!.orderNumber(state.viewModel.orderNumberLabel))
            : Text(AppLocalizations.of(context)!.orderNumber(order.orderCardNumber)),
      ),
      body: switch (state) {
        OrderDetailsPageLoaded(:final viewModel) => SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context, AppLocalizations.of(context)!.customerDetails),
                ListTile(
                  title: Text(viewModel.customerFullName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${AppLocalizations.of(context)!.phone(viewModel.customerPhone)}'),
                      Text('${AppLocalizations.of(context)!.email(viewModel.customerEmail)}'),
                    ],
                  ),
                  leading: const Icon(Icons.person),
                ),
                const Divider(),


                _buildSectionTitle(context, AppLocalizations.of(context)!.paymentAndTotal),
                ListTile(
                  title: Text(AppLocalizations.of(context)!.paymentType(viewModel.paymentType)),
                  subtitle: viewModel.ticketType != null 
                      ? Text(AppLocalizations.of(context)!.ticketType(viewModel.ticketType!))
                      : null,
                  trailing: Text(
                    '${viewModel.totalPrice} ${viewModel.currencySymbol}',
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
                  title: Text(AppLocalizations.of(context)!.address(viewModel.deliveryAddress)),
                  subtitle: Text(AppLocalizations.of(context)!.note(viewModel.deliveryNote)),
                  leading: const Icon(Icons.delivery_dining),
                  trailing: IconButton(
                    icon: const Icon(Icons.map, color: Colors.blue),
                    onPressed: () => orderDetailsPageOpenMaps(ref, viewModel),
                    tooltip: AppLocalizations.of(context)!.openInMaps,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '📍 ${viewModel.latitude.toStringAsFixed(6)}, ${viewModel.longitude.toStringAsFixed(6)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => orderDetailsPageOpenMaps(ref, viewModel),
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
                      Text(AppLocalizations.of(context)!.platform(viewModel.platform)),
                      Text(AppLocalizations.of(context)!.created(viewModel.creationDate)),
                      Text(AppLocalizations.of(context)!.integrationId(viewModel.integrationOrderId)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Mark as Delivered
                if (viewModel.isDelivered)
                  Center(
                    child: Chip(
                      avatar: const Icon(Icons.check_circle, color: Colors.white),
                      label: Text(
                        AppLocalizations.of(context)!.delivered,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showMarkAsDeliveredDialog(context, ref, viewModel),
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(AppLocalizations.of(context)!.markAsDelivered),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
      },
    );
  }

  void _showMarkAsDeliveredDialog(
    BuildContext context,
    WidgetRef ref,
    OrderDetailsPageViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.markAsDelivered),
        content: Text(AppLocalizations.of(context)!.markAsDeliveredConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              orderDetailsPageMarkAsDelivered(ref, viewModel);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
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

