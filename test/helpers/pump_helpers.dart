import 'package:flutter_test/flutter_test.dart';

/// Flushes pending timers and microtasks after state changes.
///
/// Use this instead of `pumpAndSettle()` in flow tests to avoid
/// hanging on long-running timers (e.g., auto-clear error after 5s).
///
/// Pattern: pump initial frame → flush timers → settle remaining frames.
Future<void> pumpAndFlush(WidgetTester tester) async {
  await tester.pump(); // Initial frame
  await tester.pump(const Duration(seconds: 1)); // Flush short timers
  await tester.pump(); // Settle remaining frames
}
