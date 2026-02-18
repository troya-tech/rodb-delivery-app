import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:rodb_delivery_app/features/order-feature/domain/order.dart';
import 'package:rodb_delivery_app/features/order-feature/application/order_providers.dart';
import 'package:rodb_delivery_app/features/restaurant-user-feature/application/restaurant_user_providers.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Shift configuration — customizable hours
// ═══════════════════════════════════════════════════════════════════════════

/// Represents a delivery shift window that can span midnight.
///
/// Example: startHour=18, endHour=3 → 18:00 Day1 to 03:00 Day2
class ShiftConfig extends Equatable {
  final int startHour;
  final int endHour;

  const ShiftConfig({this.startHour = 18, this.endHour = 3});

  @override
  List<Object?> get props => [startHour, endHour];
}

/// Provider for the driver-customizable shift hours.
final performanceShiftConfigProvider = StateProvider<ShiftConfig>(
  (ref) => const ShiftConfig(),
);

// ═══════════════════════════════════════════════════════════════════════════
// Shift anchor date — the "day" being viewed
// ═══════════════════════════════════════════════════════════════════════════

/// The anchor date for the current shift.
/// Default: today (date only, no time).
final performanceShiftDateProvider = StateProvider<DateTime>(
  (ref) => _today(),
);

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

// ═══════════════════════════════════════════════════════════════════════════
// Computed date range from shift config + anchor date
// ═══════════════════════════════════════════════════════════════════════════

/// Computed start/end DateTimes for the current shift.
///
/// If shift spans midnight (startHour > endHour), end is on the next day.
/// E.g. anchorDate=Feb 18, startHour=18, endHour=3 →
///   start: Feb 18 18:00 local
///   end:   Feb 19 03:00 local
final performanceDateRangeProvider =
    Provider<({DateTime start, DateTime end})>((ref) {
  final config = ref.watch(performanceShiftConfigProvider);
  final anchor = ref.watch(performanceShiftDateProvider);
  return computeDateRange(anchor, config);
});

/// Pure function for computing the date range — easy to test.
({DateTime start, DateTime end}) computeDateRange(
  DateTime anchor,
  ShiftConfig config,
) {
  final start = DateTime(
    anchor.year,
    anchor.month,
    anchor.day,
    config.startHour,
  );

  DateTime end;
  if (config.endHour < config.startHour) {
    // Shift spans midnight → end is on the next day
    end = DateTime(
      anchor.year,
      anchor.month,
      anchor.day + 1,
      config.endHour,
    );
  } else {
    // Same-day shift
    end = DateTime(
      anchor.year,
      anchor.month,
      anchor.day,
      config.endHour,
    );
  }

  return (start: start, end: end);
}

// ═══════════════════════════════════════════════════════════════════════════
// Filtered delivered orders — Firebase-optimized
// ═══════════════════════════════════════════════════════════════════════════

/// Streams delivered orders within the selected shift window.
///
/// Uses the Firebase-optimized `watchOrdersForStoresInRange` method,
/// then filters `isDelivered` client-side (RTDB can only orderByChild
/// on one field).
final filteredDeliveredOrdersProvider =
    StreamProvider<List<Order>>((ref) {
  final restaurantUserAsync = ref.watch(currentRestaurantUserProvider);
  final range = ref.watch(performanceDateRangeProvider);

  return restaurantUserAsync.when(
    data: (user) {
      if (user == null || user.restaurantKeys.isEmpty) {
        return Stream.value([]);
      }

      // Convert to ISO 8601 strings for the Firebase query
      final startIso = range.start.toUtc().toIso8601String();
      final endIso = range.end.toUtc().toIso8601String();

      return ref
          .watch(orderRepositoryProvider)
          .watchOrdersForStoresInRange(
            user.restaurantKeys,
            startIso,
            endIso,
          )
          .map(
            (orders) => orders.where((o) => o.meta.isDelivered).toList(),
          );
    },
    loading: () => const Stream.empty(),
    error: (err, stack) => Stream.error(err),
  );
});

// ═══════════════════════════════════════════════════════════════════════════
// Navigation helpers
// ═══════════════════════════════════════════════════════════════════════════

/// Whether the current shift can navigate forward (not past today).
bool canGoForward(WidgetRef ref) {
  final anchor = ref.read(performanceShiftDateProvider);
  return anchor.isBefore(_today());
}

/// Move to the previous shift (anchor - 1 day).
void goToPreviousShift(WidgetRef ref) {
  final current = ref.read(performanceShiftDateProvider);
  ref.read(performanceShiftDateProvider.notifier).state =
      current.subtract(const Duration(days: 1));
}

/// Move to the next shift (anchor + 1 day), capped at today.
void goToNextShift(WidgetRef ref) {
  final current = ref.read(performanceShiftDateProvider);
  final next = current.add(const Duration(days: 1));
  if (!next.isAfter(_today())) {
    ref.read(performanceShiftDateProvider.notifier).state = next;
  }
}
