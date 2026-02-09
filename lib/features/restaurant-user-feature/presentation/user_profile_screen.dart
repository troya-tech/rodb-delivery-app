import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/restaurant_user_providers.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentRestaurantUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant User Profile')),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('User not found'));
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${user.email}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Role: ${user.role.name.toUpperCase()}'),
                const SizedBox(height: 16),
                const Text('Associated Restaurant Keys:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...user.restaurantKeys.map((key) => ListTile(
                  leading: const Icon(Icons.restaurant),
                  title: Text(key),
                )),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
