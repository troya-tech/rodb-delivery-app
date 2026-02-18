import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:rodb_delivery_app/features/order-feature/domain/order.dart';

class PerformancePageViewModel extends Equatable {
  final int totalDeliveries;
  final String totalEarnings;
  final String shiftLabel;
  final bool canGoForward;

  const PerformancePageViewModel({
    required this.totalDeliveries,
    required this.totalEarnings,
    required this.shiftLabel,
    required this.canGoForward,
  });

  factory PerformancePageViewModel.fromOrders(
    List<Order> orders, {
    required DateTime shiftStart,
    required DateTime shiftEnd,
    required bool canGoForward,
  }) {
    final totalEarningsValue = orders.length * 50.0;
    final currencySymbol =
        orders.isNotEmpty ? orders.first.currency.symbol : '₺';

    final dateFmt = DateFormat('dd MMM HH:mm');
    final shiftLabel = '${dateFmt.format(shiftStart)} → ${dateFmt.format(shiftEnd)}';

    return PerformancePageViewModel(
      totalDeliveries: orders.length,
      totalEarnings: '${totalEarningsValue.toStringAsFixed(2)} $currencySymbol',
      shiftLabel: shiftLabel,
      canGoForward: canGoForward,
    );
  }

  @override
  List<Object?> get props => [
        totalDeliveries,
        totalEarnings,
        shiftLabel,
        canGoForward,
      ];
}
