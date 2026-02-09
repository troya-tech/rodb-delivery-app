import 'package:flutter/services.dart'; // For PlatformException
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
  // v7: Use singleton instance
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
  @override
  Future<AuthUser> signInWithGoogle() async {
    final context = _logger.createContext();
    _logger.info('Starting Google Sign-In flow (v7)', context);
    
    try {
      final credential = await _performGoogleSignIn(context);
      final user = credential.user;
      if (user == null) {
         throw Exception('Google Sign-In succeeded but user is null');
      }
      return _mapFirebaseUser(user)!;
    } catch (e) {
      if (_isError16(e)) {
        _logger.warning('Credential Manager cache issue detected (Error 16), clearing and retrying...', context);
        
        try {
          // Retry cleanup
          try { await _googleSignIn.disconnect(); } catch (_) {}
          try { await _googleSignIn.signOut(); } catch (_) {}
          _logger.debug('State cleared. Waiting before retry...', context);
          
          // Brief delay to allow Credential Manager to reset
          await Future.delayed(const Duration(seconds: 1));
          
          // Force interactive sign-in on retry to avoid lightweight auth loop
          _logger.debug('Retrying with forced interactive sign-in...', context);
          final account = await _googleSignIn.authenticate();
          
          if (account == null) {
            throw FirebaseAuthException(code: 'canceled', message: 'User canceled sign in retry');
          }
          
          final credential = await _createCredentialFromAccount(account, context);
          return await _signInWithCredential(credential, context);

        } catch (retryError) {
          _logger.error('Google Sign-In retry failed', retryError, null, context);
          throw Exception('Google Sign-In failed after retry: $retryError');
        }
      }
      
      _logger.error('Google Sign-In failed', e, null, context);
      if (_isCanceled(e)) {
        throw Exception('Google Sign-In was canceled by user');
      }
      throw Exception('Google Sign-In failed: $e');
    }
  }

  bool _isError16(Object e) {
    final s = e.toString();
    return s.contains('16') && s.contains('reauth'); // Simple string check for safety
  }

  bool _isCanceled(Object e) {
    if (e is PlatformException && e.code == 'canceled') return true;
    if (e is FirebaseAuthException && e.code == 'canceled') return true;
    return e.toString().contains('canceled');
  }

  Future<AuthUser> _signInWithCredential(OAuthCredential credential, dynamic context) async {
    _logger.debug('Signing in to Firebase with credential...', context);
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user == null) {
         throw Exception('Firebase sign-in succeeded but user is null');
      }

      _logger.success('Firebase sign-in successful', context);
      _logger.data('User UID', user.uid, context);
      _logger.data('User email', user.email, context);
      
      return _mapFirebaseUser(user)!;
    } on FirebaseAuthException catch (e) {
      _logger.error('Firebase Auth Error: [${e.code}] ${e.message}', e, null, context);
      rethrow;
    } catch (e) {
      _logger.error('Unexpected error during Firebase sign-in', e, null, context);
      rethrow;
    }
  }

  Future<OAuthCredential> _createCredentialFromAccount(GoogleSignInAccount account, dynamic context) async {
    _logger.debug('Getting authentication tokens for ${account.email}...', context);
    final GoogleSignInAuthentication auth = await account.authentication;
    final String? idToken = auth.idToken;
    // final String? accessToken = auth.accessToken; // Removed: Not available in v7 by default

    if (idToken == null) {
      _logger.error('Google ID token is null', null, null, context);
      throw StateError('Google ID token is null. Check configuration.');
    }
    
    return GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: null, // accessToken is optional and not available in basic v7 auth
    );
  }

  Future<UserCredential> _performGoogleSignIn(dynamic context) async {
    _logger.debug('Attempting lightweight authentication...', context);
    GoogleSignInAccount? account = await _googleSignIn.attemptLightweightAuthentication();
    
    if (account == null) {
      _logger.debug('Lightweight auth unavailable, using interactive sign-in...', context);
      try {
        account = await _googleSignIn.authenticate();
      } catch (e) {
        if (_isCanceled(e)) return Future.error(e);
        _logger.warning('Interactive auth failed: $e', context);
        throw e;
      }
    }
    
    if (account == null) {
         throw FirebaseAuthException(code: 'canceled', message: 'User canceled sign in');
    }

    _logger.success('Google authentication successful', context);
    
    final credential = await _createCredentialFromAccount(account, context);
    
    // We duplicate logic here because _performGoogleSignIn signature (UserCredential) 
    // is slightly different from _signInWithCredential (AuthUser), but that's fine for now 
    // or we can refactor _performGoogleSignIn to return AuthUser too.
    // To match existing call sites, let's keep it returning UserCredential or change call sites.
    // Ah, signInWithGoogle expects UserCredential from _performGoogleSignIn in original code?
    // Let's check original code: `final credential = await _performGoogleSignIn(context); final user = credential.user;`
    // Yes, it returns UserCredential.
    // But `_signInWithCredential` helper returns AuthUser.
    // I will simply duplicate the `signInWithCredential` call here to keep return type consistent OR update signature.
    // Let's update signature of _performGoogleSignIn to return AuthUser! cleaner.
    
    return _auth.signInWithCredential(credential);
  }

  @override
  Future<void> signOut() async {
    final context = _logger.createContext();
    _logger.info('Starting sign-out process', context);
    
    try {
      _logger.debug('Signing out from Firebase and Google...', context);
      try {
        await _googleSignIn.disconnect();
      } catch (e) {
        _logger.debug('Google disconnect failed or not applicable: $e', context);
      }
      try { await _googleSignIn.signOut(); } catch (_) {}

      await _auth.signOut();
      _logger.success('Sign-out successful', context);
    } catch (e) {
      _logger.error('Sign-out failed', e, null, context);
      throw Exception('Sign-out failed: $e');
    }
  }
}
