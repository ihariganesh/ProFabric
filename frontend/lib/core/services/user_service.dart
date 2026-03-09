import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserService {
  FirebaseFirestore? _firestore;

  bool get _isFirebaseSupported => !(!kIsWeb && Platform.isLinux);

  FirebaseFirestore? get _firestoreInstance {
    if (!_isFirebaseSupported) return null;
    _firestore ??= FirebaseFirestore.instance;
    return _firestore;
  }

  /// Save user role to Firestore during signup
  Future<void> saveUserRole({
    required String userId,
    required String email,
    required String role,
    required String displayName,
  }) async {
    if (!_isFirebaseSupported) {
      if (kDebugMode) {
        print('Firestore not supported on this platform');
      }
      return;
    }

    try {
      await _firestoreInstance!.collection('users').doc(userId).set({
        'email': email,
        'role': role,
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (kDebugMode) {
        print('User role saved: $email -> $role');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user role: $e');
      }
      throw 'Failed to save user information. Please try again.';
    }
  }

  /// Get user role from Firestore
  Future<String?> getUserRole(String userId) async {
    if (!_isFirebaseSupported) {
      if (kDebugMode) {
        print('Firestore not supported on this platform');
      }
      return null;
    }

    try {
      final doc =
          await _firestoreInstance!.collection('users').doc(userId).get();

      if (doc.exists) {
        final data = doc.data();
        return data?['role'] as String?;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user role: $e');
      }
      return null;
    }
  }

  /// Get complete user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    if (!_isFirebaseSupported) {
      if (kDebugMode) {
        print('Firestore not supported on this platform');
      }
      return null;
    }

    try {
      final doc =
          await _firestoreInstance!.collection('users').doc(userId).get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user data: $e');
      }
      return null;
    }
  }

  /// Get all users with a given role — used by the marketplace to list accounts.
  Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    if (!_isFirebaseSupported) return [];
    try {
      final snapshot = await _firestoreInstance!
          .collection('users')
          .where('role', isEqualTo: role)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      if (kDebugMode) print('Error getting users by role: $e');
      return [];
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoURL,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isFirebaseSupported) return;

    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updates['displayName'] = displayName;
      if (photoURL != null) updates['photoURL'] = photoURL;
      if (additionalData != null) updates.addAll(additionalData);

      await _firestoreInstance!.collection('users').doc(userId).update(updates);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user profile: $e');
      }
      throw 'Failed to update profile. Please try again.';
    }
  }
}
