import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

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
  Stream<User?> get authStateChanges => _firebaseAuth?.authStateChanges() ?? Stream.value(null);

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
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    if (!_isFirebaseSupported) {
      throw 'Firebase Auth is not supported on this platform';
    }
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignInInstance!.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth!.signInWithCredential(credential);

      if (kDebugMode) {
        print('Google Sign In successful: ${userCredential.user?.email}');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print('Google Sign In error: $e');
      }
      // Check for common Google Sign-In errors
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('apiexception: 10')) {
        throw 'Google Sign-In configuration error. Check SHA-1 fingerprint in Firebase Console.';
      } else if (errorStr.contains('apiexception: 12500')) {
        throw 'Google Play Services update required.';
      } else if (errorStr.contains('api key not valid') || errorStr.contains('internal error')) {
        throw 'An internal error has occurred. [ API key not valid. Please pass a valid API key.';
      }
      throw 'Failed to sign in with Google. Please try again.';
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
}
