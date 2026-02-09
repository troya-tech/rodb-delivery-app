import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../utils/app_logger.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

/// Authentication service implementation using Firebase and Google Sign-In
class AuthService implements AuthRepository {
  // Singleton pattern
  const AuthService._();
  static const AuthService instance = AuthService._();
  factory AuthService() => instance;

  // Logger
  static final _logger = AppLogger('AuthService');

  // Firebase Auth instance
  FirebaseAuth get _auth => FirebaseAuth.instance;

  // Google Sign-In instance
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  @override
  AuthUser? get currentUser => _mapFirebaseUser(_auth.currentUser);

  @override
  Stream<AuthUser?> authStateChanges() {
    return _auth.authStateChanges().map(_mapFirebaseUser);
  }

  AuthUser? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  /// Fast-fail connectivity check before attempting sign-in
  Future<void> _checkConnectivity(dynamic context) async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw Exception('No internet connection');
      }
      _logger.debug('Connectivity check passed', context);
    } on SocketException catch (_) {
      _logger.error('No internet connection', null, null, context);
      throw Exception(
        'No internet connection. Please check your network and try again.',
      );
    } on TimeoutException catch (_) {
      _logger.error('Internet connection timeout', null, null, context);
      throw Exception(
        'Internet connection is too slow. Please check your network and try again.',
      );
    }
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    final context = _logger.createContext();
    _logger.info('Starting Google Sign-In flow', context);

    // Fast-fail: check internet before attempting sign-in
    await _checkConnectivity(context);

    try {
      final credential = await _performGoogleSignIn(context);
      return _mapFirebaseUser(credential.user)!;
    } on GoogleSignInException catch (e) {
      // HANDLE ERROR 16 retry logic
      if (e.code == GoogleSignInExceptionCode.canceled &&
          e.description?.contains('16') == true) {
        _logger.warning(
          'Credential Manager cache issue detected (Error 16), clearing and retrying...',
          context,
        );

        // Mitigation: Clear cached credentials before retry
        try {
          await _googleSignIn.disconnect();
        } catch (_) {}

        await Future.delayed(const Duration(seconds: 1));

        try {
          final credential = await _performGoogleSignIn(context);
          return _mapFirebaseUser(credential.user)!;
        } catch (retryError) {
          _logger.error('Google Sign-In retry failed', retryError, null, context);
          throw Exception('Google Sign-In failed after retry: $retryError');
        }
      }

      _logger.error('Google Sign-In failed', e, null, context);
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw Exception('Google Sign-In was canceled by user');
      }
      throw Exception('Google Sign-In failed: ${e.description ?? e.code}');
    } catch (e) {
      _logger.error('Google Sign-In failed', e, null, context);
      throw Exception('Google Sign-In failed: $e');
    }
  }

  Future<UserCredential> _performGoogleSignIn(dynamic context) async {
    const List<String> scopes = ['email'];

    // 1. Silent sign-in warm up
    _logger.debug('Attempting lightweight authentication...', context);
    GoogleSignInAccount? account =
        await _googleSignIn.attemptLightweightAuthentication();

    // 2. Interactive sign-in fallback
    if (account == null) {
      _logger.debug('Lightweight auth unavailable, using interactive sign-in...', context);
      account = await _googleSignIn.authenticate(scopeHint: scopes);
    }

    _logger.success('Google authentication successful', context);
    _logger.data('Account email', account.email, context);

    // 3. ID Token extraction
    _logger.debug('Getting authentication tokens...', context);
    final GoogleSignInAuthentication auth = account.authentication;
    final String? idToken = auth.idToken;
    if (idToken == null) {
      _logger.error('Google ID token is null', null, null, context);
      throw StateError(
        'Google ID token is null. Ensure a Web Client ID (client_type: 3) exists in google-services.json.',
      );
    }
    _logger.debug('ID token obtained successfully', context);

    // 4. Access Token (Optional separate step in v7)
    String? accessToken;
    try {
      final authz = await account.authorizationClient.authorizeScopes(scopes);
      accessToken = authz.accessToken;
      _logger.debug('Access token obtained successfully', context);
    } catch (authzError) {
      _logger.warning(
        'Authorization failed (proceeding with idToken only): $authzError',
        context,
      );
    }

    // 5. Firebase Sign-In
    _logger.debug('Creating Firebase credential...', context);
    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: accessToken,
    );

    _logger.debug('Signing in to Firebase...', context);
    try {
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      _logger.success('Firebase sign-in successful', context);
      _logger.data('User UID', userCredential.user?.uid, context);
      _logger.data('User email', userCredential.user?.email, context);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      _logger.error(
        'Firebase Auth Error: [${e.code}] ${e.message}',
        e,
        null,
        context,
      );
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    final context = _logger.createContext();
    _logger.info('Starting sign-out process', context);

    try {
      _logger.debug('Signing out from Firebase and Google...', context);
      // Both disconnect and signOut to prevent stale session on next login
      try {
        await _googleSignIn.disconnect();
      } catch (_) {}

      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      _logger.success('Sign-out successful', context);
    } catch (e) {
      _logger.error('Sign-out failed', e, null, context);
      throw Exception('Sign-out failed: $e');
    }
  }
}
