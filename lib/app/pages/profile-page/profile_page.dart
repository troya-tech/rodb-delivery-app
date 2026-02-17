import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rodb_delivery_app/utils/app_logger.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'profile_page.facade.dart';
import 'profile_page_view_model.dart';

class ProfilePage extends ConsumerWidget {
  static const _logger = AppLogger('ProfilePage');

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.debug('Building ProfilePage');
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(profilePageFacadeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmAndSignOut(context, ref),
          ),
        ],
      ),
      body: switch (state) {
        ProfilePageLoading() =>
          const Center(child: CircularProgressIndicator()),
        ProfilePageError(:final error) =>
          Center(child: Text('Error: $error')),
        ProfilePageNotAuthenticated() =>
          Center(child: Text(l10n.notAuthenticated)),
        ProfilePageLoaded(:final viewModel) =>
          _buildProfileContent(context, viewModel, l10n),
      },
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    ProfilePageViewModel vm,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (vm.photoUrl != null)
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(vm.photoUrl!),
            )
          else
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
          const SizedBox(height: 16),
          Text(
            vm.displayName,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            vm.email,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const Divider(height: 40),
          if (vm.hasRestaurantProfile) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(context, l10n.role, vm.roleLabel!),
                  const SizedBox(height: 16),
                  Text(
                    l10n.associatedKeys,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...vm.restaurantKeys.map((key) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.restaurant),
                          title: Text(key),
                        ),
                      )),
                ],
              ),
            ),
          ] else ...[
            Center(child: Text(l10n.noProfileFound)),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmAndSignOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await profilePageSignOut(ref);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
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
