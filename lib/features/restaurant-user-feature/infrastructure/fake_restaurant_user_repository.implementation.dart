import 'package:rxdart/rxdart.dart';
import '../domain/restaurant_user.dart';
import '../domain/restaurant_user_repository.dart';
import 'package:rodb_delivery_app/testing/restaurant_user_fixtures.dart';

/// A fake implementation of [RestaurantUserRepository] for testing purposes.
///
/// Following Vladimir Khorikov's definition of a **Fake**:
/// It provides a functional, stateful, but simplified implementation of the
/// repository without external dependencies (Firebase).
class FakeRestaurantUserRepository implements RestaurantUserRepository {
  /// In-memory storage of users indexed by UID.
  final Map<String, RestaurantUser> _usersByUid = {};

  /// Stream controllers indexed by email.
  final Map<String, BehaviorSubject<RestaurantUser?>> _controllersByEmail = {};

  /// Creates a [FakeRestaurantUserRepository].
  ///
  /// If [seedWithFixtures] is true (default), it pre-populates the repository
  /// from [RestaurantUserFixtures].
  FakeRestaurantUserRepository({bool seedWithFixtures = true}) {
    if (seedWithFixtures) {
      _seedFromFixtures();
    }
  }

  void _seedFromFixtures() {
    final fixtures = [
      RestaurantUserFixtures.testUser1,
      RestaurantUserFixtures.testUser2,
      RestaurantUserFixtures.testUser3,
      RestaurantUserFixtures.testUser4,
    ];

    for (final user in fixtures) {
      _usersByUid[user.uid] = user;
      // We don't seed controllers here yet, they are created on-demand by _controllerFor
    }
  }

  BehaviorSubject<RestaurantUser?> _controllerFor(String email) {
    if (!_controllersByEmail.containsKey(email)) {
      final user = _usersByUid.values.cast<RestaurantUser?>().firstWhere(
            (u) => u?.email == email,
            orElse: () => null,
          );
      _controllersByEmail[email] = BehaviorSubject<RestaurantUser?>.seeded(user);
    }
    return _controllersByEmail[email]!;
  }

  @override
  Future<RestaurantUser?> getRestaurantUserByEmail(String email) async {
    return _usersByUid.values.cast<RestaurantUser?>().firstWhere(
          (u) => u?.email == email,
          orElse: () => null,
        );
  }

  @override
  Future<void> saveRestaurantUser(RestaurantUser user) async {
    _usersByUid[user.uid] = user;
    _controllerFor(user.email).add(user);
  }

  @override
  Stream<RestaurantUser?> watchRestaurantUserByEmail(String email) {
    return _controllerFor(email).stream;
  }

  @override
  Future<void> addRestaurantKey(String uid, String restaurantKey) async {
    final user = _usersByUid[uid];
    if (user != null) {
      final updatedKeys = List<String>.from(user.restaurantKeys);
      if (!updatedKeys.contains(restaurantKey)) {
        updatedKeys.add(restaurantKey);
      }
      final updatedUser = user.copyWith(restaurantKeys: updatedKeys);
      _usersByUid[uid] = updatedUser;
      _controllerFor(updatedUser.email).add(updatedUser);
    }
  }

  // ── Test helpers ──────────────────────────────────────────────────────

  /// Manually inject a user into the fake repository.
  void emitUser(RestaurantUser user) {
    _usersByUid[user.uid] = user;
    _controllerFor(user.email).add(user);
  }

  /// Remove a user by UID.
  void removeUser(String uid) {
    final user = _usersByUid.remove(uid);
    if (user != null) {
      _controllerFor(user.email).add(null);
    }
  }

  /// Clean up all stream controllers.
  void dispose() {
    for (final controller in _controllersByEmail.values) {
      controller.close();
    }
    _controllersByEmail.clear();
  }
}
