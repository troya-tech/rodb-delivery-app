import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rodb_delivery_app/features/auth-feature/application/auth_providers.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _isSigningIn = false;
  String? _statusMessage;
  bool _isError = false;

  Future<void> _handleSignIn() async {
    if (_isSigningIn) return; // Prevent multiple taps

    setState(() {
      _isSigningIn = true;
      _statusMessage = AppLocalizations.of(context)!.checkingConnection;
      _isError = false;
    });

    try {
      // Brief delay so the user sees the "checking" message
      await Future.delayed(const Duration(milliseconds: 200));

      setState(() {
        _statusMessage = AppLocalizations.of(context)!.signInLoading;
      });

      await ref.read(authRepositoryProvider).signInWithGoogle();
      // Auth state stream will automatically navigate away on success
    } catch (e) {
      if (!mounted) return;

      final message = _parseErrorMessage(e.toString());
      setState(() {
        _isError = true;
        _statusMessage = message;
      });

      // Auto-clear error after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && _isError) {
          setState(() {
            _statusMessage = null;
            _isError = false;
          });
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  String _parseErrorMessage(String error) {
    // Strip "Exception: " prefix for cleaner display
    final cleaned = error.replaceFirst('Exception: ', '');

    if (cleaned.contains('No internet connection')) {
      return AppLocalizations.of(context)!.noInternetError;
    }
    if (cleaned.contains('too slow') || cleaned.contains('timeout')) {
      return AppLocalizations.of(context)!.slowConnectionError;
    }
    if (cleaned.contains('canceled')) {
      return AppLocalizations.of(context)!.genericError; // Or add a specific one
    }
    if (cleaned.contains('Error 16') || cleaned.contains('reauth')) {
      return AppLocalizations.of(context)!.authError;
    }
    if (cleaned.contains('ID token is null')) {
      return AppLocalizations.of(context)!.configError;
    }

    return AppLocalizations.of(context)!.genericError;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon / branding
              Icon(
                Icons.delivery_dining_rounded,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.appTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.signInTitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 48),

              // Sign-in button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _isSigningIn ? null : _handleSignIn,
                  icon: _isSigningIn
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.login_rounded),
                  label: Text(
                    _isSigningIn
                        ? AppLocalizations.of(context)!.signInLoading
                        : AppLocalizations.of(context)!.signInButton,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Status / Error feedback
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _statusMessage != null
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isError
                              ? theme.colorScheme.errorContainer
                              : theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            if (!_isError && _isSigningIn)
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Text(
                                _statusMessage!,
                                style: TextStyle(
                                  color: _isError
                                      ? theme.colorScheme.onErrorContainer
                                      : theme.colorScheme.onPrimaryContainer,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (_isError)
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _statusMessage = null;
                                    _isError = false;
                                  });
                                },
                              ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
