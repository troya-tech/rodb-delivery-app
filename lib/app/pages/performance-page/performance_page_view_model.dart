import 'package:equatable/equatable.dart';
import 'package:rodb_delivery_app/features/order-feature/domain/order.dart';

class PerformancePageViewModel extends Equatable {
  final int totalDeliveries;
  final String totalEarnings;

  const PerformancePageViewModel({
    required this.totalDeliveries,
    required this.totalEarnings,
  });

  factory PerformancePageViewModel.fromOrders(List<Order> orders) {
    if (orders.isEmpty) {
      return const PerformancePageViewModel(
        totalDeliveries: 0,
        totalEarnings: '0.00 ₺',
      );
    }
    
    final totalEarningsValue = orders.length * 50.0;
    
    final currencySymbol = orders.first.currency.symbol; // Assuming same currency

    return PerformancePageViewModel(
      totalDeliveries: orders.length,
      totalEarnings: '${totalEarningsValue.toStringAsFixed(2)} $currencySymbol',
    );
  }

  @override
  List<Object?> get props => [totalDeliveries, totalEarnings];
}
