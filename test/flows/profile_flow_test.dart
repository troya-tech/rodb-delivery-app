import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rodb_delivery_app/features/restaurant-user-feature/presentation/user_profile_screen.dart';
import 'package:rodb_delivery_app/testing/restaurant_user_fixtures.dart';

import '../helpers/test_app.dart';
import '../helpers/pump_helpers.dart';

/// Profile Page Flow Tests
///
/// Verifies the UserProfileScreen renders correct data from both
/// AuthFixtures (auth user) and RestaurantUserFixtures (restaurant user),
/// handles edge cases, and supports logout with confirmation.
///
/// Data chain:
/// AuthFixtures.testUser (foorcun@gmail.com)
///   → matched by email in FakeRestaurantUserRepository
/// RestaurantUserFixtures.testUser4 (foorcun@gmail.com, OWNER, key: 318920)
///   → watched via currentRestaurantUserProvider
/// UserProfileScreen renders profile info
void main() {
  late TestHarness harness;

  setUp(() {
    harness = TestHarness.create();
  });

  group('Profile — Display', () {
    testWidgets('Shows display name from auth user', (tester) async {
      await tester.pumpWidget(harness.buildProfileApp());
      await pumpAndFlush(tester);
      await pumpAndFlush(tester); // 2nd flush for nested StreamProvider chain

      expect(find.text('Furkan Fake'), findsOneWidget);
    });

    testWidgets('Shows email from auth user', (tester) async {
      await tester.pumpWidget(harness.buildProfileApp());
      await pumpAndFlush(tester);
      await pumpAndFlush(tester);

      expect(find.text('foorcun@gmail.com'), findsOneWidget);
    });

    testWidgets('Shows role from restaurant user', (tester) async {
      await tester.pumpWidget(harness.buildProfileApp());
      await pumpAndFlush(tester);
      await pumpAndFlush(tester);

      expect(find.text('OWNER'), findsOneWidget);
    });

    testWidgets('Shows restaurant key', (tester) async {
      await tester.pumpWidget(harness.buildProfileApp());
      await pumpAndFlush(tester);
      await pumpAndFlush(tester);

      expect(
        find.text('${RestaurantUserFixtures.restaurantKey}'),
        findsOneWidget,
      );
    });

    testWidgets('Shows Associated Restaurant Keys list', (tester) async {
      await tester.pumpWidget(harness.buildProfileApp());
      await pumpAndFlush(tester);
      await pumpAndFlush(tester);

      // Verify the section header
      expect(find.text('Associated Restaurant Keys:'), findsOneWidget);

      // Verify the key is rendered inside a ListTile with a restaurant icon
      expect(find.byIcon(Icons.restaurant), findsOneWidget);
      expect(
        find.text('${RestaurantUserFixtures.restaurantKey}'),
        findsOneWidget,
      );
    });
  });

  group('Profile — Edge Cases', () {
    testWidgets('No auth user shows Not authenticated', (tester) async {
      await tester.pumpWidget(harness.buildProfileApp());
      await pumpAndFlush(tester);
      await pumpAndFlush(tester);

      // Sign out after the widget is built — simulates losing auth
      harness.fakeAuth.emitUser(null);
      await pumpAndFlush(tester);

      expect(find.text('Not authenticated'), findsOneWidget);
    });

    testWidgets('No restaurant user shows fallback message', (tester) async {
      // Use a user email that has no match in FakeRestaurantUserRepository
      harness.fakeRestaurantUser.removeUser(RestaurantUserFixtures.user4Uid);

      await tester.pumpWidget(harness.buildProfileApp());
      await pumpAndFlush(tester);
      await pumpAndFlush(tester);

      expect(find.text('No restaurant user profile found'), findsOneWidget);
    });
  });

  group('Profile — Logout', () {
    testWidgets('Logout button shows confirmation dialog', (tester) async {
      await tester.pumpWidget(harness.buildProfileApp());
      await pumpAndFlush(tester);
      await pumpAndFlush(tester);

      // Tap the logout icon button
      await tester.tap(find.byIcon(Icons.logout));
      await pumpAndFlush(tester);

      // Verify dialog appears
      expect(find.text('Are you sure you want to log out?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Logout'), findsWidgets);
    });

    testWidgets('Cancelling logout dialog stays on profile', (tester) async {
      await tester.pumpWidget(harness.buildProfileApp());
      await pumpAndFlush(tester);
      await pumpAndFlush(tester);

      // Open dialog
      await tester.tap(find.byIcon(Icons.logout));
      await pumpAndFlush(tester);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await pumpAndFlush(tester);

      // Dialog dismissed, profile still visible
      expect(find.byType(UserProfileScreen), findsOneWidget);
      expect(find.text('Furkan Fake'), findsOneWidget);
    });

    testWidgets('Confirming logout signs out', (tester) async {
      await tester.pumpWidget(harness.buildProfileApp());
      await pumpAndFlush(tester);
      await pumpAndFlush(tester);

      // Open dialog
      await tester.tap(find.byIcon(Icons.logout));
      await pumpAndFlush(tester);

      // Tap Logout (the TextButton inside the dialog, not the AppBar icon)
      await tester.tap(find.widgetWithText(TextButton, 'Logout'));
      await pumpAndFlush(tester);

      // Verify: auth state is now null
      expect(harness.fakeAuth.currentUser, isNull);
    });
  });
}
