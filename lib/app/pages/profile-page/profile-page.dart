import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth-feature/application/auth_providers.dart';
import '../../../features/restaurant-user-feature/application/restaurant_user_providers.dart';
import '../../../utils/app_logger.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfilePage extends ConsumerWidget {
  static const _logger = AppLogger('ProfilePage');

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.debug('Building ProfilePage');
    final restaurantUserAsync = ref.watch(currentRestaurantUserProvider);
    final authUserAsync = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.logout),
                  content: Text(AppLocalizations.of(context)!.logoutConfirmation),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(AppLocalizations.of(context)!.logout),
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
          if (authUser == null) {
            _logger.warning('User is not authenticated');
            return Center(child: Text(AppLocalizations.of(context)!.notAuthenticated));
          }
          _logger.data('Auth user loaded', authUser.uid);
          
          return restaurantUserAsync.when(
            data: (restaurantUser) {
              _logger.data('Restaurant user loaded', restaurantUser?.uid);
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
                            _buildInfoRow(context, AppLocalizations.of(context)!.role, restaurantUser.role.name.toUpperCase()),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)!.associatedKeys,
                              style: const TextStyle(fontWeight: FontWeight.bold),
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
                      Center(child: Text(AppLocalizations.of(context)!.noProfileFound)),
                    ],
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) {
              _logger.error('Error loading restaurant user profile', err, stack);
              return Center(child: Text('Error loading profile: $err'));
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) {
          _logger.error('Error loading auth state', err, stack);
          return Center(child: Text('Auth Error: $err'));
        },
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
