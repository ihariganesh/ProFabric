import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  FirebaseAuth? _auth;
  GoogleSignIn? _googleSignIn;

  bool get _isFirebaseSupported => !(!kIsWeb && Platform.isLinux);

  FirebaseAuth? get _firebaseAuth {
    if (!_isFirebaseSupported) return null;
    _auth ??= FirebaseAuth.instance;
    return _auth;
  }

  GoogleSignIn? get _googleSignInInstance {
    if (!_isFirebaseSupported) return null;
    _googleSignIn ??= GoogleSignIn(scopes: ['email', 'profile']);
    return _googleSignIn;
  }

  // Get current user
  User? get currentUser => _firebaseAuth?.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges =>
      _firebaseAuth?.authStateChanges() ?? Stream.value(null);

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    if (!_isFirebaseSupported) {
      throw 'Firebase Auth is not supported on this platform';
    }
    try {
      final credential = await _firebaseAuth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // Android API 36: Pigeon deserialization bug — auth succeeds but Dart layer throws
      if (_isPigeonError(e)) {
        if (kDebugMode) {
          print('PigeonUserDetails bug on signIn — checking auth state...');
        }
        if (await _waitForFirebaseAuth()) return null;
        throw 'Sign-in failed. Please try again.';
      }
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (!_isFirebaseSupported) {
      throw 'Firebase Auth is not supported on this platform';
    }
    try {
      final credential = await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(displayName);
      await credential.user?.reload();

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // Android API 36: Pigeon deserialization bug — account created but Dart layer throws
      if (_isPigeonError(e)) {
        if (kDebugMode) {
          print('PigeonUserDetails bug on signUp — checking auth state...');
        }
        if (await _waitForFirebaseAuth()) {
          try {
            await _firebaseAuth!.currentUser?.updateDisplayName(displayName);
          } catch (_) {}
          return null;
        }
        throw 'Account creation failed. Please try again.';
      }
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Check if error is the known PigeonUserDetails deserialization bug
  bool _isPigeonError(dynamic e) {
    final s = e.toString();
    return s.contains('PigeonUserDetails') || s.contains("List<Object?>");
  }

  // Wait for Firebase Auth to complete and return currentUser if signed in
  Future<bool> _waitForFirebaseAuth() async {
    // Check immediately first — Firebase Auth often settles before Pigeon throws
    if (_firebaseAuth!.currentUser != null) {
      if (kDebugMode) {
        print(
            'Firebase Auth confirmed immediately: ${_firebaseAuth!.currentUser!.email}');
      }
      return true;
    }
    // If not ready yet, poll up to 3×300 ms
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      try {
        await _firebaseAuth!.currentUser?.reload();
      } catch (_) {}
      if (_firebaseAuth!.currentUser != null) {
        if (kDebugMode) {
          print(
              'Firebase Auth confirmed: ${_firebaseAuth!.currentUser!.email}');
        }
        return true;
      }
    }
    return false;
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    if (!_isFirebaseSupported) {
      throw 'Firebase Auth is not supported on this platform';
    }

    try {
      // Try silent sign-in first — instant for returning users
      GoogleSignInAccount? googleUser =
          await _googleSignInInstance!.signInSilently();
      // Fall back to interactive sign-in if silent fails
      googleUser ??= await _googleSignInInstance!.signIn();

      if (googleUser == null) {
        return null; // User canceled
      }

      // Get tokens and authenticate with Firebase
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential =
          await _firebaseAuth!.signInWithCredential(credential);

      if (kDebugMode) {
        print('Google Sign In successful: ${userCredential.user?.email}');
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // google_sign_in v6.x has a Pigeon deserialization bug on newer Android.
      // The native Google Sign-In + Firebase Auth both succeed, but the Dart
      // Pigeon layer fails to deserialize the response. This affects signIn(),
      // signInSilently(), and .authentication — so we skip all of them and
      // just check Firebase's auth state directly.
      if (_isPigeonError(e)) {
        if (kDebugMode) {
          print(
              'PigeonUserDetails bug — checking Firebase auth state directly...');
        }
        if (await _waitForFirebaseAuth()) {
          return null; // Auth succeeded — caller uses currentUser
        }
        throw 'Google Sign-In failed. Please try again.';
      }

      // Handle other Google Sign-In errors
      if (kDebugMode) {
        print('Google Sign In error: $e');
      }
      final errorStr = e.toString();
      if (errorStr.contains('apiexception: 10')) {
        throw 'Google Sign-In configuration error. Check SHA-1 fingerprint in Firebase Console.';
      } else if (errorStr.contains('apiexception: 12500')) {
        throw 'Google Play Services update required.';
      } else if (errorStr.contains('api key not valid') ||
          errorStr.contains('internal error')) {
        throw 'An internal error has occurred. [ API key not valid. Please pass a valid API key.';
      }
      throw 'Failed to sign in with Google. Please try again.';
    }
  }

  // ── Role persistence ──────────────────────────────────────────────────────
  static const String _rolePrefix = 'user_role_';

  /// Persist the role chosen at sign-up so cross-role logins can be blocked.
  Future<void> saveUserRole(String uid, String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_rolePrefix$uid', role);
    } catch (_) {}
  }

  /// Returns the stored role for [uid], or null if none saved yet.
  Future<String?> getUserRole(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('$_rolePrefix$uid');
    } catch (_) {
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    if (!_isFirebaseSupported) return;
    try {
      await Future.wait([
        _firebaseAuth!.signOut(),
        _googleSignInInstance?.signOut() ?? Future.value(),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('Sign out error: $e');
      }
      throw 'Failed to sign out. Please try again.';
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    if (!_isFirebaseSupported) {
      throw 'Firebase Auth is not supported on this platform';
    }
    try {
      await _firebaseAuth!.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send reset email. Please try again.';
    }
  }

  // Send sign-in link to email
  Future<void> sendEmailLink({
    required String email,
  }) async {
    if (!_isFirebaseSupported) {
      throw 'Firebase Auth is not supported on this platform';
    }
    try {
      var acs = ActionCodeSettings(
        // URL must be whitelisted in the Firebase Console.
        url: 'https://fabricflow.page.link/login',
        handleCodeInApp: true,
        iOSBundleId: 'com.example.fabricflow',
        androidPackageName: 'com.example.fabricflow',
        androidInstallApp: true,
        androidMinimumVersion: '12',
      );

      await _firebaseAuth!.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: acs,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send sign-in link. Please try again.';
    }
  }

  // Sign in with email link
  Future<UserCredential?> signInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    if (!_isFirebaseSupported) {
      throw 'Firebase Auth is not supported on this platform';
    }
    try {
      if (_firebaseAuth!.isSignInWithEmailLink(emailLink)) {
        final credential = await _firebaseAuth!.signInWithEmailLink(
          email: email,
          emailLink: emailLink,
        );
        return credential;
      } else {
        throw 'Invalid email sign-in link.';
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to sign in with link. Please try again.';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check and try again.';
      case 'account-exists-with-different-credential':
        return 'An account exists with the same email but different sign-in credentials.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'invalid-action-code':
        return 'The sign-in link is invalid or has expired.';
      default:
        if (kDebugMode) {
          print('Firebase Auth Error: ${e.code} - ${e.message}');
        }
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  // Check if user is signed in
  bool isSignedIn() {
    return _firebaseAuth?.currentUser != null;
  }

  // Get user email
  String? getUserEmail() {
    return _firebaseAuth?.currentUser?.email;
  }

  // Get user display name
  String? getUserDisplayName() {
    return _firebaseAuth?.currentUser?.displayName;
  }

  // Get user photo URL
  String? getUserPhotoURL() {
    return _firebaseAuth?.currentUser?.photoURL;
  }

  // Update display name
  Future<void> updateDisplayName(String name) async {
    if (!_isFirebaseSupported) return;
    try {
      await _firebaseAuth?.currentUser?.updateDisplayName(name);
      await _firebaseAuth?.currentUser?.reload();
    } catch (e) {
      if (kDebugMode) {
        print('Update display name error: $e');
      }
      throw 'Failed to update name. Please try again.';
    }
  }

  // Update photo URL
  Future<void> updatePhotoURL(String url) async {
    if (!_isFirebaseSupported) return;
    try {
      await _firebaseAuth?.currentUser?.updatePhotoURL(url);
      await _firebaseAuth?.currentUser?.reload();
    } catch (e) {
      if (kDebugMode) {
        print('Update photo URL error: $e');
      }
      throw 'Failed to update photo. Please try again.';
    }
  }
}
