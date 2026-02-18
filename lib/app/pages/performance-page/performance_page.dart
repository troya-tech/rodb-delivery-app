import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rodb_delivery_app/app/pages/performance-page/performance_page_view_model.dart';
import 'package:rodb_delivery_app/app/pages/performance-page/performance_shift_provider.dart';
import 'package:rodb_delivery_app/l10n/generated/app_localizations.dart';

class PerformancePage extends ConsumerWidget {
  const PerformancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveredOrdersAsync = ref.watch(filteredDeliveredOrdersProvider);
    final range = ref.watch(performanceDateRangeProvider);
    final forward = canGoForward(ref);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.performanceTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Shift settings',
            onPressed: () => _showShiftSettings(context, ref),
          ),
        ],
      ),
      body: deliveredOrdersAsync.when(
        data: (orders) {
          final viewModel = PerformancePageViewModel.fromOrders(
            orders,
            shiftStart: range.start,
            shiftEnd: range.end,
            canGoForward: forward,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Shift Navigation Bar ──
                _ShiftNavigationBar(
                  label: viewModel.shiftLabel,
                  canGoForward: viewModel.canGoForward,
                  onPrevious: () => goToPreviousShift(ref),
                  onNext: () => goToNextShift(ref),
                ),
                const SizedBox(height: 24),

                // ── Stat Cards ──
                _StatCard(
                  title: 'Total Deliveries',
                  value: viewModel.totalDeliveries.toString(),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                _StatCard(
                  title: 'Total Earnings',
                  value: viewModel.totalEarnings,
                  icon: Icons.attach_money,
                  color: Colors.blue,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showShiftSettings(BuildContext context, WidgetRef ref) {
    final config = ref.read(performanceShiftConfigProvider);
    var startHour = config.startHour;
    var endHour = config.endHour;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Shift Settings',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Start Hour'),
                          const SizedBox(height: 8),
                          DropdownButton<int>(
                            value: startHour,
                            isExpanded: true,
                            items: List.generate(
                              24,
                              (i) => DropdownMenuItem(
                                value: i,
                                child: Text('${i.toString().padLeft(2, '0')}:00'),
                              ),
                            ),
                            onChanged: (v) {
                              if (v != null) {
                                setModalState(() => startHour = v);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('End Hour'),
                          const SizedBox(height: 8),
                          DropdownButton<int>(
                            value: endHour,
                            isExpanded: true,
                            items: List.generate(
                              24,
                              (i) => DropdownMenuItem(
                                value: i,
                                child: Text('${i.toString().padLeft(2, '0')}:00'),
                              ),
                            ),
                            onChanged: (v) {
                              if (v != null) {
                                setModalState(() => endHour = v);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    ref.read(performanceShiftConfigProvider.notifier).state =
                        ShiftConfig(startHour: startHour, endHour: endHour);
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Shift Navigation Bar
// ═══════════════════════════════════════════════════════════════════════════

class _ShiftNavigationBar extends StatelessWidget {
  final String label;
  final bool canGoForward;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _ShiftNavigationBar({
    required this.label,
    required this.canGoForward,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: onPrevious,
              tooltip: 'Previous shift',
            ),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: canGoForward ? onNext : null,
              tooltip: 'Next shift',
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Stat Card
// ═══════════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
