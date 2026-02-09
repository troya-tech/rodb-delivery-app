import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth-feature/application/auth_providers.dart';
import '../application/restaurant_user_providers.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantUserAsync = ref.watch(currentRestaurantUserProvider);
    final authUserAsync = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ],
      ),
      body: authUserAsync.when(
        data: (authUser) {
          if (authUser == null) return const Center(child: Text('Not authenticated'));
          
          return restaurantUserAsync.when(
            data: (restaurantUser) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (authUser.photoUrl != null)
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(authUser.photoUrl!),
                      )
                    else
                      const CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.person, size: 50),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      authUser.displayName ?? 'No Name',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      authUser.email ?? '',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const Divider(height: 40),
                    if (restaurantUser != null) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(context, 'Role', restaurantUser.role.name.toUpperCase()),
                            const SizedBox(height: 16),
                            const Text(
                              'Associated Restaurant Keys:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...restaurantUser.restaurantKeys.map((key) => Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.restaurant),
                                    title: Text(key),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ] else ...[
                      const Center(child: Text('No restaurant user profile found')),
                    ],
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error loading profile: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Auth Error: $err')),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
